
#import "PNAchievement.h"

//アチーブメントの再送の理由を表す定数
#define kPNAchievementUnlockRetryReasonNone			0
#define kPNAchievementUnlockRetryReasonNotFound		1
#define kPNAchievementUnlockRetryReasonUnknown		2

@class PNManager;
@class PNAchievementManager;
@class PNAchievementModel;

struct sqlite3;
typedef struct sqlite3 sqlite3;

@interface PNAchievement(Package)

@property (assign) int        achievementId;
@property (retain) NSString*  title;
@property (retain) NSString*  description;
@property (assign) NSUInteger value;
@property (retain) NSString*  iconUrl;
@property (assign) BOOL       isSecret;
@property (assign) BOOL       isUnlocked;
@property (assign) int		orderNumber;

- (id)initWithAchievementModel:(PNAchievementModel*)model;
- (id)initWithAchievementId:(int)_achievementId;
- (id)initWithLocalDictionary:(NSDictionary*)dictionary;
@end

/**
 ローカルでアチーブメント達成状況を管理するクラスです
 */
@interface PNLocalAchievementDB : NSObject {
}
+ (PNLocalAchievementDB *)sharedObject;
- (void)unlockAchievement:(int)achievementId;
- (void)unlockAchievement:(int)achievementId delegate:(id)delegate userId:(int)userId;
- (BOOL)isAchievementUnlocked:(int)achievementId userId:(int)userId;
- (void)syncWithServer;
- (void)syncWithServerWithArray:(NSArray*)achievementArray;
- (void)clearAll;
- (int)unlockedPointsOfUser:(int)userId;
- (NSArray*)unlockedAchievementIdsOfUser:(int)userId;
- (void)incrementRetryCountById:(int)achievementId;
- (void)setRetryReasonCode:(int)retryReasonCode achievementId:(int)achievementId;
- (void)unlockAchievementWithoutNotification:(int)achievementId byUser:(int)userId;

//古いバージョンからのマイグレーションに必要なメソッド群
- (NSArray*)unlockedAchievementIdsVersion1;

@end
