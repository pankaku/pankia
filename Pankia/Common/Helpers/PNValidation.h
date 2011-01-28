
/**
 * @brief バリデーションを行うクラスです。
 */
@interface PNValidation : NSObject {

}

/**
 * @brief テキストが空か否かを判定します。
 * @param[in] text 調査対象のテキスト
 * @return 空か否か
 */
+(BOOL)isEmpty:(NSString*)text;

/**
 * @brief ２つの文字列が等しいか否かを判定します。
 * @param[in] str  調査対象のテキスト 
 * @param[in] _str 調査対象のテキスト 
 * @return 同じか否か
 */
+(BOOL)isEqualToStrings:(NSString*)str :(NSString*)_str;

/**
 * @brief 文字列が指定した長さより長いか否かを判定します。
 * @param[in] text 調査対象のテキスト 
 * @param[in] max 最大値の文字数 
 * @return 指定した長さより長くなければNO,長ければYES
 */
+(BOOL)isMaxLength:(NSString*)text maxLength:(NSUInteger)max;

/**
 * @brief 空白文字を含むか否かを判定します。
 * @param[in] text  調査対象のテキスト 
 * @return 含むか否か
 */
+(BOOL)isIncludedSpace:(NSString*)text;

/**
 * @brief 与えられた文字列がユーザネームのバリデーション制限を満たしているか否かを判定します。
 * @param[in] text 調査対象のテキスト 
 * @return 正しいユーザネームならYES,不正なユーザネームならNO
 */
+(BOOL)isLegalUserName:(NSString*)text;

@end
