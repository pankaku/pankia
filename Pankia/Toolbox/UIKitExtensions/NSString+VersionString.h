
/**
 バージョンを表現する文字列（1.02.33等）をintに変換する機能を提供します
 */
@interface NSString (VersionString)

- (int)versionIntValue;

@end
