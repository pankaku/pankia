#import "PNICMPRequest.h"
#include <arpa/inet.h>
#import "PNLogger+Package.h"


@implementation PNICMPRequest

@synthesize icmp, addr, context;
@dynamic icmpType, icmpCode, identifier, sequence, address;

- (id)init {
	self = [super init];
	if (self) {
		memset(&icmp,0,sizeof(icmp));
		self.icmpType = ICMP_ECHO;
		addr.sin_family = AF_INET;
	}
	return self;
}

- (void)dealloc {
	[context release];
	[super dealloc];
}

- (u_char)icmpType {
	return icmp.icmp_type;
}

- (void)setIcmpType:(u_char)aChar {
	icmp.icmp_type = aChar;
}

- (u_char)icmpCode {
	return icmp.icmp_code;
}

- (void)setIcmpCode:(u_char)aChar {
	icmp.icmp_code = aChar;
}

- (n_short)identifier {
	return icmp.icmp_id;
}

- (void)setIdentifier:(n_short)aShort {
	icmp.icmp_id = aShort;
}

- (n_short)sequence {
	return icmp.icmp_seq;
}

- (void)setSequence:(n_short)aShort {
	icmp.icmp_seq = aShort;
}

- (NSString *)address {
	return [NSString stringWithFormat:@"%s", inet_ntoa(addr.sin_addr)];
}

- (void)setAddress:(NSString *)aString {
	addr.sin_addr.s_addr = inet_addr([aString cStringUsingEncoding:NSASCIIStringEncoding]);
	PNCLog(PNLOG_CAT_ICMP, @"Set Address:%s", inet_ntoa(addr.sin_addr));
}

@end
