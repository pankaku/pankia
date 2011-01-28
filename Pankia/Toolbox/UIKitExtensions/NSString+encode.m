#import "NSString+encode.h"

@implementation NSString(Encode)

-(NSString*)encodeEscape
{
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR (";,/?:@&=+$ #"), kCFStringEncodingUTF8) autorelease];
}

@end
