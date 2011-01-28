#import "JsonHelper.h"

@implementation JsonHelper

+ (BOOL)isValid:(id)json
{
	if (json == nil)
		return NO;
	
	NSDictionary *dic = [self parseJson:json];
	
	if (dic == nil)
		return NO;
	
	return YES;
}

+ (BOOL)isApiSuccess:(id)json
{
	if (![self isValid:json])
		return NO;
	
	NSDictionary *dic = [self parseJson:json];
	return ([[dic objectForKey:@"status"] isEqualToString:@"ok"]) ? YES : NO;
}

+ (BOOL)isApiFailure:(id)json
{
	if (![self isValid:json])
		return NO;
	
	NSDictionary *dic = [self parseJson:json];
	return ([[dic objectForKey:@"status"] isEqualToString:@"fail"]) ? YES : NO;
}

+ (NSDictionary*)parseJson:(id)json
{
	NSDictionary *dic;
	
	if ([json isKindOfClass:[NSString class]])
		dic = [json JSONValue];
	else if ([json isKindOfClass:[NSDictionary class]])
		dic = json;
	
	return dic; // => nil, when json was invalid
}

+ (NSMutableDictionary*)buildDoDictionary:(NSString*)json
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:json, @"do", @"ok", @"status", nil];
}

+ (NSData*)toData:(NSDictionary*)json
{
	NSString *str = [json JSONRepresentation];
	return [str dataUsingEncoding:NSUTF8StringEncoding];
}

@end
