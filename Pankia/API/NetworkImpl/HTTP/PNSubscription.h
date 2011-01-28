#import "PNHTTPRequestHelper.h"

@interface PNSubscription : PNHTTPRequestHelper {
}

+(void) add:(NSString*)session
	  topic:(NSString*)topic
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key;
+(NSString*)createTopic:(NSString*)command
				  param:(NSString*)param;

@end

