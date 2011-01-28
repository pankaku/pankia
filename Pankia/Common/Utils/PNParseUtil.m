//
//  PNParseUtil.m
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNParseUtil.h"
#import "PNGlobalManager.h"
#import "NSDictionary+GetterExt.h"

@implementation PNParseUtil
+ (NSDate*)dateFromString:(NSString*)dateStr
{
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
    NSDate *dateFromString = [[[NSDate alloc] init] autorelease];
    dateFromString = [dateFormatter dateFromString:dateStr];
	
	return dateFromString;
}
+ (NSString*)localizedStringForKey:(NSString*)key inDictionary:(NSDictionary*)dictionary 
					  defaultValue:(NSString*)defaultValue
{
	NSString* primaryLanguage = [[PNGlobalManager sharedObject] preferedLanguage];
	NSString* secondaryLanguage = @"en";
	
	NSDictionary *dictionaryForLanguage = nil;
	dictionaryForLanguage = [dictionary objectForKey:primaryLanguage];
	if (dictionaryForLanguage == nil) dictionaryForLanguage = [dictionary objectForKey:secondaryLanguage];
	if (dictionaryForLanguage == nil) {
		NSArray* keys = [dictionary allKeys];
		if ([keys count] > 0){
			dictionaryForLanguage = [dictionary objectForKey:[keys objectAtIndex:0]];
		}
	}
	
	if (dictionaryForLanguage != nil) {
		return [dictionaryForLanguage stringValueForKey:key defaultValue:defaultValue];
	} else {
		return defaultValue;
	}
}
@end
