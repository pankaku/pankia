#import "PNRankModel.h"
#import "PNLeaderboardModel.h"

//Rank
#define kPNRankDefaultValue			-1
#define kPNRankDefaultTotal			-1
#define kPNRankDefaultScore			0
#define kPNRankDefaultRank			0

@implementation PNRankModel
@synthesize value = _value, total = _total, score = _score, leaderboard = _leaderboard, is_ranked = _is_ranked;

- (id) init{
	if (self = [super init]){
		self.value			= kPNRankDefaultValue;
		self.total			= kPNRankDefaultTotal;
		self.score			= nil;
		self.leaderboard	= nil;
		self.is_ranked		= kPNRankDefaultRank;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.value = [aDictionary intValueForKey:@"value" defaultValue:kPNRankDefaultValue];
		self.total = [aDictionary intValueForKey:@"total" defaultValue:kPNRankDefaultTotal];

		if ([aDictionary hasObjectForKey:@"score"]) {
			if ([[aDictionary objectForKey:@"score"] isKindOfClass:[NSDictionary class]]) {
				self.score = [[[PNScoreModel alloc] initWithDictionary:[aDictionary objectForKey:@"score"]] autorelease];				
			}
			else {
				self.score = kPNRankDefaultScore;				
			}
		}
		if ([aDictionary hasObjectForKey:@"leaderboard"]) {
				self.leaderboard = [[[PNLeaderboardModel alloc] initWithDictionary:[aDictionary objectForKey:@"leaderboard"]] autorelease];
		}
		
		self.is_ranked = [aDictionary intValueForKey:@"is_ranked" defaultValue:kPNRankDefaultRank];
		
				
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc{
	self.score			= nil;
	self.leaderboard	= nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n value:%d\n total:%d\n score:%p\n leaderboard:%p is_ranked:%d",
			NSStringFromClass([self class]),self,_value, _total, _score, _leaderboard, _is_ranked];
}
@end
