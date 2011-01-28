/** @file
 *  @brief PNGameSessionクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */

@class		AsyncUdpSocket;
@class		PNPeer;
@class		PNUser;
@class		PNRoom;
@class		PNError;
@class		PNGameSet;
@class		PNGKSession;
@class		PNLobby;

@protocol	PNGameSessionDelegate;


// [GameSession connection mode]
typedef enum
{
	kPNGameSessionReliable		= 0x01000000,
	kPNGameSessionUnreliable	= 0x02000000,
	kPNGameSessionRaw			= 0x03000000
	
} PNSendDataMode ;

typedef enum
{
	PNInternetSession,	
	PNNearbySession,
	
} PNGameSessionType ;


/**
 * @brief ゲームのセッションを管理し、他のピアとの通信を行うクラスです。
 */
@interface PNGameSession : NSObject {
@private
	id<PNGameSessionDelegate>	delegate; /**<　@brief ゲームセッションのデリゲートです。 */
	
	float						recommendRTO;		/**<　@brief RTO計測値です。 */
	PNPeer*						selfPeer;			/**<　@brief 自分自身のPeerオブジェクトです */
	NSMutableDictionary*		peers;				/**<　@brief Opponents(対戦相手)のPeerオブジェクトのディクショナリーです。 */
	NSMutableDictionary*		cachedPeersForRematch;
	PNRoom*						room;				/**<　@brief ルームオブジェクトです。 */
	PNGameSessionType			gameSessionType;	/**< @brief ゲームセッションがNearbyかInternetの判別に使います。 */
	
	PNGKSession*				gameKitSession;		/**<　@brief BlueTooth用セッションです。 */
	AsyncUdpSocket*				peerSocket;
	
	double						startTime;			// ゲームスタートタイム
	double						timeDifference;		// ホストとの時間のずれ。
	
	double						latestSendTime;
	NSArray*					sortedPeersList;
	int							packetMaxSize;
	BOOL						isAlive;
	BOOL						isStarted;
	
	id							callbackGameStarting;
	SEL							callbackGameStartingSel;
	int							synchronizeCount;
	int							syncState;
	double						timeStamp;
	int							cachedCounter;
	
	BOOL						isSynchronousProcessingDone;
	BOOL						isTimeoutCheckNecessary;
	BOOL						isVotingTimeoutCheckNecessary;
	
	BOOL						isPosted;
	int							synchronizationTransactionCounter;
	int							rematchCheckTransactionCounter;
	
	NSMutableDictionary*		rematchMemberTable;
}

@property (retain) id<PNGameSessionDelegate>			delegate;
@property (retain, readonly) NSMutableDictionary*		peers;
@property (retain, readonly) PNPeer*					selfPeer;
@property (assign, readonly) PNRoom*					room; // クロス参照をさせないためAssignで割り当てる
@property (assign, readonly) float						recommendRTO;
@property (assign, readonly) PNGameSessionType			gameSessionType;
@property (assign, readonly) BOOL						isStarted;
@property (assign, readonly) int						lobby;

/**
 *	@brief 紐付けられているピアオブジェクトの配列を返します。
 * @return 紐付けられているピアオブジェクトの配列です。
 */
-(NSArray*)peerList;

/**
 *	@brief index番目のピアオブジェクトを返します。
 * @param[in] index 何番目のピアかの数値を渡します。
 * @return ピアオブジェクトを返します。
 */
-(PNPeer*)peer:(int)index;


/**
 *	@brief IPアドレスとポートからピアオブジェクトを返します。
 * @param[in] address ピアのIPアドレスです。
 * @param[in] port ピアのポート番号です。
 * @return ピアオブジェクトを返します。
 */
-(PNPeer*)peer:(NSString*)address port:(int)port;

/**
 *	@brief 現在のピアの数を返します。
 * @return 現在のピアの数を返します。
 */
-(int)countPeers;

/**
 *  @brief ゲームが開始されてからの時間を返します。このときの開始時間はホストのデバイス時間を基準にした開始時間になります。
 * @return ゲームが開始されてからの時間。
 */
-(double)timeElapsed;

/**
 *	@brief ゲームセッションを開始します。
 */
-(void)startGameSession:(id)delegate sel:(SEL)sel;

/**
 *	@brief ゲームセッションを終了します。
 */
-(void)endGameSession;//ゲーム終了をフレームワークに通知するメソッド

/**
 *	@brief データをピアに送信します。
 * @param[in] data 送信するデータです。
 * @param[in] peers 送信先ピアの配列です。
 * @param[in] mode 送信に使用するモードです。
 * @return 成功の可否が返ります。
 */
-(BOOL)sendData:(NSData *)data toPeers:(NSArray *)peers withDataMode:(PNSendDataMode)mode;

/**
 *	@brief データを全てのピアに送信します。
 * @param[in] data 送信するデータです。
 * @param[in] mode 送信に使用するモードです。
 * @return 成功の可否が返ります。
 */
-(BOOL)sendDataToAllPeers:(NSData *)data withDataMode:(PNSendDataMode)mode;

/**
 *	@brief サーバーに対戦結果を通知します。
 * 
 * @param[in] aGameSet ハンドルとポイントのセット
 * @param[in] aTimeout リマッチを受け付ける時間
 */
-(void)finish:(PNGameSet*)aGameSet;

-(void)waitForRematch:(double)aTimeout;

/**
 *	@brief すべてのPeerとの接続を切断します。
 */
-(void)disconnect;


-(void)postRequestMessage:(NSDictionary*)parameter;

@end



/**
 *	@brief ゲームセッションの状態を受け取るデリゲートのプロトコルです。
 */
@protocol PNGameSessionDelegate<NSObject>

@optional

/**
 *	@brief ピアとのコネクションが成立した際に呼ばれます。
 */
-(void)gameSession:(PNGameSession*)gameSession didConnectPeer:(PNPeer*)opponent;

/**
 *	@brief ピアとのコネクションが切断された際に呼ばれます。
 */
-(void)gameSession:(PNGameSession*)gameSession didDisconnectPeer:(PNPeer*)opponent;

/**
 *	@brief ゲームセッションが終了した時に通知されます。
 */
-(void)didGameSessionEnd:(PNGameSession*)gameSession;

/**
 *	@brief ピアからデータが送られてきた際に呼ばれます。
 */
-(void)gameSession:(PNGameSession*)gameSession didReceiveData:(NSData*)data from:(PNPeer*)opponent;

/**
 *	@brief 送信に失敗した時に呼ばれます。
 */
-(void)gameSession:(PNGameSession*)gameSession didSendError:(PNError*)error opponent:(PNPeer*)peer data:(NSData*)data;



@end
