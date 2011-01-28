
@interface NSDictionary(GetterExt)

- (int) intValueForKey:(NSString*)key defaultValue:(int)defaultValue;
- (BOOL) boolValueForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
- (NSString*) stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultValue;
- (int64_t) longLongValueForKey:(NSString*)key defaultValue:(int64_t)defaultValue;
- (BOOL) hasObjectForKey:(NSString*)key;
- (float) floatValueForKey:(NSString*)key defaultValue:(float)defaultValue;
@end
