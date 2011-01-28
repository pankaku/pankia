
#import "PNNetworkError.h"

@implementation PNNetworkError

@synthesize requestId;
@synthesize status;
+(PNNetworkError*)error
{
	return [[[PNNetworkError alloc] init] autorelease];
}

@end
