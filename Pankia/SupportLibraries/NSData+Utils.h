// Taken from https://www.devonferns.com/cocoablog/?p=47

#import <CommonCrypto/CommonDigest.h>

@interface NSData (NSData_HexAdditions)
- (NSString*) stringWithHexBytes;
+ (NSString*) sha1FromData:(NSData*)data;
+ (NSString*) sha1FromString:(NSString*)string;

@end
