#import "PNDataModel.h"
#import "PNScoreModel.h"
#import "PNLeaderboard.h"

/**
 @brief Rankに関するJSONから作られる構造体
 */
@interface PNRankModel : PNDataModel {
	int						_value;
	int						_total;
	PNScoreModel*			_score;
	PNLeaderboardModel*		_leaderboard;
	BOOL					_is_ranked;
}

@property (assign, nonatomic) int value, total;
@property (retain, nonatomic) PNScoreModel *score;
@property (retain, nonatomic) PNLeaderboardModel *leaderboard;
@property (assign, nonatomic) BOOL is_ranked;

@end
