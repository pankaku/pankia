#define kPNLeaderboardPeriodOverall				0
#define kPNLeaderboardPeriodMonthly				1
#define kPNLeaderboardPeriodDaily				2
#define kPNLeaderboardTypeGrade					@"grade"
#define kPNLeaderboardTypeCustom				@"custom"
#define kPNLeaderboardMaxRetryCount				6
#define kPNLeaderboardMaxRetryInterval			60

typedef enum {
	PNLeaderboardRankAmongWorld,
	PNLeaderboardRankAmongFriends
} PNLeaderboardRankAmongType;


@class PNError;
@class PNLeaderboard;
@class PNRank;

/**
 @brief This class provides leaderboard related functions.
 */
@interface PNLeaderboardManager : NSObject {
	NSArray* leaderboardsFromPlist;
	NSDictionary* gameCenterLeaderBoards;
}
@property (nonatomic, retain) NSArray* leaderboardsFromPlist;
@property (retain) NSDictionary* gameCenterLeaderBoards;

+ (PNLeaderboardManager *)sharedObject;

+ (PNLeaderboard*)leaderboardById:(int)leaderboardId;

- (void)getLatestScoreOnLeaderboards:(NSArray*)leaderboardIds
						   onSuccess:(void (^)(NSArray *scores)) onSuccess onFailure:(void (^)(PNError *error))onFailure;
- (void)getScoresOnLeaderboard:(int)leaderboardId among:(NSString*)among period:(NSString*)period offset:(int)offset
					 onSuccess:(void (^)(NSArray *)) onSuccess onFailure:(void (^)(PNError *))onFailure;
- (void)getRankOnLeaderboard:(int)leaderboardId username:(NSString *)username period:(NSString *)period among:(PNLeaderboardRankAmongType)among
				   onSuccess:(void (^)(PNRank *)) onSuccess onFailure:(void (^)(PNError *))onFailure;
- (void)getRankOnLeaderboards:(NSArray*)leaderboardIdArray username:(NSString *)username period:(NSString *)period among:(PNLeaderboardRankAmongType)among
							   onSuccess:(void (^)(NSArray *)) onSuccess onFailure:(void (^)(PNError *))onFailure;
#pragma mark GameCenter
- (void)postScoreToGameCenter:(int64_t)score leaderboardId:(int)leaderboardId;
@end

