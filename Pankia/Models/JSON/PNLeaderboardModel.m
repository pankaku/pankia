#import "PNLeaderboardModel.h"

//Leaderboard
#define kPNLeaderboardDefaultID					-1
#define kPNLeaderboardDefaultScoreBase			-1
#define kPNLeaderboardDefaultName				@""
#define kPNLeaderboardDefaultType				@""
#define kPNLeaderboardDefaultSort				@""
#define kPNLeaderboardDefaultOldestVersion		@"0.0.0"
#define kPNLeaderboardDefaultLatestVersion		@"9999.99.99"
#define kPNLeaderboardDefaultFormat				@"integer"

@implementation PNLeaderboardModel
@synthesize id = _id, score_base = _score_base;
@synthesize name = _name, type = _type , sort_by = _sort_by;
@synthesize min_version = _min_version, max_version = _max_version, format = _format;

- (id)init {
	PNLogMethodName;
	if (self = [super init]) {
		self.id = kPNLeaderboardDefaultID;
		self.score_base = kPNLeaderboardDefaultScoreBase;
		self.name = kPNLeaderboardDefaultName;
		self.type = kPNLeaderboardDefaultType;
		self.sort_by = kPNLeaderboardDefaultSort;
		self.min_version = kPNLeaderboardDefaultOldestVersion;
		self.max_version = kPNLeaderboardDefaultLatestVersion;
		self.format = kPNLeaderboardDefaultFormat;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary {
	PNLogMethodName;
	if (self = [super initWithDictionary:aDictionary]) {
		self.id = [aDictionary intValueForKey:@"id" defaultValue:kPNLeaderboardDefaultID];
		self.score_base = [aDictionary intValueForKey:@"score_base" defaultValue:kPNLeaderboardDefaultScoreBase];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:kPNLeaderboardDefaultName];
		self.type = [aDictionary stringValueForKey:@"type" defaultValue:kPNLeaderboardDefaultType];
		/*
		if(![[aDictionary objectForKey:@"type"] isKindOfClass:[NSNull class]]){
			self.type = [aDictionary objectForKey:@"type"];
		}else {
			self.type = @"";
		}*/
		self.sort_by = [aDictionary stringValueForKey:@"sort_by" defaultValue:kPNLeaderboardDefaultSort];
		self.min_version = [aDictionary stringValueForKey:@"min_version" defaultValue:kPNLeaderboardDefaultOldestVersion];
		self.max_version = [aDictionary stringValueForKey:@"max_version" defaultValue:kPNLeaderboardDefaultLatestVersion];
		self.format = [aDictionary stringValueForKey:@"parser" defaultValue:kPNLeaderboardDefaultFormat];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc {
	PNLogMethodName;
	self.name			= nil;
	self.type			= nil;
	self.sort_by		= nil;
	self.min_version	= nil;
	self.max_version	= nil;
	self.format			= nil;
	[super dealloc];

}

- (NSString*)description {
	PNLogMethodName;
	return [NSString stringWithFormat:@"<%@ :%p>\n id:%d\n score_base:%d\n name:%@\n type:%@\n sort_by:%@\n min_version:%@\n max_version:%@\n format:%@",
			NSStringFromClass([self class]),self,_id, _score_base, _name, _type, _sort_by, _min_version, _max_version, _format];
}

@end
