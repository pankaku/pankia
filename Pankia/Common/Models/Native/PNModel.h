//
//  PNModel.h
//  PankakuNet
//
//  Created by 横江 宗太 on 10/11/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

/**!
 * @brief アチーブメントやリーダーボード等、PANKIA内でモデルとして扱われるクラスの根底クラスです。
 *
 * このクラスはJSONデータモデル(PNDataModel)からインスタンスを生成することが可能です。
 * また、isAvailableメソッド等を使う事で、現在のバージョンにおいてモデルが有効かどうかを判定することもできます。
 */
@interface PNModel : NSObject {
	int			minVersion;
	int			maxVersion;
}
@property (assign, readonly) int		minVersion;
@property (assign, readonly) int		maxVersion;

// イニシャライザ系
/**! JSONデータモデルからインスタンスを生成するためのイニシャライザです **/
- (id)initWithDataModel:(PNDataModel*)dataModel;
/**! JSONデータモデルから、autorelease済みのインスタンスを生成します **/
+ (id)modelFromDataModel:(PNDataModel*)dataModel;
/**! JSONデータモデルの配列から、autorelease済みインスタンスの配列を生成します **/
+ (NSArray*)modelsFromDataModels:(NSArray*)dataModels;
/**! JSONデータモデルの配列から、指定のバージョンで有効なautorelease済みインスタンスの配列を生成します **/
+ (NSArray*)modelsFromDataModels:(NSArray*)dataModels availableInVersion:(int)versionNumber;

/**! 特定のバージョンで有効かどうかを返します **/
- (BOOL)isAvailable:(int)versionNumber;

@end
