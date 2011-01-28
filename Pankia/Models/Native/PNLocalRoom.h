#import "PNRoom.h"

/**
 * @brief ローカルルームをコントロールするためのクラス
 * 
 * インターネット用のルームクラスを派生させたクラス。
 * ローカル対戦はGameKitAPIを使った作りになるので、
 * インターネット対戦用のルームとはフィールドはほぼ同じだけど、
 * 概念と処理が大きく違うのとロジックが長いので別クラスに分けています。
 */
@interface PNLocalRoom : PNRoom {
@private
	PNGKSession*		gameKitSession; /**< @brief GameKitのセッションオブジェクト */
	PNPeer* selfPeer;
	BOOL					isReady;			/**<  @brief 開始準備が出来たかどうか */
	
}

-(void)startService;	/**< @brief サービスを開始 */
-(void)startNotifying;	/**< @brief 通知を開始 */
-(void)stopService;		/**< @brief サービスを停止 */
-(void)heartbeat;


@property(retain) PNGKSession* gameKitSession;
@property(assign) BOOL isReady;

@end
