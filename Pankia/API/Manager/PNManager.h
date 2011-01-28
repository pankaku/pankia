/** @file
 *  @brief PNManagerクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */

#import "PNManagerDelegate.h"
#import "PNAsyncBehaviorDelegate.h"
#import "PNManagerDelegate.h"
#import "PNMasterSynchronizer.h"


#define kPNManagerFinishLoginNotification		@"PNManagerFinishLoginNotification"

@class PNUser;
@class PNRoom;
@class PNRoomManager;
@class PNSessionManager;
@class PNNetworkError;
@class PNRootViewController;
@class PNLeaderboardManager;
@class PNInvitationManager;
@class PNNetworkError;

/**
 @brief PankiaNet全体のマネジメントを行うクラスです。
 
 PankiaNet全体のマネジメントを行うクラスです。このクラスはシングルトンです。
 */ 
@interface PNManager : NSObject <UIApplicationDelegate,PNAsyncBehaviorDelegate, PNMasterSynchronizerDelegate> {
	id<PNManagerNotifyDelegate> notifyDelegate; /**< @bridf バックグランドサービス用デリゲート */
	id<PNManagerDelegate>	delegate; /**< @brief デリゲート */
	PNRoomManager*			roomManager; /**< @brief ルームマネージャ */
	PNInvitationManager*	invitationManager; /**< @brief インビテーションマネージャ */
@private
	PNSessionManager*		sessionManager;
	BOOL					_loggedinOnce; // ログインしたことがある
	BOOL					_isLoggedIn; // 同 @property BOOL isLoggedIn
	BOOL					canPush; /**< @brief Push可能か否か */
	int						NATCheckCounter;
	BOOL                    _isScreenActive;//画面の活性状態
	BOOL                    _canResend;//再送処理ができる状態
	NSDate					*previousLoginTryDate;
}

@property (retain) id<PNManagerNotifyDelegate>	notifyDelegate;
@property (retain) id<PNManagerDelegate>		delegate;
@property (retain) PNRoomManager*				roomManager; //[PNRoomManager defaultRoomManager]と同じオブジェクト
@property (retain) PNInvitationManager*			invitationManager;
@property (retain) PNSessionManager*			sessionManager;
@property (assign) BOOL isLoggedIn;
@property (assign) BOOL canPush; /**< @brief Push可能か否か */
@property (assign) BOOL isScreenActive;
@property (assign) BOOL canResend;

+ (PNManager*) sharedObject; /**< @brief シングルトンオブジェクトを受け取る */
+ (PNRoomManager*)roomManager; /**< @brief ルームマネージャを受け取る */

-(void)connectToPingPongServer;
-(void)disconnect; /**< @brief 切断する */

- (BOOL)login;	/**< @brief UDIDを使用してログインする */

- (void)showDebugNotice:(NSString*)title description:(NSString*)description;

- (BOOL)loggedinOnce;

- (void)registerDelegateToBackchannel:(id)anObject forKey:(NSString*)akey;

- (BOOL)isCheckedNetwork;
- (void)sendReport:(NSString*)text;

// BEGIN - lerry added code

// To determine whether the current game supports Game Center,
// configurable in PankiaNet.plist:GameCenterEnabled.
-(BOOL)gameCenterOptionSet;
// To determine whether the current wants to enable Game Center,
// if gameCenterOptionSet() returns NO, there is no meaning calling this method.
-(BOOL)gameCenterEnabled;
// To enable Game Center if state=YES and disable it if state=NO.
-(void)setGameCenterToState:(BOOL)state;
// To authenticate local player on Game Center,
// meaningful to call only when both gameCenterOptionSet() and gameCenterEnabled() return YES.
-(void)authenticateLocalPlayer;

// END - lerry added code

/**
 * セッション作成／復元、アカウント切り替え等、
 * PANKIAサーバーとの接続状態が新しくなったときに呼ばれるメソッドです。
 */
- (void)onCreatingOrVerifyingSessionSucceeded;

@end



