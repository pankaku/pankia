//
//  PNMasterSynchronizer.m
//  PankakuNet
//
//  Created by sota2 on 10/11/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMasterSynchronizer.h"
#import "PNGameManager.h"
#import "PNArchiveManager.h"

#import "PNItem.h"

#import "PNMasterRevision.h"
#import "PNError.h"

@interface PNMasterSynchronizer()
@property (nonatomic, retain) id<PNMasterSynchronizerDelegate> delegate;	// このオブジェクトはdelegateをretainします
@property (nonatomic, retain) PNMasterRevision* revisionInfo;
@property (nonatomic, retain) PNMasterRevision* currentRevision;
- (void)start;
- (void)synchronizeMerchandises;
- (void)synchronizeLeaderboards;
- (void)synchronizeAchievements;
- (void)synchronizeCategories;
- (void)synchronizeFeatures;
- (void)synchronizeGrades;
- (void)synchronizeItems;
- (void)synchronizeLobbies;
- (void)synchronizeVersions;
- (void)synchronizationDone;
@end

// PLISTをサーバーと同期するためのオブジェクトです。
@implementation PNMasterSynchronizer
@synthesize delegate, revisionInfo, currentRevision;

/**! 同期処理を開始するためのメソッドです。外のクラスから呼ばれます。
 * 新しいインスタンスを生成した上で、そのインスタンスのインスタンスメソッドを読んで処理を開始しています。
 * 現時点では-[PNManager onLoggedIn]内からしか呼ばれる可能性がないため、対策をとっていませんが、
 * 将来複数の箇所から同時に呼ばれる可能性がある場合は、インスタンスが同時に複数生成されないように対策をとった方が好ましいです。
 */
+ (id)startWithDelegate:(id<PNMasterSynchronizerDelegate>)aDelegate
{
	// このインスタンスは、処理完了までリリースされてはいけないのでautoreleaseされません。
	// 処理が完了した段階で自分でautoreleaseします。
	PNMasterSynchronizer* anInstance = [[PNMasterSynchronizer alloc] init];
	anInstance.delegate = aDelegate;
	
	[anInstance start];	// 処理をスタートします

	return anInstance;
}
- (void)dealloc{
	self.currentRevision = nil;
	self.revisionInfo = nil;
	self.delegate = nil;
	[super dealloc];
}

#pragma mark -
// 同期処理が完了／失敗したときに呼ばれるメソッドです。
// この中で自身をautoreleaseしています。
- (void)onNoChanges
{
	[self autorelease];
	if ([delegate respondsToSelector:@selector(masterSynchronizationDone)]) {
		[delegate masterSynchronizationDone];
	}
}
- (void)onSucceeded
{
	// 同期したリビジョン情報を記録しておきます
	[revisionInfo saveAsCurrent];
	
	[self autorelease];
	if ([delegate respondsToSelector:@selector(masterSynchronizationDone)]) {
		[delegate masterSynchronizationDone];
	}
	
// 内容の確認用
//	NSLog(@"%@", [[PNGameManager sharedObject] latestAchievementsJSONString]);
//	NSLog(@"%@", [[PNGameManager sharedObject] latestCategoriesJSONString]);
//	NSLog(@"%@", [[PNGameManager sharedObject] latestGradesJSONString]);
//	NSLog(@"%@", [[PNGameManager sharedObject] latestItemsJSONString]);
//	NSLog(@"%@", [[PNGameManager sharedObject] latestLeaderboardsJSONString]);
//	NSLog(@"%@", [[PNGameManager sharedObject] latestLobbiesJSONString]);
//	NSLog(@"%@", [[PNGameManager sharedObject] latestMerchandisesJSONString]);
//	NSLog(@"%@", [[PNGameManager sharedObject] latestVersionsJSONString]);
}

/**! 処理に失敗した場合に、このメソッドが呼ばれるようになっています。
 * 自身をautoreleaseし、delegateに同期処理が失敗したことを通知します。
 * 同期処理の途中に通信に失敗した場合などに呼ばれる可能性があります。 */
- (void)onFailed:(PNError*)error
{
	[self autorelease];
	if ([delegate respondsToSelector:@selector(masterSynchronizationFailed)]) {
		[delegate masterSynchronizationFailed];
	}
}
#pragma mark -
- (void)start
{
	// Get latest master data revisions from the server.
	[[PNGameManager sharedObject] getMasterDataRevisionsWithOnSuccess:^(PNMasterRevision *masterRevision) {
		
		PNMasterRevision* currentRevision_ = [PNMasterRevision currentRevision];
		
		// Check if cache data for current(local) revisions valid or not.
		if (![[PNGameManager sharedObject] isAllJSONCachesAvailable]) currentRevision_ = nil;
		
		if ([masterRevision isEqual:currentRevision_]) {
			// 変更がなければ、ここで同期は完了です
			[self onNoChanges];
			return;
		}
		
		self.currentRevision = currentRevision_;
		self.revisionInfo = masterRevision;
		
		// 2. 商品一覧のマスターを同期します。
		[self synchronizeMerchandises];
	} onFailure:^(PNError *error) {
		PNWarn(@"getMasterDataRevisions error. %@", error);
		[self onFailed:error];
	}];
}

#pragma mark -
- (void)synchronizeMerchandises
{
	// merchandisesの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.merchandises == revisionInfo.merchandises) {
		[self synchronizeLeaderboards];
	} else{
		// サーバーに最新のmerchandisesを取得しにいきます
		[[PNGameManager sharedObject] getMerchandisesWithDelegate:self onSucceeded:@selector(getMerchandisesDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getMerchandisesDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeMerchandises revision:revisionInfo.merchandises];
	
	[self synchronizeLeaderboards];
}
#pragma mark -
- (void)synchronizeLeaderboards
{
	// leaderboardsの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.leaderboards == revisionInfo.leaderboards) {
		[self synchronizeAchievements];
	} else {
		// サーバーに最新のleaderboardsを取得しにいきます
		[[PNGameManager sharedObject] getLeaderboardsWithDelegate:self onSucceeded:@selector(getLeaderboardsDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getLeaderboardsDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeLeaderboards revision:revisionInfo.leaderboards];
	
	[self synchronizeAchievements];
}
#pragma mark -
- (void)synchronizeAchievements
{
	// achievementsの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.achievements == revisionInfo.achievements) {
		[self synchronizeCategories];
	} else {
		// サーバーに最新のachievementsを取得しにいきます
		[[PNGameManager sharedObject] getAchievementsWithDelegate:self onSucceeded:@selector(getAchievementsDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getAchievementsDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeAchievements revision:revisionInfo.achievements];
	
	[self synchronizeCategories];
}
#pragma mark -
- (void)synchronizeCategories
{
	// categoriesの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.categories == revisionInfo.categories) {
		[self synchronizeFeatures];
	} else {
		// サーバーに最新のcategoriesを取得しにいきます
		[[PNGameManager sharedObject] getCategoriesWithDelegate:self onSucceeded:@selector(getCategoriesDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getCategoriesDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeCategories revision:revisionInfo.categories];
	
	[self synchronizeFeatures];
}
#pragma mark -
- (void)synchronizeFeatures
{
	// 2010.11.25現在featuresはsession/createの中に含まれており、別個に取得しにいくAPIも存在せず、必要もないためスキップします。
	[self synchronizeGrades];
	/*
	// featuresの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.features == revisionInfo.features) {
		[self synchronizeGrades];
	} else {
		// サーバーに最新のfeaturesを取得しにいきます
		[[PNGameManager sharedObject] getFeaturesWithDelegate:self onSucceeded:@selector(getFeaturesDone:) onFailed:@selector(onFailed:)];
	}*/
}
- (void)getFeaturesDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeFeatures revision:revisionInfo.features];
	
	[self synchronizeGrades];
}
#pragma mark -
- (void)synchronizeGrades
{
	// 2010.12.02現在gradesはv2では仕様しないためスキップします。
	[self synchronizeItems];
	return;
	// gradesの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.grades == revisionInfo.grades) {
		[self synchronizeItems];
	} else {
		// サーバーに最新のgradesを取得しにいきます
		[[PNGameManager sharedObject] getGradesWithDelegate:self onSucceeded:@selector(getGradesDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getGradesDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeGrades revision:revisionInfo.grades];
	
	[self synchronizeItems];
}
#pragma mark -
- (void)synchronizeItems
{
	// itemsの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.items == revisionInfo.items) {
		[self synchronizeLobbies];
	} else {
		// サーバーに最新のleaderboardsを取得しにいきます
		[[PNGameManager sharedObject] getItemsWithDelegate:self onSucceeded:@selector(getItemsDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getItemsDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeItems revision:revisionInfo.items];
	
	[self synchronizeLobbies];
}
#pragma mark -
- (void)synchronizeLobbies
{
	// lobbiesの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.lobbies == revisionInfo.lobbies) {
		[self synchronizeVersions];
	} else {
		// サーバーに最新のlobbiesを取得しにいきます
		[[PNGameManager sharedObject] getLobbiesWithDelegate:self onSucceeded:@selector(getLobbiesDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getLobbiesDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeLobbies revision:revisionInfo.lobbies];
	
	[self synchronizeVersions];
}
#pragma mark -
- (void)synchronizeVersions
{
	// 2010.12.02現在versionsは必要ないのでスキップします
	[self synchronizationDone];
	return;
	// versionsの変更がなければスキップします。
	if (currentRevision != nil && currentRevision.versions == revisionInfo.versions) {
		[self synchronizationDone];
	} else {
		// サーバーに最新のversionを取得しにいきます
		[[PNGameManager sharedObject] getVersionsWithDelegate:self onSucceeded:@selector(getVersionsDone:) onFailed:@selector(onFailed:)];
	}
}
- (void)getVersionsDone:(NSString*)responseString
{
	// ローカルにJSONの内容を保存しておきます
	[[PNGameManager sharedObject] saveMasterString:responseString forRevisedObject:PNRevisedObjectTypeVersions revision:revisionInfo.versions];
	
	[self synchronizationDone];
}

- (void)synchronizationDone
{
	[self onSucceeded];
}
@end
