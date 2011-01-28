//
//  PNImageUtil.h
//  PankakuNet
//
//  Created by pankaku on 10/08/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PNImageUtil : NSObject {

}
// 角丸処理を施した画像を返します
+ (UIImage*)roundCorneredImage:(UIImage*)sourceImage width:(float)width height:(float)height;
+ (UIImage*)imageWithPadding:(UIImage*)sourceImage left:(float)left top:(float)top right:(float)right bottom:(float)bottom;
+ (UIImage*)imageWithPadding:(UIImage*)sourceImage left:(float)left top:(float)top right:(float)right bottom:(float)bottom width:(float)width height:(float)height;

// キャッシュがあるかどうかを返します
+ (BOOL)hasCacheForUrl:(NSString*)url;
+ (void)createCacheForUrl:(NSString*)url;
+ (NSString*)cacheFilePathForURL:(NSString*)url;

@end
