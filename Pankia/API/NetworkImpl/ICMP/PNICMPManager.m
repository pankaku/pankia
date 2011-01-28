#import "PNICMPManager.h"
#import "PNLogger+Package.h"


@interface PNICMPManager (Private)
- (void)sendBuffer;
@end


static BOOL ICMPConnectionCanSendRequest = NO;

void ICMPConnectionCallBack (
							 CFSocketRef s,
							 CFSocketCallBackType callbackType,
							 CFDataRef address,
							 const void *data,
							 void *info
							 ) {
	switch (callbackType) {
		case  kCFSocketAutomaticallyReenableReadCallBack:;
			PNCLog( PNLOG_CAT_ICMP, @"kCFSocketAutomaticallyReenableReadCallBack:");
			break;
		case kCFSocketAutomaticallyReenableAcceptCallBack:;
			PNCLog( PNLOG_CAT_ICMP, @"kCFSocketAutomaticallyReenableAcceptCallBack:");
			break;
		case kCFSocketAutomaticallyReenableDataCallBack:;
			PNCLog( PNLOG_CAT_ICMP, @"kCFSocketAutomaticallyReenableDataCallBack:");
			NSData* packetData = (NSData *)data;
			struct ip iph;
			[packetData getBytes:&iph length:sizeof(iph)];
			PNCLog( PNLOG_CAT_ICMP, @"IP Header Length:%u", iph.ip_hl * 4);
			PNCLog( PNLOG_CAT_ICMP, @"IP_TOS:%u, IP_V:%u, IP_ID:%u IP_P:%u", iph.ip_tos, iph.ip_v, iph.ip_id, iph.ip_p);
			NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
			struct icmp icp;
			[packetData getBytes:&icp range:NSMakeRange(iph.ip_hl * 4, sizeof(icp))];
			PNCLog( PNLOG_CAT_ICMP, @"ICMP Result Identifier:%04x, chsum:%04x", icp.icmp_id, icp.icmp_cksum);
			PNCLog( PNLOG_CAT_ICMP, @"ICMP Result Type:%04x, subcode:%04x", icp.icmp_type, icp.icmp_code);
			NSData* icmpValue = [NSData dataWithBytes:&icp length:sizeof(icp)];
			[userInfo setObject:icmpValue forKey:@"ICMP"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ICMPManagerDidGetResponse" object:[PNICMPManager sharedObject] userInfo:userInfo];
			break;
		case kCFSocketAutomaticallyReenableWriteCallBack:;
			PNCLog( PNLOG_CAT_ICMP, @"kCFSocketAutomaticallyReenableWriteCallBack:");
			ICMPConnectionCanSendRequest = YES;
			[[PNICMPManager sharedObject] sendBuffer];
			break;
		case kCFSocketCloseOnInvalidate:;
			PNCLog( PNLOG_CAT_ICMP, @"kCFSocketCloseOnInvalidate:");
			break;
		default:
			break;
	}
}

@implementation PNICMPManager

- (id)init {
	self = [super init];
	if (self) {
		sock = CFSocketCreate(CFAllocatorGetDefault(), AF_INET, SOCK_DGRAM, IPPROTO_ICMP, 15, (CFSocketCallBack)&ICMPConnectionCallBack, NULL);
		CFRunLoopSourceRef source = CFSocketCreateRunLoopSource (
																 CFAllocatorGetDefault() ,
																 sock, 1);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), source, (CFStringRef)NSRunLoopCommonModes);
		if (!sock) {
			[self release];
			return nil;
		}
		requests = [[NSMutableArray alloc] init];
		
	}
	
	return self;
}


- (u_short)checkSum:(struct icmp *)icmp {
	
	int nleft = 64;
	u_short *w = (u_short *)icmp;
	int sum = 0;
	u_short answer = 0;
	
	/*
	 *  Our algorithm is simple, using a 32 bit accumulator (sum),
	 *  we add sequential 16 bit words to it, and at the end, fold
	 *  back all the carry bits from the top 16 bits into the lower
	 *  16 bits.
	 */
	while( nleft > 1 )  {
		sum += *w++;
		nleft -= 2;
	}
	
	/* mop up an odd byte, if necessary */
	if( nleft == 1 ) {
		*(u_char *)(&answer) = *(u_char *)w ;
		sum += answer;
	}
	
	/*
	 * add back carry outs from top 16 bits to low 16 bits
	 */
	sum = (sum >> 16) + (sum & 0xffff);	/* add hi 16 to low 16 */
	sum += (sum >> 16);			/* add carry */
	answer = ~sum;				/* truncate to 16 bits */
	return (answer);
	
}

- (void)sendRequest:(PNICMPRequest *)aReq {
	@synchronized (self) {
		[requests addObject:aReq];
		[[PNICMPManager sharedObject] sendBuffer];
	}
}

- (void)sendBuffer {
	
	@synchronized (self) {
	
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		if (!ICMPConnectionCanSendRequest) {
			PNCLog(PNLOG_CAT_ICMP, @"ICMP:Not yet write.");
			return;
		}
		
		if (![requests count]) {
			PNCLog(PNLOG_CAT_ICMP, @"Request cache is not found.");
			return;
		}

		PNICMPRequest* aReq = [[requests objectAtIndex:0] retain];
		[requests removeObjectAtIndex:0];
		
		PNCLog(PNLOG_CAT_ICMP, @"Sock Num:%d", CFSocketGetNative(sock));
		int s = CFSocketGetNative(sock);
//		PNCLog(PNLOG_CAT_ICMP, @"Set RSpace");
//		char rspace[40];	/* record route space */
//		memset(rspace,0,sizeof(rspace));
//		rspace[IPOPT_OPTVAL] = IPOPT_RR;
//		rspace[IPOPT_OLEN] = sizeof(rspace) - 1;
//		rspace[IPOPT_OFFSET] = IPOPT_MINOFF;
//		setsockopt(s, IPPROTO_IP, IP_OPTIONS, rspace, sizeof(rspace));
		PNCLog(PNLOG_CAT_ICMP, @"Set TTL");
		int ttl = MAXTTL; //MAXTTL = 255, IPDEFTTL = 64
		setsockopt(s, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));
		PNCLog(PNLOG_CAT_ICMP, @"Get Address:%@", [aReq address]);
		struct sockaddr_in aAddr = aReq.addr;
		PNCLog(PNLOG_CAT_ICMP, @"Get ICMP Structure");
		struct icmp icmp = aReq.icmp;
		icmp.icmp_cksum = [self checkSum:&icmp];
		PNCLog(PNLOG_CAT_ICMP, @"Sending ICMP...:%04x", icmp.icmp_id);
		
		sendto(s, (const char *)&icmp, 64, 0, (struct sockaddr*)&aAddr, sizeof(aAddr));
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:aReq forKey:@"Request"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ICMPManagerFinishSendRequest" object:self userInfo:userInfo];
		
		[aReq release];
		[pool release];
	}
	
	[self sendBuffer];
}


#pragma mark -
#pragma mark Singleton pattern

static PNICMPManager* _sharedInstance;
+ (PNICMPManager*)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init];
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;
}

- (void)release
{
}

- (id)autorelease
{
	return self;
}

@end
