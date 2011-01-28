/** @file
 *  @brief PNRoomManagerクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */

#import "PNServiceNotifyDelegate.h"
#import "PNAsyncBehaviorDelegate.h"
#import "PNRoomManagerDelegate.h"

@class PNLobby;
@class PNRoom;
@class PNGKSession;

@protocol PNRoomDelegate;

/**
 @brief roomを管理するクラスです
 */
@interface PNRoomManager : NSObject<PNServiceNotifyDelegate> {
@public
	id<PNAsyncBehaviorDelegate> asyncBehaviorDelegate;
@private
	id<PNRoomManagerDelegate> delegate;	/**< @brief ルームマネージャーデリゲート */
	id<PNRoomDelegate> currentRoomDelegate;	/**< @brief カレントルームデリゲート */
	NSMutableDictionary* rooms;	/**< @brief ルーム一覧 */
	PNRoom* currentRoom;	/**< @brief 現在入室中のルーム */
	PNGKSession* gkSession;	/**< @brief セッション */
	NSString *currentJoinRequestKey;
}

@property(retain) id<PNRoomManagerDelegate> delegate;
@property(retain) id<PNRoomDelegate> currentRoomDelegate;
@property(readonly) NSMutableDictionary* rooms;
@property(retain) PNRoom* currentRoom;
@property(retain) PNGKSession* gkSession;

/**
 * @brief パラメーターを指定してルームを作成する
 * @param[in] memberNum メンバー数
 * @param[in] pairingReqestFlag ペアリングを必要とする部屋かどうか
 * @param[in] publishFlag 公開ルームにするか否か
 * @param[in] name ルーム名
 * @param[in] gradeId gradeのID
 * @param[in] gradeRange gradeのRange
 * @param[in] roomDelegate ルームデリゲート
 */
-(int)createRoomWithMemberNumAndGrade:(int)memberNum
						  publishFlag:(BOOL)publishFlag
							 roomName:(NSString*)name
						   gradeRange:(NSString*)gradeRange
							  lobbyId:(int)lobbyId
						 roomDelegate:(id<PNRoomDelegate>)_roomDelegate;
-(void)createAnInternetRoomWithMaxMemberNum:(int)memberNum
								  isPublic:(BOOL)isPublic
								  roomName:(NSString*)name
								gradeRange:(NSString*)gradeRange
									lobbyId:(int)lobbyId
								  delegate:(id)aDelegate
							   onSucceeded:(SEL)onSucceededSelector
								  onFailed:(SEL)onFailedSelector;



/**
 * @brief パラメータを指定してローカルルームを作成する
 * @param[in] aMinMemberNum 対戦が出来る最小メンバー数
 * @param[in] aMaxMemberNum 対戦が出来る最大メンバー数
 * @param[in] aName ルーム名
 * @param[in] aDelegate ルームデリゲート
 */
-(void)createLocalRoomWithMinMemberNum:(int)aMinMemberNum
						  maxMemberNum:(int)aMaxMemberNum
							  roomName:(NSString*)aName 
								 lobby:(PNLobby*)lobby
							  delegate:(id<PNRoomDelegate>)aDelegate;

/**
 * @brief ランダムにルームを取得する
 * @param[in] maxCount 取得するルーム数
 */
- (void)findRandomRooms:(int)maxCount delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
			   onFailed:(SEL)onFailedSelector;
- (void)findRooms:(int)maxCount inLobby:(int)lobbyId delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
		 onFailed:(SEL)onFailedSelector;
/**
 * @brief ルームのメンバー一覧を取得する
 */
- (void)getMembersOfRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector;
- (void)getMembersOfRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector withObject:(id)object;

/**
 * @brief インターネット対戦の部屋を退室する
 */
- (void)leaveInternetRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
					 onFailed:(SEL)onFailedSelector;

/**
 * @brief インターネット対戦の部屋に入室する
 */
- (void)joinInternetRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector;

/**
 * @brief ルーム情報を取得する
 * param[in] roomId 取得するルームのId
 */
-(void)showRoom:(NSString*)roomId;

/**
 * @brief アクティブなルームの一覧を取得する
 * @return 成功の可否
*/
-(int)getActiveRooms;

/**
 * @brief アクティブな招待されたルームの一覧を取得する
 * @return 成功の可否
*/
-(int)getActiveInvitedRooms;

/**
 * @brief アクティブなルームの数を取得する
 * @return ルーム数
 */
-(int)countActiveRooms;

/**
 * @brief アクティブなローカルルームの一覧を検索する
*/
-(void)findLocalRoomsWithLobby:(PNLobby*)lobby;

/**
 * @brief アクティブなローカルルームの一覧の検索を中止する
*/
-(void)stopFindActiveRooms;


-(void)terminate;

@end
