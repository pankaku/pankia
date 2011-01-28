/** @file
 *  @brief PNRoomクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */

#import "PNHTTPRequestHelper.h"
#import "PNRoomDelegate.h"
#import "PNNetworkDefined.h"
#import "PNLobby.h"
#import "PNModel.h"

@protocol PNRoomManagerDelegate;

@class PNGameSession;
@class PNRoomManager;

/**
 @brief InternetMatchやLocalMatchのroomを表すクラスです。
 */
@interface PNRoom : PNModel {
	PNRoomManager*			roomManager; /**<　@brief ルームマネージャー */
	id<PNRoomDelegate>		delegate; /**<　@brief デリゲート */
	
	int						startCounter;
	NSString*				roomId;			/**<　@brief Room ID (dDI4Axe等の文字列) */
	int						maxMemberNum;		/**<　@brief 部屋の最大人数。（入れる上限） */
	int						minMemberNum;		/**<　@brief 部屋の最小人数。（開始人数 ）*/
	BOOL					isPublished;		/**<　@brief 公開か否か */
	
	BOOL					isInGame;			/**<　@brief ゲームフラグ */
	BOOL					isOwner;			/**<　@brief オーナーであるか */
	BOOL					isJoined;			/**<　@brief 部屋にJoinしているか */
	BOOL					isRequestingJoining;	/**< @brief 入室処理中かどうか */
	int						joinCount;			/**<　@brief 順位付け用の数字。累計の参加人数(JOINしなおすと二回かうんと)。参加人数を表しているわけではないので注意。 */
	
	PNConnectionLevel		speedLevel;			/**<　@brief 通信速度レベル */

	
	NSString*				roomName;	/**<　@brief 追加予定 */
	NSString*				hostName;	/**<　@brief ホスト名 */
	PNGameSession*			gameSession; /**<　@brief ルームに統合予定 */
	
	NSMutableDictionary*	peers;		/**<　@brief ピアの一覧 */
	NSMutableArray*			roomMembers;	/**<　@brief 部屋のメンバーの一覧 */
	int						pairingCounter;	/**<　@brief ペアリングカウンター */	
	
	NSMutableDictionary*	icmpTimes; /**< @brief ICMPリクエストの送信ログ。RTT測定用。 **/
	unsigned short			roomIdentifier; /**< @brief ICMP用ルームID(icmp_idの上位12ビット。最後の4ビットは必ず0。) **/
	
	/** @brief ペアリングし終わったユーザーリスト */
	NSMutableDictionary		*pairingTable;
	


	BOOL					isLocked;			/**<　@brief 部屋がLockされているか */
	BOOL					cancelJoiningFlag;
	
	BOOL					isDisconnectDetectionNecessary;
	BOOL					isHeartBeatNecessary;
	double					heartbeatLastTimeStamp;
	
	PNLobby*				lobby;
	
}

@property (retain) PNLobby* lobby;
@property (retain,readonly) NSString*		roomName;
@property (retain,readonly) NSMutableArray*	roomMembers;

@end
