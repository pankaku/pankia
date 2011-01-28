#import "PNRoom.h"
#define kPNRoomErrorFailedInvitation					0x010001 //!< 招待に失敗した場合。
#define kPNRoomErrorFailedCreate						0x010002 //!< ルーム作成に失敗した場合。
#define kPNRoomErrorFailedJoin							0x010003 //!< ルーム参加に失敗した場合。
#define kPNRoomErrorFailedAlreadyDeleted				0x010004 //!< 既にルームが削除されていた場合。
#define kPNRoomErrorFailedAlreadyStarted				0x010005 //!< 既にスタートされていた場合。
#define kPNRoomErrorFailedSync							0x010007 //!< ルームメンバーとの同期処理に失敗した場合。
#define kPNRoomErrorFailedMemberChange					0x010008 //!< 入室処理中にメンバー変更があった場合。
#define kPNRoomErrorFailedNoCoins						0x010009 //!< コインが足りない場合。
#define kPNGameSessionErrorFailedHolePunching			0x020001 //!< ホールパンチに失敗した場合。 RTT計測に失敗するのも含まれる。
#define kPNGameSessionErrorFailedPeerToPeerConnection	0x020002 //!< P2Pコネクションが切れた場合。（ping/pongのタイムアウト）

@class PNUser;
@class PNNetworkError;
@class PNGameSession;
@class PNPeer;
@class PNRoomManager;
@class PNError;
@class PNGKSession;
@class PNRoomModel;
@class PNMembershipModel;
@class AsyncUdpSocket;


@interface PNRoom (Package)

@property (retain) NSString*		roomName;
@property (retain) NSMutableArray*	roomMembers;

@property (retain) id<PNRoomDelegate> delegate;
@property (retain) NSString* roomId;
@property (assign) BOOL isPublished;
@property (assign) BOOL isInGame;
@property (retain) NSString* hostName;
@property (retain) PNGameSession* gameSession;
@property (retain) NSMutableDictionary* peers;
@property (assign) PNRoomManager* roomManager;
@property (retain) NSMutableDictionary* pairingTable;
@property (assign) PNConnectionLevel speedLevel;
@property (assign) int maxMemberNum;
@property (assign) int minMemberNum;
@property (assign) int pairingCounter;
@property (assign) int joinCount;
@property (assign) double heartbeatLastTimeStamp;
@property (assign) BOOL isLocked;
@property (assign) BOOL isJoined;
@property (assign) BOOL isRequestingJoining;
@property (assign) BOOL isHeartBeatNecessary;
@property (assign) BOOL isOwner;
@property (assign) BOOL isDisconnectDetectionNecessary;


/** @brief モデルから情報をセットする。 */
-(void) setRoomModel:(PNRoomModel*)aModel;
/** @brief メンバーシップモデルを追加する */
-(void) addMembership:(PNMembershipModel*)aMembershipModel;
/** @brief 接続 */
-(void) join;
/** @brief 接続解除 */
-(void) leave;

-(void) lock;
-(void) unlock;

-(BOOL)isGameRestarting;

/** @brief ICMPによるRTTを測定する。 */
-(void) roundTripTimeMeasurement:(NSArray*)members;
/** @brief 接続レベルを取得する（速度） */
-(int) connectionLevel;
/** @brief ゲームを開始 */
-(void)startGame;
/** @brief ペアリングテーブルやルームメンバーなどが正しいかどうかを調べます */
-(BOOL)verify;	

-(void)terminate;

-(void)heartbeatForP2PNATTable:(AsyncUdpSocket*)aUDPSocket;
-(void)cancelJoining;

+ (NSArray*)availableRoomsFromModels:(NSArray*)models;
- (void)addPeer:(PNPeer*)aPeer;
- (void)removePeer:(PNPeer*)aPeer;
@end

