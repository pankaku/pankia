/** @file
 *  @brief PNUserクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */

#import "PNNetworkDefined.h"

typedef enum {
	PNUserIconTypeDefault,
	PNUserIconTypeTwitter,
	PNUserIconTypeFacebook
} PNUserIconType;

/**
 @brief Pユーザを表すモデルです。
 現在ログイン中のユーザの情報を[PNUser currentUser]で取得できます
 */
@interface PNUser : NSObject {
@private
	// Sessions.
	NSString*	userId;				/**< @brief Self user ID. */
	NSString*	sessionId;			/**< @brief Private session ID. */
	NSString*	publicSessionId;	/**< @brief Public session ID. */
	NSString*   gameId;				/**< @brief Game ID. */
	
	// UserInfos.
	NSString*	udid;				/**< @brief Unique device ID. */
	NSString*	username;				/**< @brief User name. */
	NSString*	status;				/**< @brief User status. */
	NSString*   gradeName;			/**< @brief Grade name. */
	NSString*	countryCode;		/**< @brief User country code. */
	NSString*	iconURL;			/**< @brief Image URL. */
	NSString*   twitterId;			/**< @brief Twitter ID. */
	NSString*   twitterAccount;		/**< @brief Twitter User Name ? */
	// BEGIN - lerry added code
	NSString*	facebookId;
	NSString*	facebookAccount;
	// END - lerry added code
	BOOL		isGuest;			/**< @brief Account is guest or not. */
	int         gradePoint;			/**< @brief グレードポイント. */
	int			achievementPoint;	/**< @brief アチーブメントポイント */
	int         achievementTotal;	/**< @brief アチーブメントの合計 */
	BOOL		isSecured;			/**< @brief セキュアーアカウントか否か */
	BOOL		isLinkTwitter;		/**< @brief Twitterにリンクされているか */
	BOOL		isLinkFacebook;		/**< @brief Facebookにリンクされているか */
	BOOL        gradeEnabled;		/**< @brief グレードが有効か否か */
	PNNATType	natType;			/**< @brief NATの種類 */
	int			gradeId;			/**< @brief GradeのID */
	NSUInteger	coins;				/**< @brief コインの枚数 */
	PNUserIconType iconType;		/**< @brief アイコンの種類(DEFAULT, FACEBOOK, TWITTER) */
	
	NSMutableData* receivedData;
	
	NSString* externalId;
}

@property(retain,readonly) NSString* udid;
@property(retain,readonly) NSString* username;
@property(retain,readonly) NSString* status;
@property(retain,readonly) NSString* gradeName;
@property(retain,readonly) NSString* countryCode;
@property(retain,readonly) NSString* iconURL;
@property(retain,readonly) NSString* twitterId;
@property(retain,readonly) NSString* twitterAccount;
// BEGIN - lerry added code
@property(retain,readonly) NSString* facebookId;
@property(retain,readonly) NSString* facebookAccount;
// END - lerry added code
@property(assign,readonly) int achievementPoint;
@property(assign,readonly) int achievementTotal;
@property(assign,readonly) int gradePoint;
@property(assign,readonly) int gradeId;
@property(assign,readonly) NSUInteger coins;
@property(readonly) PNUserIconType iconType;
@property(retain,readonly) NSString* externalId;
@property(retain,readonly) NSString* userId;

#pragma mark current user
/**
 * @brief 現在のユーザーを取得する
 * @returnユーザーオブジェクトを返す
 */
+(PNUser*) currentUser;

@end
