#import "PNSessionRequestHelper.h"
#import "Helpers.h"
#import "PNLogger+Common.h"
#import "PNRequestKeyManager.h"
#import "PNHTTPRequestCacheManager.h"
#import "PNAPIHTTPDefinition.h"
#import "PNGlobalManager.h"
#import "PNHTTPDownload.h"
#import "PNGlobal.h"

#ifdef PNUsingExternalID
#import "PNExternalManager.h"
#endif

static const NSString* apiVersion = @"3";
static const NSString* osType = @"IOS";

@implementation PNSessionRequestHelper
+ (NSMutableDictionary*)paramsForAuthByDevice
{
	NSString* _gameKey = [PNGlobalManager sharedObject].gameKey;
	NSString* _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:_gameKey forKey:@"game_key"];
	
	[params setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
	
	//device language
	NSArray *languages = [NSLocale preferredLanguages];
	NSString *currentLanguage = [languages objectAtIndex:0];
	NSString* currencyLocale = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
	
	[params setObject:currentLanguage forKey:@"lang"];
	
	NSString* gameSecret = [PNGlobalManager sharedObject].gameSecret;
	
	//シークレットの生成
	NSMutableString *secret = [NSMutableString stringWithString:gameSecret];
	[secret appendString:[UIDevice currentDevice].uniqueIdentifier];
#ifdef PNUsingExternalID
	[secret appendString:[[PNExternalManager sharedObject] userId]];
#endif
	[params setObject:_version forKey:@"version"];
	[params setObject:[NSData sha1FromString:secret] forKey:@"verifier"];
	[params setObject:apiVersion forKey:@"api_version"];
	[params setObject:osType forKey:@"os"];
	[params setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
	[params setObject:[[UIDevice currentDevice] platform] forKey:@"hardware"];
	[params setObject:[[UIDevice currentDevice] name] forKey:@"nickname"];
	[params setObject:currencyLocale forKey:@"currency"];
	
#ifdef PNUsingExternalID
	[params setObject:[[PNExternalManager sharedObject] userId] forKey:@"external_id"];
#endif
	
	return params;
}
+ (NSMutableDictionary*)paramsForAuthByLoginID:(NSString*)_loginID password:(NSString*)_password
{
	//device language
	NSArray *languages = [NSLocale preferredLanguages];
	NSString *currentLanguage = [languages objectAtIndex:0];	
	NSString* _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:[PNGlobalManager sharedObject].gameKey forKey:@"game_key"];
	[params setObject:_loginID forKey:@"user"];
	[params setObject:_password forKey:@"password"];
	[params setObject:currentLanguage forKey:@"lang"];
	[params setObject:_version forKey:@"version"];
	[params setObject:apiVersion forKey:@"api_version"];
	return params;
}
+ (void) createSessionWithDelegate:(id)delegate selector:(SEL)selector{
	NSString *key = @"CreatedSession";
	[self createSessionWithDelegate:delegate selector:selector key:key];
}
+ (void) createSessionInFormerStyleWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)requestKey{

	
	return;
}
+ (void) createSessionWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)requestKey{
	NSDictionary* params = [self paramsForAuthByDevice];
	/*
	[[self class] requestWithCommand:kPNHTTPRequestCommandSessionCreate
						  parameters:params 
							delegate:delegate
							selector:selector callBackKey:requestKey];*/
	//NSString* requestURL = [PNHTTPRequestHelper createRequestString:kPNHTTPRequestCommandSessionCreate parameters:params];
	//[[PNHTTPRequestManager sharedObject] newRequestWithURL:requestURL delegate:delegate selector:selector object:requestKey];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandSessionCreate
								requestType:@"GET"
								  isMutable:NO 
								 parameters:params
								   delegate:delegate
								   selector:selector
								callBackKey:requestKey
									timeout:15.0f];
}
+ (void) switchAccountByUsername:(NSString*)username password:(NSString*)password delegate:(id)delegate selector:(SEL)selector key:(NSString*)requestKey{
	NSMutableDictionary *params = [self paramsForAuthByLoginID:username password:password];
	[[self class] requestWithCommand:kPNHTTPRequestCommandSessionCreateByPassword
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate 
							selector:selector 
						 callBackKey:requestKey];
}
+ (void) switchAccountByTwitterID:(NSString*)twitterId password:(NSString*)password
						 delegate:(id)delegate selector:(SEL)selector key:(NSString*)key
{
	NSMutableDictionary *params = [self paramsForAuthByLoginID:twitterId password:password];
	[[self class] requestWithCommand:kPNHTTPRequestCommandSessionCreateByTwitter 
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params 
							delegate:delegate
							selector:selector 
						 callBackKey:key];

}
+ (void) verifySession:(NSString*)session delegate:(id)delegate selector:(SEL)selector key:(NSString*)key
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:session forKey:@"session"];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandSessionVerify
								requestType:@"GET"
								  isMutable:NO
								 parameters:params 
								   delegate:delegate
								   selector:selector 
								callBackKey:key];
}
// BEGIN - lerry added code
+ (void) switchAccountByFacebookSessionKey:(NSString*)sessionKey 
									secret:(NSString*)secret
								  delegate:(id)delegate 
								  selector:(SEL)selector 
									   key:(NSString*)key
{
	NSMutableDictionary *params = [self paramsForAuthByDevice];
	[params setObject:sessionKey forKey:@"session_key"];
	[params setObject:secret forKey:@"session_secret"];
	[[self class] requestWithCommand:kPNHTTPRequestCommandSessionCreateByFacebook
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params 
							delegate:delegate
							selector:selector 
						 callBackKey:key];
}
// END - lerry added code
@end
