#import "JSON.h"

@interface JsonHelper : NSObject

+ (BOOL)isValid:(id)json;
+ (BOOL)isApiSuccess:(id)json;
+ (BOOL)isApiFailure:(id)json;
+ (NSDictionary*)parseJson:(id)json;
+ (NSMutableDictionary*)buildDoDictionary:(NSString*)json;
+ (NSData*)toData:(id)json;

@end
