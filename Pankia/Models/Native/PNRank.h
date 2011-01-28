@class PNUser;

/**
 @brief Rank情報をゲーム側に受け渡すための構造体です。
 
 LeaderboardのRank情報が格納されます。
 */
@interface PNRank : NSObject {
	PNUser*			user;
	int				leaderboardId;
	int				rank;		
	long long int	score;
	int				userCount;
	BOOL			isRanked;
}

@property (retain,readonly) PNUser*			user;
@property (assign,readonly) int				leaderboardId;
@property (assign,readonly) int				rank;
@property (assign,readonly) long long int	score;
@property (assign,readonly) int				userCount;
@property (assign,readonly) BOOL			isRanked;

@end
