#import "NSString+VersionString.h"


@implementation NSString(VersionString)

/**
 1.23.45等の表記を12345のような形のintに変換して返します。
 想定される動作
 1.00.00 -> 10000
 1.1.3 -> 10103
 10.01.01 -> 100101
 */
- (int)versionIntValue
{
	NSArray *components = [self componentsSeparatedByString:@"."];
	if (self == nil || [self isEqualToString:@""] || components == nil){
		return -1;
	}
	
	NSString *majorString, *minorString, *revisionString;
	switch ([components count]) {
		case 2:	// ex 1.23
			majorString = [components objectAtIndex:0];
			minorString = [components objectAtIndex:1];
			revisionString = @"0";
			break;
		case 3:	// ex.1.23.45
			majorString = [components objectAtIndex:0];
			minorString = [components objectAtIndex:1];
			revisionString = [components objectAtIndex:2];
			break;
		default:
			return -1;
			break;
	}
	
	@try {
		int majorInt = [majorString intValue];
		int minorInt = [minorString intValue];
		int revisionInt = [revisionString intValue];
		return revisionInt + minorInt * 100 + majorInt * 10000;
	}
	@catch (NSException * e) {
		return -1;
	}
	
	return -1;	//本来ここに達するべきではありません
}
@end
