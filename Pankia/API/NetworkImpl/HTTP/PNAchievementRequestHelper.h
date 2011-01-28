#import "PNHTTPRequestHelper.h"
#import "PNNetworkError.h"
#import "PNAchievement.h"

@protocol PNAchievementRequestHelperDelegate;

/**
 @brief AchievementのHTTP通信を補助するクラスです。
 
 Achievementの取得、アンロック、などを行うHTTP通信の補助クラスです。
 */
@interface PNAchievementRequestHelper : PNHTTPRequestHelper {
}

+ (void)getAchievementsWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
+ (void)unlockAchievements:(NSArray*)achievements delegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
@end

