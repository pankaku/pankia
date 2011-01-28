#import "PNPacketFireWall.h"
#include <arpa/inet.h>
#include <netdb.h>
#import "PNGlobal.h"
#import "PNLogger+Package.h"

#define kPNDNStoIPV4CheckDelayTime	5.0
#define kPNPacketFirewallEnabled	YES

@interface PNPacketFireWall()
-(void)DNSToIPv4;
@end

@implementation PNPacketFireWall

static PNPacketFireWall* packetFireWall() {
	static PNPacketFireWall *firewall = nil;
	@synchronized(firewall) {
		if(!firewall) {
			firewall = [[PNPacketFireWall alloc] init];
		}
	}
	return firewall;
}

+(NSDictionary*)getDynamicIptables{
	PNPacketFireWall* firewall = packetFireWall();
	return firewall->dynamicIptables;
}
+(PNPacketFireWall*)sharedObject{
	return packetFireWall();
}

-(id)init
{
	if(self = [super init]) {
		dynamicIptables = [[NSMutableDictionary dictionary] retain];
		fixedIptables	= [[NSMutableDictionary dictionary] retain];
		[self DNSToIPv4];
	}
	return self;
}

-(void)dealloc
{
	[dynamicIptables release];
	[fixedIptables release];
	[super dealloc];
}

-(void)DNSToIPv4
{
	PNLog(@"DNSToIPv4");
	BOOL retry = NO;
	@synchronized(self) {
		NSArray* hosts = [NSArray arrayWithObjects:kPNPrimaryHost,kPNSecondaryHost,nil];
		for(NSString* ipv4 in hosts) {
			struct sockaddr_in addr_in;
			struct hostent *ent = (struct hostent *)gethostbyname([ipv4 UTF8String]);
			if(ent) {
				addr_in.sin_addr = *((struct in_addr*)ent->h_addr);
				const char* ipv4Address = inet_ntoa(addr_in.sin_addr);
				[fixedIptables setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%s",ipv4Address]];
				PNLog(@"Registered %s into firewall table.\n",ipv4Address);
			} else {
				retry = YES;
			}
		}
	}
	
	if(retry)
		[self performSelector:@selector(DNSToIPv4) withObject:nil afterDelay:kPNDNStoIPV4CheckDelayTime];
}

+(void)initialize
{
	packetFireWall();
}

NSString* uniting(NSString* aIPv4,int aPort) {
	return [NSString stringWithFormat:@"%@:%d",aIPv4,aPort];
}

+(void)allowIPv4:(NSString*)aIPv4 port:(int)aPort
{
	if(!kPNPacketFirewallEnabled)
		return;

	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Firewall#allow %@:%d",aIPv4,aPort);
	PNPacketFireWall* firewall = packetFireWall();
	@synchronized(firewall) {
		[firewall->dynamicIptables setObject:[NSNumber numberWithBool:YES] forKey:uniting(aIPv4,aPort)];
	}
}

+(BOOL)isServerAddress:(NSString*)aIPv4
{
	PNPacketFireWall* firewall = packetFireWall();
	@synchronized(firewall) {
		NSNumber* mark = [firewall->fixedIptables objectForKey:aIPv4];
		if(mark)
			return YES;
	}
	return NO;
}


+(BOOL)isIPv4Allowed:(NSString*)aIPv4 port:(int)aPort
{
	if(!kPNPacketFirewallEnabled)
		return YES;
	PNPacketFireWall* firewall = packetFireWall();
	@synchronized(firewall) {
		{
			NSNumber* mark = [firewall->dynamicIptables objectForKey:uniting(aIPv4,aPort)];
			if(mark && [mark boolValue]) {
				return YES;
			}
		}
		{
			NSNumber* mark = [firewall->fixedIptables objectForKey:aIPv4];
			if(mark && [mark boolValue]) {
				return YES;
			}
		}
	}
	return NO;
}

+(void)removeIPv4:(NSString*)aIPv4 port:(int)aPort
{
	if(!kPNPacketFirewallEnabled)
		return;
	
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Firewall#remove %@:%d",aIPv4,aPort);
	PNCLog(PNLOG_CAT_PACKET_FIREWALL, @"Removed %@:%d from firewall", aIPv4,aPort);
	PNPacketFireWall* firewall = packetFireWall();
	@synchronized(firewall) {
		if(aIPv4) [firewall->dynamicIptables removeObjectForKey:uniting(aIPv4,aPort)];
	}
}

+(void)clear
{
	if(!kPNPacketFirewallEnabled)
		return;
	
	PNCLog(PNLOG_CAT_PACKET_FIREWALL, @"Warning! Clearing packet firewall.");
	PNPacketFireWall* firewall = packetFireWall();
	@synchronized(firewall) {
		[firewall->dynamicIptables removeAllObjects];
	}
	
	for(NSString* ip in [firewall->dynamicIptables allValues]) {
		PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Firewall#remove:%@",ip);
	}
	
	PNCLog(PNLOG_CAT_PACKET_FIREWALL, @"Packet firewall cleared.");
}

@end

