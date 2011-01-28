#import "NSData+Utils.h"

@implementation NSData (NSData_HexAdditions)
- (NSString*) stringWithHexBytes {
	NSMutableString *stringBuffer = [NSMutableString
									 stringWithCapacity:([self length] * 2)];
	const unsigned char *dataBuffer = [self bytes];
	int i;
	
	for (i = 0; i < [self length]; ++i)
		[stringBuffer appendFormat:@"%02x", (unsigned long)dataBuffer[ i ]];
	
	return [[stringBuffer copy] autorelease];
}

+ (NSString*) sha1FromData:(NSData*)data
{
	return [NSData sha1FromString:[NSString stringWithCString:(const char*)[data bytes] encoding:NSUTF8StringEncoding]];
}

+ (NSString*) sha1FromString:(NSString*)string
{
	unsigned char hashedChars[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1([string UTF8String],
			[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
			hashedChars);
	NSData *hashedData = [NSData dataWithBytes:hashedChars length:CC_SHA1_DIGEST_LENGTH];
	NSData *tmp = [[NSData alloc] initWithData:hashedData];
	NSString *ret = [tmp stringWithHexBytes];
	[tmp release];
	return ret;
}

@end
