#include "ip.h"
#include "ip_icmp.h"

@interface PNICMPRequest : NSObject {
	struct icmp icmp;
	struct sockaddr_in addr;
	id context;
}
@property (assign, nonatomic) struct icmp icmp;
@property (assign, nonatomic) u_char icmpType;
@property (assign, nonatomic) u_char icmpCode;
@property (assign, nonatomic) n_short identifier;
@property (assign, nonatomic) n_short sequence;
@property (assign, nonatomic) struct sockaddr_in addr;
@property (assign, nonatomic) NSString* address;
@property (retain, nonatomic) id context;

@end
