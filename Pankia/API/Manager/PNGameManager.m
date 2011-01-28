//
//  PNGameManager.m
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGameManager.h"

#import "PNRequestKeyManager.h"
#import "PNArchiveManager.h"
#import "PNSettingManager.h"
#import "PNAchievementManager.h"
#import "PNLeaderboardManager.h"
#import "PNGlobalManager.h"

#import "PNLogger+Package.h"
#import "PNGameModel.h"
#import "Helpers.h"
#import "NSDictionary+GetterExt.h"
#import "PNMasterRevision.h"

#import "PNAchievement.h"
#import "PNAchievement+Package.h"
#import "PNAchievementModel.h"
#import "PNItemCategory.h"
#import "PNItemCategoryModel.h"
#import "PNItem.h"
#import "PNItemManager.h"
#import "PNItemModel.h"
#import "PNLeaderboardModel.h"
#import "PNLeaderboard.h"
#import "PNLobbyModel.h"
#import "PNLobby.h"
#import "PNMerchandiseModel.h"
#import "PNMerchandise.h"

// Request Helpers
#import "PNGameRequestHelper.h"
#import "PNStoreRequestHelper.h"
#import "PNLeaderboardRequestHelper.h"
#import "PNAchievementRequestHelper.h"
#import "PNRoomRequestHelper.h"

#import "NSString+VersionString.h"
#import "PNError.h"

#define kPNLastPlistSyncDate @"PN_LAST_PLIST_SYNC_DATE"


static PNGameManager* _sharedInstance;


@interface PNGameManager()
@property (nonatomic, retain) NSArray* cachedLatestCategories;
@property (nonatomic, retain) NSArray* cachedLatestItems;
@property (nonatomic, retain) NSArray* cachedLatestMerchandises;
@end

@implementation PNGameManager
@synthesize cachedLatestCategories, cachedLatestItems, cachedLatestMerchandises;

- (void)getDetailsOfGame:(NSString*)gameId
				delegate:(id)delegate
			 onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector {

	PNLogMethodName;
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNGameRequestHelper getDetailsOfGame:gameId delegate:self selector:@selector(getDetailsOfGameDone:) requestKey:requestKey];
}
- (void)getDetailsOfGameDone:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSDictionary* json = [response jsonDictionary];
	
	if (response.isValidAndSuccessful) {
		PNGameModel* gameModel = [PNGameModel dataModelWithDictionary:[json objectForKey:J_GAME]];
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:gameModel];
	} else {
		[PNRequestKeyManager callOnFailedSelectorAndRemove:requestKey withObject:nil];
	}
}

#pragma mark -

- (int)currentVersionIntValue {
	PNLogMethodName;
	return [[self currentVersionStringValue] versionIntValue];
}
- (NSString*)currentVersionStringValue
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark -

- (NSDate *)lastPlistSyncDate {
	PNLogMethodName;
	NSDate* lastPlistSyncDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kPNLastPlistSyncDate];
	if (lastPlistSyncDate) {
		return lastPlistSyncDate;
	} else {
		return [NSDate dateWithTimeIntervalSince1970:0];
	}
}

#pragma mark -

+ (NSString*)keyForRevisedObject:(PNRevisedObjectType)revisedObject {
	PNLogMethodName;
	switch (revisedObject) {
		case PNRevisedObjectTypeMerchandises:
			return @"merchandises";
			break;
		case PNRevisedObjectTypeAchievements:
			return @"achievements";
			break;
		case PNRevisedObjectTypeCategories:
			return @"categories";
			break;
		case PNRevisedObjectTypeFeatures:
			return @"features";
			break;
		case PNRevisedObjectTypeGrades:
			return @"grades";
			break;
		case PNRevisedObjectTypeItems:
			return @"items";
			break;
		case PNRevisedObjectTypeLeaderboards:
			return @"leaderboards";
			break;
		case PNRevisedObjectTypeLobbies:
			return @"lobbies";
			break;
		case PNRevisedObjectTypeVersions:
			return @"versions";
			break;
		default:
			return @"unknown-revised-object";
			break;
	}
}

- (NSString*)fileNameWithRevisedObject:(PNRevisedObjectType)objectType revision:(int)revision {
	PNLogMethodName;
	return [NSString stringWithFormat:@"master-%@-%@-r%d-v%d.json", [PNGameManager keyForRevisedObject:objectType], [[PNSettingManager sharedObject] preferedLanguage],
			revision, [self currentVersionIntValue]];
}

- (void)saveMasterString:(NSString*)string forRevisedObject:(PNRevisedObjectType)objectType revision:(int)revision {
	PNLogMethodName;
	[PNArchiveManager archiveString:string toFile:[self fileNameWithRevisedObject:objectType revision:revision]];
}

- (void)getMasterDataRevisionsWithOnSuccess:(void (^)(PNMasterRevision* masterRevision))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandGameRevision onSuccess:^(PNHTTPResponse *response) {
		if (response.isValidAndSuccessful) {
			PNMasterRevision * masterRevision = [PNMasterRevision masterRevisionWithDictionary:[response.jsonDictionary objectForKey:@"revision"]];
			onSuccess(masterRevision);
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
#pragma mark -

// このメソッドはHTTPリクエストに対するコールバックメソッドです。
// レスポンスの返り値のJSONにstatus=okがついていれば、そのリクエストに指定されているonSucceededメソッドに引数でJSONをそのまま返します。
// status=ngの場合はonFailedで指定されているメソッドを呼びます。
- (void)defaultResponse:(PNHTTPResponse*)response
{
	if (response.isValidAndSuccessful) {
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:response.requestKey withObject:response.jsonString];
	} else {
		[PNRequestKeyManager callOnFailedSelectorAndRemove:response.requestKey withErrorFromResponse:response.jsonString];
	}
}


- (void)getAchievementsWithDelegate:(id)delegate 
						onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector {
	PNLogMethodName;
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNAchievementRequestHelper getAchievementsWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];
}

- (void)getCategoriesWithDelegate:(id)delegate 
					  onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector {
	PNLogMethodName;
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNGameRequestHelper getCategoriesWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];
}

- (void)getGradesWithDelegate:(id)delegate 
				  onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector {
	PNLogMethodName;
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNGameRequestHelper getGradesWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];
}

- (void)getItemsWithDelegate:(id)delegate 
				 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector {
	PNLogMethodName;
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNGameRequestHelper getItemsWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];	
}
- (void)getLeaderboardsWithDelegate:(id)delegate 
						onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNLeaderboardRequestHelper leaderboardsWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];
}
- (void)getLobbiesWithDelegate:(id)delegate 
				   onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector {
	PNLogMethodName;
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNRoomRequestHelper findLobbiesWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];	
}
- (void)getMerchandisesWithDelegate:(id)delegate 
						onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNStoreRequestHelper getMerchandisesWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];
}
- (void)getVersionsWithDelegate:(id)delegate 
					onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector {
	PNLogMethodName;
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNGameRequestHelper getVersionsWithDelegate:self selector:@selector(defaultResponse:) requestKey:requestKey];		
}

#pragma mark -

- (NSString*)latestJSONStringForRevisedObject:(PNRevisedObjectType)objectType {
	PNLogMethodName;
	PNMasterRevision* currentRevision = [PNMasterRevision currentRevision];
	if (currentRevision) {
		int revisionNumber = -1;
		switch (objectType) {
			case PNRevisedObjectTypeAchievements:
				revisionNumber = currentRevision.achievements;
				break;
			case PNRevisedObjectTypeCategories:
				revisionNumber = currentRevision.categories;
				break;
			case PNRevisedObjectTypeFeatures:
				revisionNumber = currentRevision.features;
				break;
			case PNRevisedObjectTypeGrades:
				revisionNumber = currentRevision.grades;
				break;
			case PNRevisedObjectTypeItems:
				revisionNumber = currentRevision.items;
				break;
			case PNRevisedObjectTypeLeaderboards:
				revisionNumber = currentRevision.leaderboards;
				break;
			case PNRevisedObjectTypeLobbies:
				revisionNumber = currentRevision.lobbies;
				break;
			case PNRevisedObjectTypeMerchandises:
				revisionNumber = currentRevision.merchandises;
				break;
			case PNRevisedObjectTypeVersions:
				revisionNumber = currentRevision.versions;
				break;
			default:
				break;
		}
		return [PNArchiveManager unarchiveStringWithFile:[self fileNameWithRevisedObject:objectType revision:revisionNumber]];
	} else {
		return nil;
	}
}

#pragma mark -

- (NSString*)latestAchievementsJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeAchievements];
}

- (NSString*)latestCategoriesJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeCategories];
}

- (NSString*)latestGradesJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeGrades];
}

- (NSString*)latestItemsJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeItems];
}

- (NSString*)latestLeaderboardsJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeLeaderboards];
}

- (NSString*)latestLobbiesJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeLobbies];
}

- (NSString*)latestMerchandisesJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeMerchandises];
}

- (NSString*)latestVersionsJSONString {
	PNLogMethodName;
	return [self latestJSONStringForRevisedObject:PNRevisedObjectTypeVersions];
}

#pragma mark -

- (NSArray*)latestAchievements {
	PNLogMethodName;
	NSString* latestJSON = [self latestAchievementsJSONString];
	if (latestJSON == nil) return nil;
	
	NSDictionary* json = [latestJSON JSONValue];
	NSArray* models = [PNAchievementModel dataModelsFromArray:[json objectForKey:@"achievements"]];
	return [PNAchievement modelsFromDataModels:models availableInVersion:[self currentVersionIntValue]];
}

- (NSArray*)latestCategories {
	PNLogMethodName;
	if (cachedLatestCategories) return cachedLatestCategories;
	
	NSString* latestJSON = [self latestCategoriesJSONString];
	if (latestJSON == nil) return nil;
	
	if (cachedLatestCategories == nil) {
		NSDictionary* json = [latestJSON JSONValue];
		NSArray* models = [PNItemCategoryModel dataModelsFromArray:[json objectForKey:@"categories"]];
		self.cachedLatestCategories = [PNItemCategory modelsFromDataModels:models availableInVersion:[self currentVersionIntValue]];
	}
	return self.cachedLatestCategories;
}

- (NSArray*)latestItems {
	PNLogMethodName;
	if (cachedLatestItems) return cachedLatestItems;
	
	NSString* latestJSON = [self latestItemsJSONString];
	if (latestJSON == nil) return nil;
	
	if (cachedLatestItems == nil) {
		NSDictionary* json = [latestJSON JSONValue];
		NSArray* models = [PNItemModel dataModelsFromArray:[json objectForKey:@"items"]];
		self.cachedLatestItems = [PNItem modelsFromDataModels:models availableInVersion:[self currentVersionIntValue]];
	}
	return self.cachedLatestItems;
}

- (NSArray*)latestLeaderboards {
	PNLogMethodName;
	NSString* latestJSON = [self latestLeaderboardsJSONString];
	if (latestJSON == nil) return nil;

	NSDictionary* json = [latestJSON JSONValue];
	NSArray* models = [PNLeaderboardModel dataModelsFromArray:[json objectForKey:@"leaderboards"]];
	return [PNLeaderboard modelsFromDataModels:models availableInVersion:[self currentVersionIntValue]];
}

- (NSArray*)latestLobbies {
	PNLogMethodName;
	NSString* latestJSON = [self latestLobbiesJSONString];
	if (latestJSON == nil) return nil;
	
	NSDictionary* json = [latestJSON JSONValue];
	NSArray *models = [PNLobbyModel dataModelsFromArray:[json objectForKey:@"lobbies"]];
	return [PNLobby modelsFromDataModels:models availableInVersion:[self currentVersionIntValue]];
}
- (NSArray*)latestMerchandises 
{
	if (cachedLatestMerchandises) return cachedLatestMerchandises;
	
	NSString* latestJSON = [self latestMerchandisesJSONString];
	if (latestJSON == nil) return nil;
	
	if (cachedLatestMerchandises == nil) {
		NSDictionary* json = [latestJSON JSONValue];
		NSArray *models = [PNMerchandiseModel dataModelsFromArray:[json objectForKey:@"merchandises"]];
		self.cachedLatestMerchandises = [PNMerchandise modelsFromDataModels:models availableInVersion:[self currentVersionIntValue]];
	}
	
	return cachedLatestMerchandises;
}
#pragma mark -

- (NSArray*) achievements {
	PNLogMethodName;
	NSArray* latestObjects = [self latestAchievements];
	if (latestObjects != nil) return latestObjects;
	
	return [PNAchievementManager sharedObject].achievementDetails;
}

- (NSArray*) categories {
	PNLogMethodName;
	NSArray* latestObjects = [self latestCategories];
	if (latestObjects != nil) return latestObjects;
	
	return [PNItemManager sharedObject].categoryArray;	
}

- (NSArray*)items {
	PNLogMethodName;
	NSArray* latestObjects = [self latestItems];
	if (latestObjects != nil) return latestObjects;
	
	return [PNItemManager sharedObject].itemArray;	
}

- (NSArray*) leaderboards {
	PNLogMethodName;
	NSArray* latestObjects = [self latestLeaderboards];
	if (latestObjects != nil) return latestObjects;
	
	return [PNLeaderboardManager sharedObject].leaderboardsFromPlist;
}

- (NSArray*) lobbies {
	PNLogMethodName;
	NSArray* latestObjects = [self latestLobbies];
	if (latestObjects != nil) return latestObjects;
	
	return [[PNSettingManager sharedObject] lobbies];
}
- (NSArray*) merchandises
{
	NSArray* latestObjects = [self latestMerchandises];
	if (latestObjects != nil) return latestObjects;
	
	return [NSArray array];
}
#pragma mark -

- (BOOL)isAllJSONCachesAvailable {
	PNLogMethodName;
	PNRevisedObjectType objectTypes[] = {PNRevisedObjectTypeAchievements, PNRevisedObjectTypeCategories, //PNRevisedObjectTypeGrades, 
		PNRevisedObjectTypeItems, PNRevisedObjectTypeLeaderboards, PNRevisedObjectTypeLobbies, PNRevisedObjectTypeMerchandises //, PNRevisedObjectTypeVersions
		};
	for (int i=0; i< 6; i++) {
		NSString* cachedString = [self latestJSONStringForRevisedObject:objectTypes[i]];
		if (cachedString == nil) {
			return NO;
		}
	}
	return YES;
}

#pragma mark -
- (void)setFeatures:(NSArray *)enabledFeatures
{
	for(NSString* enabledFeature in enabledFeatures) {
		if ([enabledFeature isEqualToString:@"match"]) {
			[PNSettingManager sharedObject].matchEnabled = YES;
			[[PNGlobalManager sharedObject] setObject:[NSNumber numberWithBool:YES] forKey:@"match_enabled"];
		} else if ([enabledFeature isEqualToString:@"coin"]) {
			[[PNGlobalManager sharedObject] setObject:[NSNumber numberWithBool:YES] forKey:@"coin_enabled"];
		} else if ([enabledFeature isEqualToString:@"item"]) {
			[[PNGlobalManager sharedObject] setObject:[NSNumber numberWithBool:YES] forKey:@"item_enabled"];
		}
	}
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	PNLogMethodName;
	if (self = [super init]) {	
	}
	return self;
}

- (void) dealloc {
	PNLogMethodName;
	self.cachedLatestCategories = nil;
	self.cachedLatestItems = nil;
	self.cachedLatestMerchandises = nil;
	[super dealloc];
}

+ (PNGameManager *)sharedObject {
	PNLogMethodName;
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	PNLogMethodName;
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone {
	PNLogMethodName;
	return self;
}

- (id)retain {
	PNLogMethodName;
	return self;
}

- (unsigned)retainCount {
	PNLogMethodName;
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release {
	PNLogMethodName;
	// 何もしない
}

- (id)autorelease {
	PNLogMethodName;
	return self;
}

@end
