#import "PNICMPRequest.h"

@interface PNICMPManager : NSObject {
	CFSocketRef sock;
	NSMutableArray* requests;
}

- (unsigned short)checkSum:(struct icmp *)icmp;
- (void)sendRequest:(PNICMPRequest *)aReq;

+ (PNICMPManager*)sharedObject;

@end
