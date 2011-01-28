#import "PNValidation.h"
#import "OnigRegexp.h"

@implementation PNValidation

+(BOOL)isEmpty:(NSString*)text
{
	return text ? (text.length?NO:YES) : YES;
}

+(BOOL)isEqualToStrings:(NSString*)str :(NSString*)_str
{
	return [str isEqualToString:_str];
}

+(BOOL)isIncludedSpace:(NSString*)text
{
	OnigRegexp*	e = [OnigRegexp compile:@"^[^ 　]*$"];
	OnigResult*	r = [e search:text];
	
	if ([r count] > 0) {
		return NO;
	}
	
	return YES;	
}

+(BOOL)isMaxLength:(NSString*)text maxLength:(NSUInteger)max
{
	return text ? (text.length <= max?NO:YES) :YES;
}

+(BOOL)isLegalUserName:(NSString*)text
{
	
	OnigRegexp*	e = [OnigRegexp compile:@"^[a-zA-Z0-9][a-zA-Z0-9_.¥-]*[a-zA-Z0-9]$"];
	OnigResult*	r = [e search:text];
	
	if ([r count] > 0) {
		return YES;
	}
	
	return NO;	
}

@end
