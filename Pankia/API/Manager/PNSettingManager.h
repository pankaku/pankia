/** @file
 *  @brief PNSettingManagerクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */

/**
 @brief アプリケーション毎の機能設定(gameKeyなど)を管理するクラスです。
 
 InternetMatchや、LocalMatch、等の表示制御や、gameKey、gameSecretなどの設定を読み取ります。
 */
@interface PNSettingManager : NSObject {
	NSMutableDictionary *userDictionary;	/**< @brief ユーザー辞書 */
	NSDictionary *defaultDictionary;	/**< @brief デフォルト辞書 */
	
	NSDictionary *offlineSettingsDictionary;
	
	BOOL matchEnabled;
}
@property (nonatomic, assign) BOOL matchEnabled;
+ (PNSettingManager*)sharedObject;	/**< @brief シングルトンオブジェクトを取得する */
/**
 * @brief キーに結びつけられたBOOL値を取得する
 * @param[in] key キー
*/
- (BOOL)boolValueForKey:(NSString*)key;
/**
 * @brief キーに結びつけられた文字列を取得する
 * @param[in] key キー
 */
- (NSString*)stringValueForKey:(NSString*)key;

- (int)intValueForKey:(NSString*)key;
/**
 * @brief キーが存在するか調べる
 * @param[in] key キー
 */
- (BOOL)hasKey:(NSString*)key;

- (void)setIntValue:(int)value forKey:(NSString*)key;

/**
 * @brief 現在の言語設定を読み込みます
 */
- (NSString*)preferedLanguage;

- (void)setInternetMatchMinRoomMember:(int)minMember;
- (void)setInternetMatchMaxRoomMember:(int)maxMember;
- (void)setNearbyMatchMinRoomMember:(int)minMember;
- (void)setNearbyMatchMaxRoomMember:(int)maxMember;
- (int)internetMatchMinRoomMember;
- (int)internetMatchMaxRoomMember;
- (int)nearbyMatchMinRoomMember;
- (int)nearbyMatchMaxRoomMember;
- (void)setSideMenuEnabled:(BOOL)value;
- (BOOL)isSideMenuEnabled;

+ (NSString*)pathForLocalSettingsPlist;
+ (BOOL)hasLocalSettingPlist;
+ (int)currentVersionInt;

- (NSArray*)lobbies;

- (NSDictionary*)offlineSettings;

+ (BOOL)storedBoolValueForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
+ (void)storeBoolValue:(BOOL)value forKey:(NSString*)key;
@end
