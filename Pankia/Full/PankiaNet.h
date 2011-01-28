#import "PankiaNetworkLibrary.h"

#import "PNExtendedAppDelegate.h"
@protocol PankiaNetDelegate;

/**
 @brief PankiaNetの基本となるクラスです。
 
 基本となるクラスです。ダッシュボードの起動などはこのクラスを通じて行えます。このクラスはシングルトンです。
 */
@interface PankiaNet : NSObject<PNAppDelegateProtocol, PNManagerDelegate, PNManagerNotifyDelegate, UIApplicationDelegate> {
@private
	id<PankiaNetDelegate>	pankiaNetDelegate;
}

@property (retain)	id<PankiaNetDelegate>		pankiaNetDelegate;

+ (void)initWithGameKey:(NSString*)gameKey
			 gameSecret:(NSString*)secret
				  title:(NSString*)title
			   delegate:(id<PankiaNetDelegate>)delegate
				options:(NSDictionary*)options;
+ (BOOL)isLoggedIn;

//etc.
+ (BOOL)isTwitterLinked;
+ (void)followUserByName:(NSString*)username;
+ (void)postTweet:(NSString*)tweet onSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure;

+ (void)setInternetMatchMinRoomMember:(int)minMember;
+ (void)setInternetMatchMaxRoomMember:(int)maxMember;
+ (void)setNearbyMatchMinRoomMember:(int)minMember;
+ (void)setNearbyMatchMaxRoomMember:(int)maxMember;

+ (void)applicationWillEnterForeground:(UIApplication *)application;
+ (void)applicationDidEnterBackground:(UIApplication *)application;
@end

@interface PankiaNet(Dashboard)
+ (UIInterfaceOrientation)dashboardOrientation;
+ (void)dismissDashboard;
+ (void)launchDashboard;
+ (void)launchDashboardWithURL:(NSString*)url;
+ (void)launchDashboardWithLeaderboardsView;
+ (void)launchDashboardWithAchievementsView;
+ (void)launchDashboardWithFindFriendsView;
+ (void)launchDashboardWithNearbyMatchView;
+ (void)launchDashboardWithInternetMatchView;
+ (void)launchDashboardWithSettingsView;
+ (void)launchDashboardWithEditProfileView;
+ (void)launchDashboardWithSecureAccountView;
+ (void)launchDashboardWithSwitchAccountView;
+ (void)launchDashboardWithMyProfileView;
+ (void)launchDashboardWithUsersProfileView:(NSString*)username;
+ (void)launchDashboardWithInvitedRoomsView;
+ (void)launchDashboardWithInternetMatchRoom:(PNRoom*)room;
+ (void)launchDashboardWithLinkWithTwitterView;
+ (void)launchDashboardWithItemDetailView:(int)itemId;
+ (void)launchDashboardWithMerchandiseDetailView:(NSString*)identifier;
+ (void)setDashboardOrientation:( UIInterfaceOrientation)orientation;
+ (void)setSideMenuEnabled:(BOOL)enabled;
@end

@interface PankiaNet(Achievements)
+ (NSArray*)achievements;
+ (NSArray*)unlockedAchievements;

+ (void)unlockAchievement:(int)achievementId;
+ (void)unlockAchievements:(NSArray*)achievementsToUnlock;
+ (BOOL)isAchievementUnlocked:(int)achievementId;
@end

@interface PankiaNet(Items)
+ (int64_t)acquireItem:(int)itemId quantity:(int64_t)quantity error:(PNError**)error;
+ (int64_t)consumeItem:(int)itemId quantity:(int64_t)quantity error:(PNError**)error;
+ (int64_t)quantityOfItem:(int)itemId;
@end

@interface PankiaNet(Leaderboards)
+ (NSArray*)leaderboards;

+ (void)fetchRankOnLeaderboard:(int)leaderboardId onSuccess:(void (^)(PNRank* rank))onSuccess onFailure:(void (^)(PNError* error))onFailure;
+ (void)fetchAllLeaderboardsRankWithOnSuccess:(void (^)(NSArray* ranks))onSuccess onFailure:(void (^)(PNError* error))onFailure;
+ (void)fetchLatestLeaderboardsScore:(NSArray*)leaderboardIds onSuccess:(void (^)(NSArray* scores))onSuccess onFailure:(void (^)(PNError* error))onFailure;

+ (int64_t)postScore:(int64_t)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental;
+ (int64_t)postScore:(int64_t)score leaderboardId:(int)leaderboardId;
+ (float)postFloatScore:(float)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental;
+ (float)postFloatScore:(float)score leaderboardId:(int)leaderboardId;
+ (NSTimeInterval)postTimeScore:(NSTimeInterval)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental;
+ (NSTimeInterval)postTimeScore:(NSTimeInterval)score leaderboardId:(int)leaderboardId;
+ (int64_t)postMoneyScore:(int64_t)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental;
+ (int64_t)postMoneyScore:(int64_t)score leaderboardId:(int)leaderboardId;
+ (float)postFloatMoneyScore:(float)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental;
+ (float)postFloatMoneyScore:(float)score leaderboardId:(int)leaderboardId;
+ (int64_t)latestScoreOnLeaderboard:(int)leaderboardId;
+ (float)latestFloatScoreOnLeaderboard:(int)leaderboardId;
+ (NSTimeInterval)latestTimeScoreOnLeaderboard:(int)leaderboardId;
+ (int64_t)latestMoneyScoreOnLeaderboard:(int)leaderboardId;
+ (float)latestFloatMoneyScoreOnLeaderboard:(int)leaderboardId;
@end

#pragma mark PankiaNetDelegate
@protocol PankiaNetDelegate<NSObject>
@optional

//game session
- (void)gameSessionWillBegin:(PNGameSession*)gameSession;
- (void)gameSessionDidBegin:(PNGameSession*)gameSession;
- (void)gameSessionDidEnd:(PNGameSession*)gameSession;
- (void)gameSessionDidRestart:(PNGameSession*)gameSession;
- (void)gameSessionDidFailWithError:(PNNetworkError*)error;

//achievements
- (void)unlockAchievementDone:(PNAchievement*)achievementData;
- (void)unlockAchievementFailedWithError:(PNError*)error;
- (void)achievementsDidUpdate;

//dashboard
- (void)dashboardWillAppear;
- (void)dashboardDidAppear;
- (void)dashboardWillDisappear;
- (void)dashboardDidDisappear;
- (void)dashboardDidFailToLaunchWithError:(PNError*)error;

//leaderboards
- (void)postScoreDone:(NSArray*)scores;
- (void)postScoreFailedWithError:(PNError*)error;
- (void)fetchRankOnLeaderboardDone:(NSArray*)rankArray;
- (void)fetchRankOnLeaderboardFailedWithError:(PNError*)error;
- (void)fetchScoresOnLeaderboardDone:(NSArray*)rankArray;
- (void)fetchScoresOnLeaderboardFailedWithError:(PNError*)error;

//user
- (void)userDidLogin:(PNUser*)user;
- (void)userDidFailToLoginWithError:(PNError*)error;
- (void)userDidUpdate:(PNUser*)user;
- (void)userWillSwitchAccount:(PNUser*)user;
- (void)userDidSwitchAccount:(PNUser*)user;
- (void)didUpdateUser:(PNUser*)user;

//etc.
- (void)networkCheckDidFinish;
- (BOOL)shouldShowNotification;
- (BOOL)shouldShowUpgradeNotification;
- (BOOL)shouldShowRegistrationView;
- (BOOL)shouldLaunchDashboardWithAchievementsView;
- (NSString*)messageBeforeSwitchAccount;	//スイッチアカウント前に独自の警告を表示したい時はこのメソッドでその文章を返すように実装してください。
@end
