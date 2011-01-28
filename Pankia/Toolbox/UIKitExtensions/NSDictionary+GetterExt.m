#import "NSDictionary+GetterExt.h"


@implementation NSDictionary(GetterExt)

- (int) intValueForKey:(NSString*)key defaultValue:(int)defaultValue{
	id object = [self objectForKey:key];
	if (object == nil || [object isKindOfClass: [NSNull class]] || ![object respondsToSelector:@selector(intValue)]){
		return defaultValue;
	}else{
		return [object intValue];
	}
}
- (int64_t) longLongValueForKey:(NSString*)key defaultValue:(int64_t)defaultValue
{
	id object = [self objectForKey:key];
	if (object == nil || [object isKindOfClass: [NSNull class]] || ![object respondsToSelector:@selector(longLongValue)]){
		return defaultValue;
	}else{
		return [object longLongValue];
	}
}
- (float) floatValueForKey:(NSString*)key defaultValue:(float)defaultValue
{
	id object = [self objectForKey:key];
	if (object == nil || [object isKindOfClass: [NSNull class]] || ![object respondsToSelector:@selector(floatValue)]){
		return defaultValue;
	}else{
		return [object floatValue];
	}
}
- (BOOL) boolValueForKey:(NSString*)key defaultValue:(BOOL)defaultValue{
	id object = [self objectForKey:key];
	if (object == nil || [object isKindOfClass: [NSNull class]] || ![object respondsToSelector:@selector(boolValue)]){
		return defaultValue;
	}else{
		return [object boolValue];
	}
}
- (NSString*) stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultValue{
	id object = [self objectForKey:key];
	if (object == nil || [object isKindOfClass: [NSNull class]] || ![object isKindOfClass:[NSString class]]){
		if ([object isKindOfClass:[NSDecimalNumber class]] || [object isKindOfClass:[NSNumber class]]) {
			return [NSString stringWithFormat:@"%d",object];
		}
		return defaultValue;
	}else{
		return (NSString*)object;
	}
}

- (BOOL) hasObjectForKey:(NSString*)key{
	id object = [self objectForKey:key];
	if (object == nil || [object isKindOfClass: [NSNull class]]){
		return NO;
	}else{
		return YES;
	}
}
@end
