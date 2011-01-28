#import "PNThreadManager.h"
#import "PNRunLoop.h"
#import "NSThread+ControllerExt.h"

#define kPNConnectionThreadKey @"UDPConnectionThread"


@implementation PNThreadManager

+(NSThread*)getConnectionThread
{
	NSThread* connectionThread = [[PNRunLoop getThreads] objectForKey:kPNConnectionThreadKey];
	if(!connectionThread) {
		connectionThread = [PNRunLoop createRunLoopWithKey:kPNConnectionThreadKey];
	}
	return connectionThread;
}

@end
