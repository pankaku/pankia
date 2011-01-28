//
//  PNGameManager.h
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAbstractManager.h"

typedef enum 
{
	PNRevisedObjectTypeAchievements,
	PNRevisedObjectTypeCategories,
	PNRevisedObjectTypeFeatures,
	PNRevisedObjectTypeGrades,
	PNRevisedObjectTypeItems,
	PNRevisedObjectTypeLeaderboards,
	PNRevisedObjectTypeLobbies,
	PNRevisedObjectTypeMerchandises,
	PNRevisedObjectTypeTotal,
	PNRevisedObjectTypeVersions
} PNRevisedObjectType;

@class PNError;
@class PNMasterRevision;
@interface PNGameManager : PNAbstractManager {
	NSArray* cachedLatestCategories;
	NSArray* cachedLatestItems;
	NSArray* cachedLatestMerchandises;
}
+ (PNGameManager*)sharedObject;
- (void)getDetailsOfGame:(NSString*)gameId delegate:(id)delegate 
			 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getMasterDataRevisionsWithOnSuccess:(void (^)(PNMasterRevision *masterRevision))onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (NSDate*)lastPlistSyncDate;

/*! 現在のバージョンをintで返します */
- (int)currentVersionIntValue;
- (NSString*)currentVersionStringValue;

// ここから下は、マスターのキャッシュ用のAPIです。
- (void)getMerchandisesWithDelegate:(id)delegate 
						onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getLeaderboardsWithDelegate:(id)delegate 
						onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getAchievementsWithDelegate:(id)delegate 
						onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getCategoriesWithDelegate:(id)delegate 
					  onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getGradesWithDelegate:(id)delegate 
				  onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getItemsWithDelegate:(id)delegate 
				 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getLobbiesWithDelegate:(id)delegate 
				   onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getVersionsWithDelegate:(id)delegate 
					onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;

// ローカルにキャッシュされている、最新のJSON文字列を返すメソッドです。
- (NSString*)latestAchievementsJSONString;
- (NSString*)latestCategoriesJSONString;
- (NSString*)latestGradesJSONString;
- (NSString*)latestItemsJSONString;
- (NSString*)latestLeaderboardsJSONString;
- (NSString*)latestLobbiesJSONString;
- (NSString*)latestMerchandisesJSONString;
- (NSString*)latestVersionsJSONString;

// ローカルにキャッシュされているJSON文字列を元に生成したオブジェクトの配列を返すメソッドです。
// キャッシュされているJSON文字列がない場合にはnilを返します。
// PANKIA内でマスター情報を参照したい場合は、基本的にはこちらのメソッドによって生成された情報を優先します。
// この情報が使用できない場合は、PNOfflineSettings.plistから生成した情報を使用します。
// 現在実行中のバージョンにおいて無効なものは除外されます。
- (NSArray*)latestAchievements;
- (NSArray*)latestCategories;
- (NSArray*)latestItems;
- (NSArray*)latestLeaderboards;
- (NSArray*)latestLobbies;
- (NSArray*)latestMerchandises;

// latestAchievements等は、JSONキャッシュから生成されますが、キャッシュが存在しない時(一度もオンラインになっていない状態)
// は使用できません。下記のメソッドは、キャッシュが利用可能な場合は最新のキャッシュから生成したオブジェクトを、
// キャッシュが使用できない場合はplistから生成したオブジェクトを返します。
// 通常はlatest〜よりこちらのメソッドを使った方が便利です。
- (NSArray*)achievements;
- (NSArray*)categories;
- (NSArray*)items;
- (NSArray*)leaderboards;
- (NSArray*)lobbies;
- (NSArray*)merchandises;	//※ただしmerchandisesだけは、オフライン状態でキャッシュがない場合は空のarrayを返します。

/*! キャッシュに欠損がないかを調べます */
- (BOOL)isAllJSONCachesAvailable;
+ (NSString*)keyForRevisedObject:(PNRevisedObjectType)revisedObject;

/*! フィーチャーをセットします */
- (void)setFeatures:(NSArray*)enabledFeatures;

/*! マスター情報のJSON文字列のキャッシュを保存します */
- (void)saveMasterString:(NSString*)string forRevisedObject:(PNRevisedObjectType)objectType revision:(int)revision;
@end
