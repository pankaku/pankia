#import "PNAPIHTTPDefinition.h"
#import "PNServiceNotifyDelegate.h"
#import "PNHTTPResponse.h"
#import "PNHTTPService.h"

@class PNError;

@interface PNHTTPRequestParams : NSObject
{
	NSMutableDictionary *dic;
}

@property (retain) NSDictionary* dictionary;

- (void)setObject:(id)anObject forKey:(id)aKey;
+ (PNHTTPRequestParams*)params:(NSString*)sessionId;
@end


@interface PNHTTPRequestHelper : NSObject <PNServiceNotifyDelegate> {
}

+ (void)synchronousRequestWithCommand:(NSString*)command
						   parameters:(id)params;

+ (void)requestWithCommand:(NSString*)command
			   requestType:(NSString*)requestType
				 isMutable:(BOOL)isMutable
				parameters:(id)params
				  delegate:(id)delegate
				  selector:(SEL)selector
			   callBackKey:(NSString*)callBackKey;

+ (void)requestWithCommand:(NSString*)command
			  requestType:(NSString*)requestType
				isMutable:(BOOL)isMutable
			   parameters:(id)params
				 delegate:(id)delegate
				 selector:(SEL)selector
			  callBackKey:(NSString*)callBackKey
				  timeout:(int)sec;

+ (NSString*)createRequestString:(NSString*)path parameters:(id)params;

+ (NSString*)urlStringFromPath:(NSString*)path params:(id)params;
+ (void)requestWithCommand:(NSString*)command params:(NSDictionary*)params 
				 onSuccess:(void (^)(PNHTTPResponse* response))onSuccess
				 onFailure:(void (^)(PNError* error))onFailure;
+ (void)requestWithCommand:(NSString*)command 
				 onSuccess:(void (^)(PNHTTPResponse* response))onSuccess
				 onFailure:(void (^)(PNError* error))onFailure;

@end
