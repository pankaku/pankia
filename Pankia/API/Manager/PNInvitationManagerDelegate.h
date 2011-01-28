@class PNError;

/**
 *	@brief 招待に関する変化を受け取るデリゲートのプロトコルです。
 */
@protocol PNInvitationManagerDelegate<NSObject>
/**
 *	@brief 招待リストが表示された際に呼ばれるメソッド。
 */
- (void)didShowInvitationList:(NSArray*)invitationArray requestKey:(NSString*)key;
/**
 *	@brief 招待のポストが完了した際に呼ばれるメソッド。
 */
- (void)didPostInvitation:(NSString*)key;
/**
 *	@brief 招待のポストが失敗した際に呼ばれるメソッド。
 */
- (void)didFailInvitationWithError:(PNError*)error requestKey:(NSString*)key;
/**
 *	@brief 招待の削除が完了した際に呼ばれるメソッド。
 */
- (void)didDeleteInvitation:(NSString*)key;
/**
 *	@brief 招待されたルームの一覧が表示された際に呼ばれるメソッド。
 */
- (void)didFindInvitedRooms:(NSArray*)roomArray requestKey:(NSString*)key;
/**
 *	@brief 招待関連でエラーが発生した際に呼ばれるメソッド。
 */
- (void)didFailWithError:(PNError*)error requestKey:(NSString*)key;

@end
