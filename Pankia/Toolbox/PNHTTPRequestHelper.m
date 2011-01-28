#import "PNHTTPRequestHelper.h"
#import "PNHTTPService.h"
#import "JsonHelper.h"
#import "NSString+encode.h"
#import "PNLogger.h"
#import "PNStandardLoggingConfig.h"
#import "PNGlobal.h"
#import "PNHTTPDownload.h"
#import "PNUser.h"
#import "PNUser+Package.h"

#pragma mark -- Implementation of PNHTTPRequestParams ---
@implementation PNHTTPRequestParams
@synthesize dictionary = dic;

- (id) init 
{
	if (self = [super init]) {
		dic = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey 
{
	[dic setObject:anObject forKey:aKey];
}

+ (PNHTTPRequestParams*)params:(NSString*)sessionId 
{
    PNHTTPRequestParams* p = [[[self alloc] init] autorelease];
    if (sessionId) {
        [p setObject:sessionId forKey:@"session"];
	}
    return p;
}

- (void) dealloc
{
	[dic release];
	dic = nil;
	[super dealloc];
}
@end

#pragma mark --- Implementation of PNHTTPRequestHelper ---
@interface PNHTTPRequestHelper (Private)
+ (NSString*)buildParameters:(NSDictionary*)params;
@end

@implementation PNHTTPRequestHelper

- (id) init 
{
	if (self = [super init]) {
	
	}
	return self;
}

+ (void)synchronousRequestWithCommand:(NSString*)command
						   parameters:(id)params 
{
	NSString *requestURL = [PNHTTPRequestHelper createRequestString:command
														 parameters:params];
	[PNHTTPService synchronousRequestWithURL:requestURL];
}

+(void)requestWithCommand:(NSString*)command
			  requestType:(NSString*)requestType
				isMutable:(BOOL)isMutable
			   parameters:(id)params
				 delegate:(id)delegate
				 selector:(SEL)selector
			  callBackKey:(NSString*)callBackKey
{
	[PNHTTPRequestHelper requestWithCommand:command
								requestType:requestType
								  isMutable:isMutable
								 parameters:params
								   delegate:delegate
								   selector:selector
								callBackKey:callBackKey
									timeout:kPNHTTPRequestTimeout];
}

+(void)requestWithCommand:(NSString*)command
			  requestType:(NSString*)requestType
				isMutable:(BOOL)isMutable
			   parameters:(id)params
				 delegate:(id)delegate
				 selector:(SEL)selector
			  callBackKey:(NSString*)callBackKey
				  timeout:(int)sec
{
	PNHTTPRequestHelper* helper = [[[[self class] alloc] init] autorelease];
	NSString *requestURL = [PNHTTPRequestHelper createRequestString:command
														 parameters:params];
	
	NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] init] autorelease];
	[userInfo setObject:delegate	forKey:@"delegate"];
	[userInfo setObject:helper		forKey:@"model"];
	[userInfo setObject:callBackKey	forKey:@"key"];
	[userInfo setObject:requestURL forKey:@"request_url"];
	[userInfo setObject:[NSValue valueWithPointer:selector] forKey:@"selector"];	
	
	PNCLog(PNLOG_CAT_POST_REQUEST, @"HELPER %@",NSStringFromClass([helper class]));
	PNCLog(PNLOG_CAT_POST_REQUEST, @"REQUEST : \n <---------- %@",requestURL);
	
	if([requestType isEqualToString:@"GET"]) {
		[PNHTTPService GETWithURL:requestURL
						 delegate:(id<PNServiceNotifyDelegate>)helper
						 userInfo:userInfo
						  timeout:sec
						isMutable:isMutable
		 ];
	} else if ([requestType isEqualToString:@"POST"]) {
		[PNHTTPService POSTWithURL:requestURL
						  delegate:(id<PNServiceNotifyDelegate>)helper
						  userInfo:userInfo
						   timeout:sec
						 isMutable:isMutable
		 ];
	} else {
		PNCLog(PNLOG_CAT_HTTP_REQUEST, @"Invalidate request type.(%@)",requestType);
	}
}

+ (NSString*)buildParameters:(NSDictionary*)params
{
	NSMutableString* s = [NSMutableString string];
	if (params) {
		NSEnumerator* e = [params keyEnumerator];
		NSString* key;
		while (key = (NSString*)[e nextObject]) {
			id value = [params objectForKey:key];
			if ([value isKindOfClass:[NSString class]]) {
				NSString* tmpValue = [params objectForKey:key];
				NSString* resValue = [tmpValue encodeEscape];				
				[s appendFormat:@"%@=%@&", key, resValue];
			}
			else {
				[s appendFormat:@"%@=%@&", key, value];
			}
		}
		if ([s length] > 0) [s deleteCharactersInRange:NSMakeRange([s length]-1, 1)];
	}
	return s;
}

+(NSString*)createRequestString:(NSString*)path parameters:(id)params
{
	return [self urlStringFromPath:path params:params];
}
+ (NSString*)urlStringFromPath:(NSString*)path params:(id)params
{
	NSMutableString *url = [NSMutableString stringWithString:kPNEndpointBase];
	[url appendString:path];
	[url appendString:@"?"];
	
	if ([params isKindOfClass:[NSString class]])
		[url appendString:[params encodeEscape]];
	else if ([params isKindOfClass:[NSDictionary class]])
		[url appendString:[PNHTTPRequestHelper buildParameters:params]];
	return url;
}
+ (void)requestWithCommand:(NSString*)command 
				 onSuccess:(void (^)(PNHTTPResponse*))onSuccess
				 onFailure:(void (^)(PNError* error))onFailure
{
	NSDictionary* params = [NSDictionary dictionaryWithObject:[PNUser currentUser].sessionId forKey:@"session"];
	[self requestWithCommand:command params:params onSuccess:onSuccess onFailure:onFailure];
}
+ (void)requestWithCommand:(NSString*)command params:(NSDictionary*)params 
				 onSuccess:(void (^)(PNHTTPResponse* response))onSuccess
				 onFailure:(void (^)(PNError* error))onFailure
{
	[PNHTTPDownload asyncDownloadFromURL:[self urlStringFromPath:command params:params] success:onSuccess failure:onFailure];
}
- (void) dealloc
{
	[super dealloc];
}

#pragma mark --- PNServiceNotifyDelegate Methods ---
- (void) notify:(NSString*)data userInfo:(id)userInfo
{
	NSMutableDictionary*	params		= userInfo;
	NSString*				key			= [params objectForKey:@"key"];
	NSString*				requestUrl	= [params objectForKey:@"request_url"];
	id						delegate	= [params objectForKey:@"delegate"];
	SEL						selector	= [[params objectForKey:@"selector"] pointerValue];
	
	PNHTTPResponse*			response	= [[[PNHTTPResponse alloc] initWithRequestURL:requestUrl Key:key andJson:data] autorelease];
	[delegate performSelector:selector withObject:response];
}

- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNWarn(@"PNHTTPRequestHelper error. %@ %d",error.message,error.errorType);
	
	NSMutableDictionary*	params		= userInfo;
	id						delegate	= [params objectForKey:@"delegate"];
	
	if([delegate respondsToSelector:@selector(error:userInfo:)]) {
		[delegate error:error userInfo:userInfo];
	}
}

@end
