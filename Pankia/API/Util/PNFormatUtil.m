//
//  PNFormatUtil.m
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNFormatUtil.h"
#import "PNLocalizedString.h"
#import "PNItem.h"
#import "PNSKProduct.h"
#import "PNRank.h"
#import "PNLeaderboard.h"
#import "PNLeaderboardManager.h"
#import "PNParseUtil.h"
#import "PNGameManager.h"

@implementation PNFormatUtil

// 日付を経過時間で表示します。
// 60分以内 -> min表記
// 12h以内 -> h表記
// 48h以内 -> yesterday
// それ以降 -> 日付
+ (NSString*)timeElapsedSinceDate:(NSString*)dateStr
{
	NSDate* dateFromString = [PNParseUtil dateFromString:dateStr];
	
	float timeElapsed = -[dateFromString timeIntervalSinceNow];
	int elapsedMins = (int)round(timeElapsed / 60.0);
	if (elapsedMins <= 0) {
		return [NSString stringWithFormat:getTextFromTable(@"PNTEXT:UI:n_mins_ago"), 0];
	} else if (elapsedMins < 60) {
		return [NSString stringWithFormat:getTextFromTable(@"PNTEXT:UI:n_mins_ago"), elapsedMins];
	} else {
		int elapsedHours = elapsedMins / 60;
		if (elapsedHours < 12) {
			return [NSString stringWithFormat:getTextFromTable(@"PNTEXT:UI:n_hours_ago"), elapsedHours];
		} else if (elapsedHours < 48) {
			return getTextFromTable(@"PNTEXT:UI:Yesterday");
		} else {
			NSDateFormatter* outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[outputFormatter setDateFormat:@"yyyy/MM/dd"];
			return [outputFormatter stringFromDate:dateFromString];
		}
	}
}

+ (NSString*)priceFormat:(double)price locale:(NSString*)localeString
{
	NSString* formattedString;
	NSLocale* locale = [[NSLocale alloc] initWithLocaleIdentifier:localeString];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setCurrencyCode:localeString];
	formattedString = [formatter stringFromNumber:[NSNumber numberWithDouble:price]];
	[formatter release];
	[locale release];
	
	return formattedString;
}
+ (NSString*)priceOfProduct:(PNSKProduct*)product
{
	return [self priceFormat:[product.price floatValue] locale:[product.priceLocale objectForKey:NSLocaleCurrencyCode]];
}

+ (NSString*)quantityFormat:(PNItem *)item
{
	return item.maxQuantity == 1 ? @" " : [NSString stringWithFormat:@"%d", item.quantity];
}
+ (NSString*)trimSpaces:(NSString*)string
{
	NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSMutableArray *trimmedLines = [NSMutableArray array];
	int index=0;
	if (string == nil || [string isKindOfClass:[NSNull class]]) return @"";
	for (NSString* line in [string componentsSeparatedByString:@"\n"]) {
		NSString* trimmedString = [line stringByTrimmingCharactersInSet:charSet];
		if (index == 0 && [trimmedString length] <= 1) continue;
		[trimmedLines addObject:trimmedString];
		index++;
	}
	return [trimmedLines componentsJoinedByString:@"\n"];
}

+ (NSString*)stringWithComma:(int64_t)value
{
    NSNumber *number=[NSNumber numberWithLongLong:value];
    NSNumberFormatter *formatter=[[[NSNumberFormatter alloc] init] autorelease];
    [formatter setPositiveFormat:@"#,##0"];
    [formatter setNegativeFormat:@"-#,##0"];
    
    return [formatter stringForObjectValue:number];
}

+ (NSString*)stringRepresentationForRank:(PNRank*)rank
{
	// This can be implemented better as
	// PNLeaderboard* leaderboard = rank.leaderboard;
	// by adding readonly property to PNRank model.
//    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:rank.leaderboardId];
	NSArray* leaderboards = [[PNGameManager sharedObject] leaderboards];
	PNLeaderboard* leaderboard = nil;
	for (PNLeaderboard* aLeaderboard in leaderboards) {
		if (aLeaderboard.leaderboardId == rank.leaderboardId) {
			leaderboard = aLeaderboard;
			break;
		}
	}
	
	if (leaderboard == nil) return @"";
	
	if (leaderboard.format == kPNLeaderboardFormatInteger ){
		// TODO: Please insert comma
		return [NSString stringWithFormat:@"%@", [self stringWithComma:rank.score]];
	}
	else if (leaderboard.format == kPNLeaderboardFormatFloat1 ){
		// TODO: Please insert comma
		int64_t intger = rank.score/10;
		NSInteger decimal = rank.score%10;
		return [NSString stringWithFormat:@"%@.%d", [self stringWithComma:intger], decimal];
	}
	else if (leaderboard.format == kPNLeaderboardFormatFloat2 ){
		// TODO: Please insert comma
		int64_t intger = rank.score/100;
		NSInteger decimal = rank.score%100;
		return [NSString stringWithFormat:@"%@.%d", [self stringWithComma:intger], decimal];
	}
	else if (leaderboard.format == kPNLeaderboardFormatFloat3 ){
		// TODO: Please insert comma
		int64_t intger = rank.score/1000;
		NSInteger decimal = rank.score%1000;
		return [NSString stringWithFormat:@"%@.%d", [self stringWithComma:intger], decimal];
	}
	else if (leaderboard.format == kPNLeaderboardFormatElaspedTimeToMinute ){
		unsigned long minutes = rank.score;
		unsigned long hours = minutes / 60;
		minutes %= 60;		
		
		return [NSString stringWithFormat:@"%02d:%02d", hours, minutes ];
	}
	else if (leaderboard.format == kPNLeaderboardFormatElaspedTimeToSecond ){
		unsigned long seconds = rank.score;
		unsigned long minutes = seconds / 60;
		seconds %= 60;
		unsigned long hours = minutes / 60;
		minutes %= 60;
		
		return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
	}
	else if (leaderboard.format == kPNLeaderboardFormatElaspedTimeToTheHunsredthOfASecond ){
		unsigned long hseconds = rank.score;
		unsigned long seconds = hseconds/ 100;
		hseconds %= 1000;
		unsigned long minutes = seconds / 60;
		seconds %= 60;
		unsigned long hours = minutes / 60;
		minutes %= 60;
		
		return [NSString stringWithFormat:@"%02d:%02d:%02d.%02d", hours, minutes, seconds, hseconds];
	}
	else if (leaderboard.format == kPNLeaderboardFormatMoneyWholeNumbers ){
		// TODO: Please insert comma
		return [NSString stringWithFormat:@"%@", [self stringWithComma:rank.score]];
	}
	else if (leaderboard.format == kPNLeaderboardFormatMoneyTwoDecimals ){
		// TODO: Please insert comma
		int64_t intger = rank.score/100;
		NSInteger decimal = rank.score%100;
		return [NSString stringWithFormat:@"%@.%d", [self stringWithComma:intger], decimal];
	} 
	
	return @"--";
}

@end
