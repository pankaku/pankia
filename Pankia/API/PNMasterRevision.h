//
//  PNMasterRevision.h
//  PankakuNet
//
//  Created by sota2 on 10/11/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! \brief アチーブメントや商品などのマスターデータのリビジョンを管理するクラス
 * 
 * アチーブメントや商品などのマスターデータのリビジョンを管理するクラスです。
 * サーバー上のgame/revisionにおける返り値をもとに内容がセットされます。
 * 各要素におけるリビジョンをプロパティで参照できます。
 * ローカルに保持されているリビジョンを+[PNMasterRevision currentRevision]として取得できます。
 * isEqual:メソッドを使って、マスターデータに変更があったかどうかを調べる事ができます。
 */
@interface PNMasterRevision : NSObject<NSCoding> {
	NSDictionary *originalDictionary;	/**! サーバーからのJSONをパースして作られたDictionaryモデル **/
}
@property (nonatomic, readonly) int achievements;
@property (nonatomic, readonly) int categories;
@property (nonatomic, readonly) int features;
@property (nonatomic, readonly) int grades;
@property (nonatomic, readonly) int items;
@property (nonatomic, readonly) int leaderboards;
@property (nonatomic, readonly) int lobbies;
@property (nonatomic, readonly) int merchandises;
@property (nonatomic, readonly) int total;
@property (nonatomic, readonly) int versions;

/*! サーバーからのJSONデータ(をパースして作ったDictionary)を元にPNMasterRevisionモデルのインスタンスを生成して返します。autorelease済み。
 */
+ (id)masterRevisionWithDictionary:(NSDictionary*)dictionary;

/*! ローカルに保持されているマスターデータのリビジョン情報が含まれるインスタンスを返します。
 */
+ (id)currentRevision;

/*! 現在のインスタンスをローカルのマスターデータのリビジョン情報として保存します。
 */
- (void)saveAsCurrent;

@end
