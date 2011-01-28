/** @file
 *  @brief PNErrorクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
*/

#define kPNConnectionError @"cannot_connect_to_server"

#define kPNPurchaseErrorProductNotFoundInTheAppStore @"product_not_found_in_the_app_store"
#define kPNPurchaseErrorMerchandiseNotFound @"merchandise_not_found"
#define kPNPurchaseErrorItemNotFound @"item_not_found"
#define kPNPurchaseErrorTransactionNotRestored @"transaction_not_restored"
#define kPNPurchaseErrorWillBeMaxedOut @"will_be_maxed_out"
#define kPNPurchaseErrorCannotMakePayments @"cannot_make_payments"
#define kPNPurchaseErrorPaymentFailed @"payment_failed"
/**
 * \if Japanese
 *@brief Errorデータを保持する構造体としてのクラスです。
 
 エラーの情報を格納します。
 * \endif
 * \if English
 * @brief Error data wo hoji-suru kouzoutai to shiteno class desu.
 
 errir infomation wo kakunou shimasu
 * \endif
 */
@interface PNError : NSError {
	int errorType; /**<　@brief エラーの種類です。 */
	NSString* errorCode; /**<　@brief エラーコードです。 */
	NSString* message; /**<　@brief エラーメッセージです。 */
}

@property(assign) int errorType; /**<　@brief エラーの種類です。 */
@property(retain) NSString* errorCode; /**<　@brief エラーコードです。 */
@property(retain) NSString *message; /**<　@brief エラーメッセージです。 */
/**
 *	@brief エラーの種類、エラーメッセージからーオブジェクトを作成します。
 * @return AutoReleaseされたエラーオブジェクトを返します。
 */
+(PNError*)errorWithType:(int)type message:(NSString*)message;
/**
 *	@brief 基本的なエラーオブジェクトを作成します。
 * @return AutoReleaseされたエラーオブジェクトを返します。
 */
+(PNError*)error;
/**
 *	@brief レスポンスの文字列から、エラーオブジェクトを作成します。
 * @return 初期化されたエラーオブジェクトを返します。
 */
-(id)initWithResponse:(NSString*)response;
+ (id)errorFromResponse:(NSString*)response;

- (id)initWithCode:(NSString*)code message:(NSString*)message;
+ (id)errorWithCode:(NSString*)code message:(NSString*)message;

+ (id)connectionError;
- (BOOL)isConnectionError;

- (NSString*)errorTitle; /**< @brief エラーのタイトル */
- (NSString*)errorMessage; /**< @brief エラーメッセージ */

@end

