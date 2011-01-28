//
//  PNJSONCacheManager.h
//  PankakuNet
//
//  Created by sota2 on 10/12/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**!
 @brief サーバーから返ってきたJSONデータをキャッシュするためのマネージャです
 *
 * これは主にPHASE 3以降のUIWebViewベースのダッシュボードからのデータ要求に応えるときのために使用されます。
 * キャッシュはユーザ、言語単位で保存されています。
 */
@interface PNJSONCacheManager : NSObject {

}
+ (PNJSONCacheManager*)sharedObject;
- (void)deleteCacheNamed:(NSString*)cacheName;
- (void)saveCacheNamed:(NSString*)cacheName text:(NSString*)text;
- (NSString*)cacheNamed:(NSString*)cacheName;
@end
