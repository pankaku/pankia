#define kPNPeerToPeerPacketTimeout		20.0f	//!<P2Pパケットがタイムアウトするまでの時間
#define ___GAMESESSION_DEBUG___			false	//!<ゲームセッションのデバッグモード (true or false)
#define kPNPeerToPeerPingPongTimeout	5.0		// 5000ms

@class PNGKSession;
@class AsyncUdpSocket;

@interface PNGameSession (Package)

@property (retain) AsyncUdpSocket*		peerSocket;
@property (retain) PNGKSession*			gameKitSession;
@property (assign) double				startTime;
@property (assign) double				timeDifference;
@property (assign) BOOL					isStarted;
@property (assign) BOOL					isAlive;

@property (retain) id<PNGameSessionDelegate> delegate;
@property (retain) NSMutableDictionary* peers;
@property (retain) PNPeer*				selfPeer;
@property (assign) PNRoom*				room; // クロス参照をさせないためAssignで割り当てる
@property (assign) float				recommendRTO;
@property (assign) PNGameSessionType	gameSessionType;

-(void)postRematchMessage:(BOOL)yesOrNo;
-(void)checkRematchResult:(double)aTimeout;

@end
