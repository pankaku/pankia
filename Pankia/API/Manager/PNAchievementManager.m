#import "PNAchievementManager.h"
#import "PNAchievement.h"
#import "PNAchievement+Package.h"
#import "PNAchievementRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "NSString+VersionString.h"
#import "PNRequestKeyManager.h"
#import "JsonHelper.h"
#import "PNAchievementRequestQueue.h"
#import "PNLogger+Package.h"
#import "PNSettingManager.h"
#import "PNAchievementModel.h"
#import <GameKit/GameKit.h>
#import "PNGameManager.h"
#import "PNJSONCacheManager.h"
#import "PNManager.h"
#import "PNNotificationNames.h"

#define kPNAchievementUnlockErrorCodeNotFound		@"not_found"


PNAchievementManager *_sharedAchievementManager = nil;

@interface PNAchievementManager(Private)
- (NSArray*) achievementDetailsInCurrentLocale;
- (void) showAchievements;
- (void)loadGameCenterAchievement;
@end


@implementation PNAchievementManager
@synthesize achievementDetails, totalPoints, gameCenterAchievementDictionary;

- (BOOL)isAchievementUnlocked:(int)id
{
	for (PNAchievement* achievement in [self unlockedAchievements]) {
		if (achievement.id == id) return YES;
	}
	return NO;
}

- (NSArray*)unlockedAchievements
{
	// ログインしていなかったらローカルに無いか探しに行く。
	NSArray* unlockedAchievementIds = [[PNLocalAchievementDB sharedObject] 
									   unlockedAchievementIdsOfUser:[PNUser currentUser] != nil ? [[PNUser currentUser].userId intValue] : 0];
	
	NSMutableArray* unlockedAchievements = [NSMutableArray array];
	for (NSNumber* unlockedAchievementId in unlockedAchievementIds){
		PNAchievement* achievement = [self achievementById:[unlockedAchievementId intValue]];
		if (achievement != nil)
			[unlockedAchievements addObject:achievement];
	}
	
	return unlockedAchievements;
}

- (void)unlockAchievementById:(int)achievementId{
	
	[[PNJSONCacheManager sharedObject] deleteCacheNamed:@"unlocked_achievements"];
	
	//まずはじめにローカルに保存します
	[[PNLocalAchievementDB sharedObject] unlockAchievement:achievementId delegate:self userId:[[PNUser currentUser].userId intValue]];
	
	//サーバーに保存します
	if ([PNManager sharedObject].isLoggedIn){
		[[PNAchievementRequestQueue sharedObject] addUnlockRequest:[NSArray arrayWithObjects:[NSNumber numberWithInt:achievementId],nil]];
	}
	
	// begin - lerry added code
	[self uploadAchievementToGameCenter:achievementId];
	// end - lerry added code
}

- (void)unlockAchievements:(NSArray*)achievements{
	//まずはじめにローカルに保存します
	for (id achievementObj in achievements){
		int achievementId = 0;
		if ([achievementObj isKindOfClass:[PNAchievement class]]){
			achievementId = ((PNAchievement*)achievementObj).achievementId;
		}
		if ([achievementObj isKindOfClass:[NSNumber class]]){
			achievementId = [(NSNumber*)achievementObj intValue];
		}
		[[PNLocalAchievementDB sharedObject] unlockAchievement:achievementId delegate:self userId:[[PNUser currentUser].userId intValue]];
	}
	
	//サーバーに送信します
	//解放するアチーブメントのIDの配列を作ります
	NSMutableArray* achievementIdArray = [NSMutableArray array];
	for (id achievementObj in achievements){
		if ([achievementObj isKindOfClass:[PNAchievement class]]){
			[achievementIdArray addObject:[NSNumber numberWithInt:((PNAchievement*)achievementObj).achievementId]];
		}
		if ([achievementObj isKindOfClass:[NSNumber class]]){
			[achievementIdArray addObject:achievementObj];
		}
	}
	if ([PNManager sharedObject].isLoggedIn){
		[[PNAchievementRequestQueue sharedObject] addUnlockRequest:achievementIdArray];
	}
}

-(void)unlockAchievementResponse:(PNHTTPResponse*)response
{		
	NSDictionary* json = [response jsonDictionary];
	NSString* resp = [response jsonString];
	
	if(response.isValidAndSuccessful) {
		//api is success
		if ([json objectForKey:@"achievements"]){
			for (NSDictionary *achievement in [json objectForKey:@"achievements"]){
				PNAchievement *achievementData = [[[PNAchievement alloc] initWithDictionary:achievement] autorelease];
				
				[[NSNotificationCenter defaultCenter] 
				 postNotification:[NSNotification notificationWithName:kPNNotificationAchievementUnlockedInServerDatabase object:achievementData]];						
			}		
			//自分のステータスを更新
			[[PNUser currentUser] downloadLatestStatusFromServer];
		}
	} else {
		// 存在しないアチーブメントIDが指定されていた場合などは、エラーでこちらに到達します
		PNWarn(@"Achievement error. Cannot unlock achievement.");
		PNError* error = [[PNError alloc] initWithResponse:resp];
		
		if ([error.errorCode isEqualToString:kPNAchievementUnlockErrorCodeNotFound]){
			NSArray *components = [error.message componentsSeparatedByString:@":"];
			if ([components count] == 2){
				int achievementId = [[components objectAtIndex:1] intValue];
				[[PNLocalAchievementDB sharedObject] setRetryReasonCode:kPNAchievementUnlockRetryReasonNotFound
														  achievementId:achievementId];
				[[PNLocalAchievementDB sharedObject] incrementRetryCountById:achievementId];
			}
		}
		
		PNWarn(@" Reason: %@ - %@", error.errorCode,  error.message);
		//api is not success
		/*
		if([delegate respondsToSelector:@selector(didFailUnlockAchievementWithError:)]) {
			
			error.message = @"Can not unlock achievement";
			[delegate didFailUnlockAchievementWithError:error];
		}*/
	}
}

- (void) showAchievements{
	for (PNAchievement* achievement in achievementDetails){
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"%d[%d]\t%@(%d)", 
			   achievement.achievementId,
			   achievement.isSecret,
			   achievement.title,
			   achievement.value);
	}
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"---------- ---------- ----------");
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Total points: %d", totalPoints);
}

- (void)syncWithServer{
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Sync with server");
	[[PNLocalAchievementDB sharedObject] syncWithServer];
}

- (NSArray*) achievementDetailsInCurrentLocale{
	NSArray* achievementDictionaries = [[[PNSettingManager sharedObject] offlineSettings] objectForKey:@"achievements"];
	NSMutableArray *achievementDetailsInCurrentLocale = [NSMutableArray array];
	
	int _totalPoints = 0;
	if (achievementDictionaries != nil){
		for (NSDictionary* achievementDictionary in achievementDictionaries) {
			[achievementDetailsInCurrentLocale addObject:[[[PNAchievement alloc] initWithLocalDictionary:achievementDictionary] autorelease]];
		}
		totalPoints = _totalPoints;
	}
	return [achievementDetailsInCurrentLocale sortedArrayUsingSelector:@selector(compareOrderId:)];
}

- (PNAchievement*)achievementById:(int)achievementId{
	if (achievementDetails == nil) return nil;
	
	for(PNAchievement* achievement in achievementDetails){
		if (achievement.achievementId == achievementId) {
			return achievement;
		}
	}
	return nil;
}
- (int)valueOfAchievementById:(int)achievementId{
	PNAchievement* achievement = [self achievementById:achievementId];
	if (achievement){
		return achievement.value;
	}
	return 0;
}

- (BOOL)hasDetailsForAchievementId:(int)achievementId{
	if ([self achievementById:achievementId] != nil){
		return YES;
	}else{
		return NO;
	}
}
#pragma mark Server API
- (void)getUnlockedAchievementsOfUser:(NSString*)user gameId:(NSString*)gameId onSuccess:(void (^)(NSArray *unlockedAchievements))onSuccess onFailure:(void (^)(PNError *error))onFailure {
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[PNUser currentUser].sessionId, @"session",
							user, @"user", gameId, @"game", nil];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandAchievementUnlocks params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			NSArray* unlockedAchievements = [PNAchievementModel dataModelsFromArray:[response.jsonDictionary objectForKey:@"unlocks"]];
			onSuccess(unlockedAchievements);
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
		
	} onFailure:onFailure];
}
#pragma mark GameCenter

-(void)loadGameCenterAchievement {
	if (self.gameCenterAchievementDictionary == nil) {
		NSString* errorDesc = nil;
		NSPropertyListFormat format;
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"PNGameCenter" ofType:@"plist"];
		NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
		NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization
													propertyListFromData:plistXML
													mutabilityOption:NSPropertyListMutableContainersAndLeaves
													format:&format
													errorDescription:&errorDesc];
		[self setGameCenterAchievementDictionary:[dictionary objectForKey:@"Achievements"]];
	}
}

-(void)uploadAchievementToGameCenter:(int)achievementId {
	if ([[PNManager sharedObject] gameCenterOptionSet] && [[PNManager sharedObject] gameCenterEnabled]) {
		if (![GKLocalPlayer localPlayer].authenticated) {
			[[PNManager sharedObject] authenticateLocalPlayer];
		}
		// upload the achievement to the game center
		float percent=0;
		if ([[PNLocalAchievementDB sharedObject] isAchievementUnlocked:achievementId userId:[[PNUser currentUser].userId intValue]]) {
			percent=100;
		}
		NSString* identifier = [[self gameCenterAchievementDictionary] objectForKey:[NSString stringWithFormat:@"%d",achievementId]];
		if (identifier) {
			GKAchievement* ach = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
			if (ach) {
				ach.percentComplete = percent;
				[ach reportAchievementWithCompletionHandler:^(NSError* error){
					if (error != nil) {
						PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Cannot report achievement to game center due to %@", error);
					} else {
						PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Achievement %@ reported to game center!", identifier);
					}
					
				}];
			} else {
				PNCLog(PNLOG_CAT_ACHIEVEMENT, @"GKAchievement is nil.");
			}
		}
	}
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"PNAchievementManager init");
	if (self = [super init]){			
		self.achievementDetails = nil;
		
		//現在の言語におけるアチーブメント名／説明を読み込みます
		self.achievementDetails = [self achievementDetailsInCurrentLocale];
		
		[self showAchievements];	//デバッグ用にローカルにあるマスター情報を表示します
		
		// begin - lerry added code
		[self loadGameCenterAchievement];
		// end - lerry added code
	}
	return self;
}

- (void) dealloc{
	self.achievementDetails = nil;
	// begin - lerry added code
	[[self gameCenterAchievementDictionary] release];
	self.gameCenterAchievementDictionary = nil;
	// end - lerry added code
	[super dealloc];
}

+ (PNAchievementManager *)sharedObject
{
    @synchronized(self) {
        if (_sharedAchievementManager == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedAchievementManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedAchievementManager == nil) {
			_sharedAchievementManager = [super allocWithZone:zone];
			return _sharedAchievementManager;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}

@end
