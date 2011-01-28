#import "PNLeaderboard.h"
#import "PNLeaderboardModel.h"
#import "NSString+VersionString.h"
#import "PNParseUtil.h"

@interface PNLeaderboard (Private)
- (void) setFormatFromJSONValue:(NSString*)jsonValue;
@end


@implementation PNLeaderboard
@synthesize leaderboardId,name,type,sortBy,scoreBase,format;

- (int)id 
{
	return leaderboardId;
}
- (id)init
{
	if (self = [super init]) {
		self.format = kPNLeaderboardFormatInteger;
		self.type = @"custom";
	}
	return self;
}

- (id)initWithLocalDictionary:(NSDictionary*)dictionary {
	PNLogMethodName;
	if (self = [self init]) {
		self.leaderboardId = [dictionary intValueForKey:@"id" defaultValue:0];
		self.name = [PNParseUtil localizedStringForKey:@"name" inDictionary:[dictionary objectForKey:@"translations"] 
										  defaultValue:@"-"];
		[self setSortByWithString:[dictionary objectForKey:@"sort_by"]];
		[self setFormatFromJSONValue:[dictionary stringValueForKey:@"parser" defaultValue:@""]];
	}
	return self;
}

- (id) initWithDataModel:(PNDataModel *)dataModel {
	PNLogMethodName;
	if (self = [super initWithDataModel:dataModel]){
		PNLeaderboardModel* model = (PNLeaderboardModel*)dataModel;
		self.leaderboardId = model.id;
		self.name = model.name;
		self.type = model.type;		
		self.scoreBase = model.score_base;
		
		[self setSortByWithString:model.sort_by];	
		[self setFormatFromJSONValue:model.format];
	}
	return self;
}
- (id) initWithLeaderboardModel:(PNLeaderboardModel*)model {
	PNLogMethodName;
	return [self initWithDataModel:model];
}

- (void) setSortByWithString:(NSString*)stringValue {
	PNLogMethodName;
	if ([stringValue isEqualToString:@"latest"]) {
		self.sortBy = kPNSortByLatest;
	} else if ([stringValue isEqualToString:@"min"]) {
		self.sortBy = kPNSortByMinimum;
	} else if ([stringValue isEqualToString:@"max"]) {
		self.sortBy = kPNSortByMaximum;
	} else {
		self.sortBy = kPNUndefined;
	}
}

- (void) setFormatFromJSONValue:(NSString*)jsonValue {
	PNLogMethodName;
	if ([jsonValue isEqualToString:@"decimal_1"]) {
		self.format = kPNLeaderboardFormatFloat1;
	} else if ([jsonValue isEqualToString:@"decimal_2"]) {
		self.format = kPNLeaderboardFormatFloat2;
	} else if ([jsonValue isEqualToString:@"decimal_3"]) {
		self.format = kPNLeaderboardFormatFloat3;
	} else if ([jsonValue isEqualToString:@"time_min"]) {
		self.format = kPNLeaderboardFormatElaspedTimeToMinute;
	} else if ([jsonValue isEqualToString:@"time_sec"]) {
		self.format = kPNLeaderboardFormatElaspedTimeToSecond;
	} else if ([jsonValue isEqualToString:@"time_centisec"]) {
		self.format = kPNLeaderboardFormatElaspedTimeToTheHunsredthOfASecond;
	} else if ([jsonValue isEqualToString:@"money"]) {
		self.format = kPNLeaderboardFormatMoneyWholeNumbers;
	} else if ([jsonValue isEqualToString:@"money_decimal_2"]) {
		self.format = kPNLeaderboardFormatMoneyTwoDecimals;
	} else {
		self.format = kPNLeaderboardFormatInteger;
	}
}

- (NSComparisonResult)compareId:(PNLeaderboard *)leaderboard {
	PNLogMethodName;
	if (self.leaderboardId > leaderboard.leaderboardId ){
		return NSOrderedDescending;
	} else if (self.leaderboardId < leaderboard.leaderboardId){
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

- (void)dealloc {
	PNLogMethodName;
	self.name				= nil;
	self.type				= nil;
	
	[super dealloc];
}

@end
