/** @file
 *  @brief PNInvitationManagerクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */


#import "PNAsyncBehaviorDelegate.h"

@class PNError;
@protocol PNInvitationManagerDelegate;

/**
 @brief InvitationのHTTPリクエストを補助するクラスです。
 
 Invitationの表示、発行、削除を行えます。
 */
@interface PNInvitationManager : NSObject {
@public
	id<PNAsyncBehaviorDelegate>			asyncBehaviorDelegate;
@private
	NSMutableDictionary*				rooms;		/**< @brief ルーム一覧 */
	id delegate;
	SEL succeedSelector;
	SEL failedSelector;
}

/**
 *	@brief 招待リストを表示します。
 */
- (void)showInvitationList;
/**
 *	@brief 全てのユーザーに招待リクエストを送信します。
 */
- (void)postInvitationForAllUsersWithDelegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector;
/**
 *	@brief 特定のユーザーに招待リクエストを送信します。
 *  @param[in] userArray 招待先ユーザーの配列です。
 */
- (void)postInvitationForUsers:(NSMutableArray*)userArray delegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector;

/**
 *	@brief 招待リクエストを削除します。
 */
- (void)deleteInvitation;
/**
 *	@brief 招待されたルームの一覧表示します。
 */
- (void)findInvitedRoomsWithDelegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector;

@end

