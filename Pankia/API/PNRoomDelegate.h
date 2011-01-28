@class PNRoom;
@class PNNetworkError;
@class PNGameSession;
@class PNPeer;
@class PNUser;

/**
 * @brief PNRoomオブジェクトのデリゲートのためのプロトコルです。
 */

@protocol PNRoomDelegate<NSObject>
@optional
/**
 * @brief ルームに入室した際に呼ばれます。
 * @param[in] room ルームオブジェクト
 */
-(void)roomDidJoin:(PNRoom*)room;

/**
 * @brief ルームへの入室に失敗した際に呼ばれます。
 * @param[in] room ルームオブジェクト
 * @param[in] error エラーオブジェクト
 */
-(void)room:(PNRoom*)room didFailJoinWithError:(PNNetworkError*)error;

/**
 * @brief ルームのゲームセッションが開始される直前に呼ばれます
 * @param[in] room ルームオブジェクト
 * @param[in] gameSession 開始されるゲームセッション
 */
-(void)room:(PNRoom*)room willBeginGameSession:(PNGameSession*)gameSession;

/**
 * @brief ルームのゲームセッションが再開始される際に呼ばれます
 * @param[in] room ルームオブジェクト
 * @param[in] gameSession 開始されるゲームセッション
 */
-(void)room:(PNRoom*)aRoom didRestartGameSession:(PNGameSession*)gameSession;

/**
 * @brief ルームのゲームセッションが開始された際に呼ばれます
 * @param[in] room ルームオブジェクト
 * @param[in] gameSession 開始されたゲームセッション
 */
-(void)room:(PNRoom*)room didBeginGameSession:(PNGameSession*)gameSession;

/**
 * @brief ルームのゲームセッションが終了された際に呼ばれます
 * @param[in] room ルームオブジェクト
 * @param[in] gameSession 終了されたゲームセッション
 */
-(void)room:(PNRoom*)room didEndGameSession:(PNGameSession*)gameSession;

@optional
/**
 * @brief ルームを退室した際に呼ばれます。
 * @param[in] room ルームオブジェクト
 */
-(void)roomDidLeave:(PNRoom*)room;

/**
 * @brief ルームに他のユーザが入室した際に呼ばれます。
 * @param[in] room ルームオブジェクト
 * @param[in] user 入室したユーザ
 */
-(void)room:(PNRoom*)room didJoinUser:(PNUser*)user;

/**
 * @brief ルームから他のユーザが退室した際に呼ばれます。
 * @param[in] room ルームオブジェクト
 * @param[in] user 退室したユーザ
 */
-(void)room:(PNRoom*)room didLeaveUser:(PNUser*)user;

/**
 * @brief ルームから退室した際に呼ばれます。
 * @param[in] room ルームオブジェクト
 */
-(void)didLeaveRoom:(PNRoom*)room;

/**
 * @brief 入室者情報が更新された際に呼ばれます。
 * @param[in] room ルームオブジェクト
 * @param[in] users 入室しているユーザのリスト
 */
-(void)room:(PNRoom*)room didUpdateJoinedUsers:(NSArray*)users;

/**
 * @brief ルーム関係の処理でエラーが発生した際に呼ばれます。
 * @param[in] room ルームオブジェクト
 * @param[in] error エラーオブジェクト
 */
-(void)room:(PNRoom*)room didFailWithError:(PNError*)error;

/**
 * @brief UHPを開始する直前に呼ばれます。
 */
-(void)room:(PNRoom*)room willStartPairing:(PNPeer*)peer;

/**
 * @brief UHPの結果をサーバーにレポートしたときに呼ばれます。
 */
-(void)room:(PNRoom*)room didReport:(NSString*)report;

/**
 * @brief speed Levelの計測が終了したときに呼ばれます。
 */
-(void)room:(PNRoom*)room finishGetSpeedLevelForPeer:(PNPeer*)peer;

-(void)didStartRematchProcessing;

// When finished rematch synchronous processing, call back this method.
-(void)synchronizationBeforeVotingDone;

// When finished result processing, call back this method.
-(void)decidedRematchResult:(NSArray*)memberArray; // Member of the remainder. Element type is PNPeer*

-(void)receivedRequestMessage:(NSDictionary*)params;

@end
