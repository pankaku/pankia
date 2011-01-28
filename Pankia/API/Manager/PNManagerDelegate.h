
@class PNManager;
@class PNUser;
@class PNRoom;
@class PNError;

/**
 * @brief PNManagerのデリゲートのためのプロトコルです。
 */
@protocol PNManagerDelegate<NSObject>

@optional
/**
 * @brief NATチェックがおわったときに呼ばれます。
 */
-(void)managerDidDoneNatCheck:(PNManager*)manager;
/**
 * @brief PankiaNetにログインされた際に呼ばれます。
 * @param[in] manager PNManagerオブジェクトです。
 * @param[in] user ユーザーオブジェクトです。
 */
-(void)manager:(PNManager*)manager didLogin:(PNUser*)user;
-(void)manager:(PNManager*)manager didFailLoginWithError:(PNError*)error;
/**
 * @brief Dashboard上でスイッチアカウントが完了したときに呼ばれます
 */
-(void)manager:(PNManager*)manager didSwitchAccount:(PNUser*)user;

/**
 * @brief 対戦用のネットワーク環境チェックが終了した場合に呼ばれます。このAPIが呼ばれないうちはルームにJOINできません。
 * @param[in] manager PNManagerオブジェクトです。
 */
-(void)didEndNetworkCheckingWithManager:(PNManager*)manager;
/**
 * @brief PankiaNetへの接続に失敗した際に呼ばれます。
 * @param[in] manager PNManagerオブジェクトです。
 * @param[in] error エラーオブジェクトです。
 */
-(void)manager:(PNManager*)manager didFailConnectionWithError:(PNError*)error;
/**
 * @brief PankiaNetとの通信に失敗した際に呼ばれます。
 * @param[in] manager PNManagerオブジェクトです。
 * @param[in] error エラーオブジェクトです。
 */
-(void)manager:(PNManager*)manager didFailWithError:(PNError*)error;
/**
 * @brief Push通知が飛んできた際に呼ばれます。
 * @param[in] manager PNManagerオブジェクトです。
 * @param[in] message 通知の内容のメッセージです。
 * @param[in] user 送信元のユーザー名です。
 */
-(void)manager:(PNManager*)manager didRecievePushNotification:(NSString *)message fromUser:(PNUser*)user;
/**
 * @brief 招待を受信した際に呼ばれます。
 * @param[in] manager PNManagerオブジェクトです。
 * @param[in] room 招待されたルームです。
 * @param[in] user 招待を行ったユーザーです。
 */
-(void)manager:(PNManager*)manager didRecieveInvitation:(PNRoom*)room fromUser:(PNUser *)user;

- (void)manager:(PNManager*)manager didGetLatestVersion:(NSString*)versionString iTunesURL:(NSString*)iTunesURL;

/**
 * @brief サーバーに保存されている解放済みアチーブメントを同期し、新たにアチーブメントが解放された時に呼ばれます。
 */
- (void)managerDidDownloadAndUnlockedAchievementsFromServer:(PNManager*)manager;

#ifdef DEBUG	//デバッグ用のメソッドです。Debugビルドのときだけ使用できます。情報をNotificationViewで表示します。
- (void)manager:(PNManager*)manager didReceiveDebugInfo:(NSString*)title description:(NSString*)description;
#endif
@end

@protocol PNManagerNotifyDelegate

- (void)didUpdate:(PNManager*)aManager;
- (void)didFinishMatch:(int)aChangePoint newGradePoint:(int)aNewGradePoint;

@end
