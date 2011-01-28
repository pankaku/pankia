#import "PNNetworkError.h"
#import "PNServiceNotifyDelegate.h"

@protocol PNServiceNotifyDelegate;

/**
 @brief HTTPRequestをサーバーに送信し、レスポンスを受け取るクラス。
 
 レスポンスは非同期で受け取るために、リクエストメソッドに対して、オブザーブ用のデリゲートを渡します。
 受け取るとPNConnectionNotifyDelegateの実装に対してレスポンスが非同期に通知されます。
 */
@interface PNHTTPService : NSObject {
	NSMutableData*				data;
	NSString*					requestURL;
	id							userInfo;
	id<PNServiceNotifyDelegate> delegate;
	int							sec;
	BOOL						isMutable;
	NSURLConnection*			urlConnection;
	NSMutableURLRequest*		urlRequest;
}

@property (retain) NSMutableData*				data;
@property (retain) NSString*					requestURL;
@property (retain) id<PNServiceNotifyDelegate>	delegate;
@property (retain) id							userInfo;
@property (retain) NSURLConnection*				urlConnection;
@property (retain) NSMutableURLRequest*			urlRequest;
@property (assign) int							sec;
@property (assign) BOOL							isMutable;

/**
 * @brief 同期HTTPRequestメソッド
 * @param url リクエストurl
 */
+ (PNHTTPService*)synchronousRequestWithURL:(NSString*)url;

/** 
 * @brief HTTPRequestメソッド
 *
 * HTTP GETで指定のURLにリクエストします。
 * @param request リクエストURL
 * @param delegate レスポンスを受け取るオブザーバーインスタンス
 * @param userInfo レスポンスを受け取る時に、どのリクエストに対してのレスポンスか判定するための情報（ユーザー定義）
 */
+ (PNHTTPService*) GETWithURL:(NSString*)url
				  delegate:(id<PNServiceNotifyDelegate>)delegate
				  userInfo:(id)info;

/** 
 * @brief HTTPRequestメソッド
 *
 * HTTP GETで指定のURLにリクエストします。
 * @param requestWithTimeout リクエストURL
 * @param delegate レスポンスを受け取るオブザーバーインスタンス
 * @param userInfo レスポンスを受け取る時に、どのリクエストに対してのレスポンスか判定するための情報（ユーザー定義）
 * @param timeout タイムアウト値を秒単位で設定
 */
+ (PNHTTPService*) GETWithURL:(NSString*)url
					  delegate:(id<PNServiceNotifyDelegate>)delegate
					  userInfo:(id)info
					   timeout:(int)sec; //タイムアウトを指定できる

/** 
 * @brief HTTPRequestメソッド
 *
 * HTTP POSTで指定のURLにリクエストします。
 * @param requestWithTimeout リクエストURL
 * @param delegate レスポンスを受け取るオブザーバーインスタンス
 * @param userInfo レスポンスを受け取る時に、どのリクエストに対してのレスポンスか判定するための情報（ユーザー定義）
 * @param timeout タイムアウト値を秒単位で設定
 */
+ (PNHTTPService*) POSTWithURL:(NSString*)url
					  delegate:(id<PNServiceNotifyDelegate>)delegate
					  userInfo:(id)info
					   timeout:(int)sec; //タイムアウトを指定できる

/** 
 * @brief HTTPRequestメソッド
 *
 * HTTP GETで指定のURLにリクエストします。
 * @param request リクエストURL
 * @param delegate レスポンスを受け取るオブザーバーインスタンス
 * @param userInfo レスポンスを受け取る時に、どのリクエストに対してのレスポンスか判定するための情報（ユーザー定義）
 * @param isMutalbe clearAllRequestによるリクエストのキャンセルを許すかどうか。NOならキャンセルされない。
 */
+ (PNHTTPService*) GETWithURL:(NSString*)url 
					 delegate:(id)delegate
					 userInfo:(id)info
					isMutable:(BOOL)_isMutable;

/** 
 * @brief HTTPRequestメソッド
 *
 * HTTP GETで指定のURLにリクエストします。
 * @param requestWithTimeout リクエストURL
 * @param delegate レスポンスを受け取るオブザーバーインスタンス
 * @param userInfo レスポンスを受け取る時に、どのリクエストに対してのレスポンスか判定するための情報（ユーザー定義）
 * @param timeout タイムアウト値を秒単位で設定
 * @param isMutalbe clearAllRequestによるリクエストのキャンセルを許すかどうか。NOならキャンセルされない。
 */
+ (PNHTTPService*) GETWithURL:(NSString*)url 
					 delegate:(id)delegate
					 userInfo:(id)info
					  timeout:(int)sec
					isMutable:(BOOL)_isMutable;

/** 
 * @brief HTTPRequestメソッド
 *
 * HTTP POSTで指定のURLにリクエストします。
 * @param requestWithTimeout リクエストURL
 * @param delegate レスポンスを受け取るオブザーバーインスタンス
 * @param userInfo レスポンスを受け取る時に、どのリクエストに対してのレスポンスか判定するための情報（ユーザー定義）
 * @param timeout タイムアウト値を秒単位で設定
 * @param isMutalbe clearAllRequestによるリクエストのキャンセルを許すかどうか。NOならキャンセルされない。
 */
+ (PNHTTPService*) POSTWithURL:(NSString*)url
					  delegate:(id)delegate
					  userInfo:(id)info
					   timeout:(int)sec
					 isMutable:(BOOL)_isMutable;

- (BOOL) cancel;

@end

