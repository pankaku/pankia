/*! \brief LeaderboardのHTTP通信の補助をするクラスです。
 *
 * Leaderboardへの得点の送信、各ユーザのランキング情報、Leaderboadのランキング取得のHTTP通信の補助をします。
 * 
 */
#import "PNHTTPRequestHelper.h"
#import "PNNetworkError.h"

@interface PNLeaderboardRequestHelper : PNHTTPRequestHelper {
}

+(void)scoresInLeaderboard:(int)leaderboard
	   period:(NSString*)period
		among:(NSString*)among
	   offset:(int)offset
		limit:(int)limit
	  reverse:(NSString*)reverse
	 delegate:(id)delegate
	 selector:(SEL)selector
   requestKey:(NSString*)key;

+(void)rankInLeaderboard:(int)leaderboard
	   user:(NSString*)user
	 period:(NSString*)period
	  among:(NSString*)among
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key;

+(void)rankInLeaderboards:(NSString*)leaderboardIds
	   user:(NSString*)user
	 period:(NSString*)period
	  among:(NSString*)among
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key;

+(void)latestScoreOnLeaderboards:(NSArray*)leaderboardIds
						delegate:(id)delegate
						selector:(SEL)selector
					  requestKey:(NSString*)key;

+(void)postScore:(long long int)score
leaderboard:(int)leaderboard
	  delta:(BOOL)delta
	 period:(NSString*)period
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key;

+(void)leaderboardsWithDelegate:(id)delegate
		   selector:(SEL)selector
		 requestKey:(NSString*)key;

@end
