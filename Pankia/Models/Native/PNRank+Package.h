
@class PNRankModel;
@class PNScoreModel;

@interface PNRank(Package)

@property (retain) PNUser*			user;
@property (assign) int				leaderboardId;
@property (assign) int				rank;
@property (assign) long long int	score;
@property (assign) int				userCount;
@property (assign) BOOL				isRanked;

- (id) initWithRankModel:(PNRankModel*)model;
- (id) initWithScoreModel:(PNScoreModel*)model;

@end
