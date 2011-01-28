#import "PNHTTPRequestHelper.h"

@interface PNSessionRequestHelper : PNHTTPRequestHelper {

}
+ (NSMutableDictionary*)paramsForAuthByDevice;
+ (NSMutableDictionary*)paramsForAuthByLoginID:(NSString*)_loginID password:(NSString*)_password;
+ (void) createSessionWithDelegate:(id)delegate selector:(SEL)selector;
+ (void) createSessionWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void) createSessionInFormerStyleWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void) switchAccountByUsername:(NSString*)username password:(NSString*)password
						delegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void) switchAccountByTwitterID:(NSString*)twitterId password:(NSString*)password
						delegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void) verifySession:(NSString*)session delegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
// BEGIN - lerry added code
+ (void) switchAccountByFacebookSessionKey:(NSString*)sessionKey 
									secret:(NSString*)secret
								  delegate:(id)delegate 
								  selector:(SEL)selector 
									   key:(NSString*)key;
// END - lerry added code
@end
