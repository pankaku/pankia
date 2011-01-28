#import "PNRank.h"
#import "PNRank+Package.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNRankModel.h"
#import "PNUserModel.h"
#import "PNLeaderboard.h"
#import "PNLeaderboardModel.h"
#import "PNGlobal.h"

@implementation PNRank(Package)

@dynamic user;
@dynamic leaderboardId;
@dynamic rank;
@dynamic score;
@dynamic userCount;
@dynamic isRanked;

-(void)setUser:(PNUser *)arg { PNSETPROP(user,arg); }
-(void)setLeaderboardId:(int)arg { PNPSETPROP(leaderboardId,arg); }
-(void)setRank:(int)arg { PNPSETPROP(rank,arg); }
-(void)setScore:(long long int)arg { PNPSETPROP(score,arg); }
-(void)setUserCount:(int)arg { PNPSETPROP(userCount,arg); }
-(void)setIsRanked:(BOOL)arg { PNPSETPROP(isRanked,arg); }

-(PNUser*)user { PNGETPROP(PNUser*,user); }
-(int)leaderboardId { PNGETPROP(int,leaderboardId); }
-(int)rank { PNGETPROP(int,rank); }
-(long long int)score { PNGETPROP(long long int,score); }
-(int)userCount { PNGETPROP(int,userCount); }
-(BOOL)isRanked { PNGETPROP(BOOL,isRanked); }



- (id) initWithRankModel:(PNRankModel*)model
{
	if (self = [self init]){
		self.rank		= model.value;
		self.score		= model.score.value;
		if (model.score != nil) {
			if (model.score.user != nil) {
				self.user = [[[PNUser alloc] initWithUserModel:model.score.user] autorelease];
			}
		}
		if (model.leaderboard != nil) {
			self.leaderboardId = model.leaderboard.id;
		}
		self.userCount		= model.total;
		self.isRanked	= model.is_ranked;
	}
	return self;
	
}

- (id) initWithScoreModel:(PNScoreModel*)model
{
	if (self = [self init]){
		self.score		= model.value;
		if (model.user != nil) {
			self.user = [[[PNUser alloc] initWithUserModel:model.user] autorelease];
		}		
	}
	return self;			
}

@end


@implementation PNRank
@dynamic user;
@dynamic leaderboardId;
@dynamic rank;
@dynamic score;
@dynamic userCount;
@dynamic isRanked;

- (id) init
{
	if (self = [super init]) {
		self.user = [[[PNUser alloc] init] autorelease];
	}
	return self;
}

-(void)dealloc
{
	self.user				= nil;
	[super dealloc];
}


@end
