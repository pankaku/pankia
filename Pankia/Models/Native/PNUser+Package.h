#import "PNUser.h"
//[Country code]
#define kPNCountryCodeDefault       @"COUNTRY_CODE_NONE"

@class PNUserModel;
@class PNSessionModel;

@interface PNUser(Package)

@property(retain) NSString* udid;
@property(retain) NSString* username;
@property(retain) NSString* status;
@property(retain) NSString* gradeName;
@property(retain) NSString* countryCode;
@property(retain) NSString* iconURL;
@property(retain) NSString* twitterId;
@property(retain) NSString* twitterAccount;
// BEGIN - lerry added code
@property(retain) NSString* facebookId;
@property(retain) NSString* facebookAccount;
// END - lerry added code
@property(assign) int achievementPoint;
@property(assign) int achievementTotal;
@property(assign) int gradePoint;
@property(assign) int gradeId;

@property(retain) NSString* userId;
@property(retain) NSString* sessionId;
@property(retain) NSString* publicSessionId;
@property(retain) NSString* gameId;
@property(assign) PNNATType natType;
@property(assign) BOOL gradeEnabled;
@property(assign) BOOL isLinkTwitter;
@property(assign) BOOL isLinkFacebook;
@property(assign) BOOL isGuest;
@property(assign) BOOL isSecured;
@property(assign) int64_t coins;


#pragma mark initializers, etc 
- (id)initWithUserModel:(PNUserModel *)model;

/**
 * @brief ユーザーモデルを使用して情報を更新する
 * @param[in] aModel ユーザーモデル
 */
- (void)updateFieldsFromUserModel:(PNUserModel*)aModel;

/**
 * @brief セッションモデルを使用して情報を更新する
 * @param[in] model セッションモデル
 */
- (void)updateFieldsFromSessionModel:(PNSessionModel*)model;

/**
 * @brief 新規ユーザーを作成する
 * @return 作成したユーザーオブジェクトを返す
 */
+(PNUser*) user;

/**
 * @brief セッションIDを返す
 * @return セッションID
 */
+(NSString*) session;

//現在のユーザID(int)を返します。ゲストユーザの場合は0を返します。
+(int)currentUserId;

/**
 * @brief 重複除外カウンタの値を返す
 * @return カウンタの値
 */
+(int)countUpDedupCounter;

-(NSString*)verifierStringWithGameSecret:(NSString*)gameSecret;

#pragma mark cache
/**
 * @brief ユーザーデータを読み込む
 * @return ユーザーオブジェクト
 */
+(PNUser*)loadFromCache;

/**
 * そのユーザの情報をカレントユーザとしてNSUserDefaultsに保存します。
 * そうすることで、次回起動時にインターネットに接続されていない状況でもユーザ情報を復元することができます。
 */
- (void)saveToCacheAsCurrentUser;

/**
 * @brief サーバから最新の自分のアカウント情報をダウンロードしてきて上書きする。
 */
- (void)downloadLatestStatusFromServer;

// BEGIN - lerry added code
- (BOOL)isLinkedWithFacebook;
// END - lerry added code
@end
