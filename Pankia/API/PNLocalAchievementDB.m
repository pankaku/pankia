#import "PNAchievement.h"
#import "PNAchievement+Package.h"
#include <sqlite3.h>
#import "PNAchievementRequestHelper.h"
#import "JsonHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNAchievementModel.h"
#import "PNAchievementManager.h"
#import "PNLogger+Package.h"
#import "PNGlobal.h"
#import "PNLocalDB.h"
#import "PNJSONCacheManager.h"
#import "PNNotificationNames.h"
#import "PNManager.h"

//アチーブメントの再送回数の上限(その回数リトライしてだめだった項目については再送しません)
#define kPNAchievementUnlockMaximumRetryCount		100
#define kPNUnlockedAchievementStoreKey				@"UNLOCKED_ACHIEVEMENTS"

static PNLocalAchievementDB *_sharedInstance = nil;
static const int LATEST_TABLE_VERSION = 2;

@interface PNLocalAchievementDB (Private)
- (void)createCopyOfDatabaseIfNeeded;
- (BOOL)connectToDatabase;
- (void)disconnectFromDatabase;
- (void)sendUnsentAchievements:(NSArray*)serverUnlockedAchievementIds;
- (void)mergePreviousAchievements:(NSArray*)serverUnlockedAchievementIds;
- (int)retryCountOfAchievementById:(int)achievementId;
- (void)changeUnlockOwnerFrom:(int)oldUserId to:(int)newUserId;
@end
@interface PNLocalAchievementDB (Migration)
- (int)currentMigrationNumber;
- (void)doMigrationFrom:(int)oldVersion to:(int)newVersion;
@end


@implementation PNLocalAchievementDB
- (int)currentMigrationNumber{
	return [[PNLocalDB sharedObject] currentMigrationNumberOfTableNamed:@"unlocked_achievements"];
}

- (void)clearAll{
	const char *sql = "delete from unlocked_achievements";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_step(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}

- (BOOL)isAchievementUnlocked:(int)achievementId userId:(int)userId{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT id FROM unlocked_achievements WHERE id = ? and user_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, achievementId);
		sqlite3_bind_int(statement, 2, userId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sqlite3_finalize(statement);
			return YES;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return NO;
}

- (int)retryCountOfAchievementById:(int)achievementId{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT retry_count FROM unlocked_achievements WHERE id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, achievementId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int retry_count = sqlite3_column_int(statement, 0);
			sqlite3_finalize(statement);
			return retry_count;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return UINT_MAX;
}
- (void)changeUnlockOwnerFrom:(int)oldUserId to:(int)newUserId{
	
	//同じユーザだったらなにもしません
	if (oldUserId == newUserId) return;
	
	//重複がないようにしながら、oldUserIdのアンロック情報をnewUserIdに引き継ぎます
	NSArray* unlockedAchievementIdsByOldUser = [self unlockedAchievementIdsOfUser:oldUserId];
	
	//一件ずつnewUserIdに引き継いでいきます
	for (NSNumber *achievementId in unlockedAchievementIdsByOldUser){
		if (![self isAchievementUnlocked:[achievementId intValue] userId:newUserId]){
			[self unlockAchievementWithoutNotification:[achievementId intValue] byUser:newUserId];
		}
	}
	
	//oldUserIdのアンロック情報を空にします
	const char *sql = "delete from unlocked_achievements WHERE user_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, oldUserId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sqlite3_finalize(statement);
			return;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
- (void)incrementRetryCountById:(int)achievementId{
	int currentUserId = [PNUser currentUserId];
	
	//IDが存在するか確認します
	if (![self isAchievementUnlocked:achievementId userId:currentUserId]){
		return;	//存在しなければなにもしません(本来ここに到達するべきではありません)
	}
	
	//問い合わせ用のSQLを生成します
	const char *sql = "UPDATE unlocked_achievements SET retry_count = retry_count + 1 WHERE id = ? and user_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, achievementId);
		sqlite3_bind_int(statement, 2, currentUserId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sqlite3_finalize(statement);
			return;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
- (void)setRetryReasonCode:(int)retryReasonCode achievementId:(int)achievementId{
	int currentUserId = [PNUser currentUserId];
	
	//IDが存在するか確認します
	if (![self isAchievementUnlocked:achievementId userId:currentUserId]){
		return;	//存在しなければなにもしません(本来ここに到達するべきではありません)
	}
	
	//問い合わせ用のSQLを生成します
	const char *sql = "UPDATE unlocked_achievements SET retry_reason_code = ? WHERE id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, retryReasonCode);
		sqlite3_bind_int(statement, 2, achievementId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sqlite3_finalize(statement);
			return;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}

- (void)unlockAchievementWithoutNotification:(int)achievementId byUser:(int)userId{
	const char *sql = "insert into unlocked_achievements (id, retry_reason_code, retry_count, user_id) values (?, ?, ?, ?)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int(statement, 1, achievementId);
	sqlite3_bind_int(statement, 2, kPNAchievementUnlockRetryReasonNone);
	sqlite3_bind_int(statement, 3, 0);
	sqlite3_bind_int(statement, 4, userId);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}

- (void)unlockAchievement:(int)achievementId{
	[self unlockAchievement:achievementId delegate:nil userId:0];
}
- (void)unlockAchievement:(int)achievementId delegate:(id)delegate userId:(int)userId{
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"LocalDB unlockAchievement:%d", achievementId);
	
	//既に値が入っていなければ登録します
	BOOL alreadyUnlocked = [self isAchievementUnlocked:achievementId userId:userId];
	PNCLog(PNLOG_CAT_DB, @"isAchievement(%d) unlocked? %d",achievementId, alreadyUnlocked);
	
	if (!alreadyUnlocked){
		const char *sql = "insert into unlocked_achievements (id, retry_reason_code, retry_count, user_id) values (?, ?, ?, ?)";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
			PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		}
		sqlite3_bind_int(statement, 1, achievementId);
		sqlite3_bind_int(statement, 2, kPNAchievementUnlockRetryReasonNone);
		sqlite3_bind_int(statement, 3, 0);
		sqlite3_bind_int(statement, 4, userId);
		if (sqlite3_step(statement) != SQLITE_DONE){
			PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		}
		sqlite3_finalize(statement);
		
		PNAchievement *achievement = [[PNAchievementManager sharedObject] achievementById:achievementId];
		if (achievement == nil)
			achievement = [[[PNAchievement alloc] initWithAchievementId:achievementId] autorelease];
		
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPNNotificationAchievementUnlockedInLocalDatabase object:achievement]];
	}
	
	for (NSNumber* achievementId in [self unlockedAchievementIdsOfUser:userId]){
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Unlocked achievement: %d", [achievementId intValue]);
	}
}

/**
 ローカルDB上に記録されている、アンロックされたAchievementIDの一覧を返します
 */
- (NSArray*)unlockedAchievementIdsVersion1{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT id FROM unlocked_achievements order by id";
	sqlite3_stmt *statement;
	
	NSMutableArray *achievements = [NSMutableArray array];
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			[achievements addObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 0)]];
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return achievements;
}
- (NSArray*)unlockedAchievementIdsOfUser:(int)userId{	
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT id FROM unlocked_achievements WHERE user_id = ? order by id";
	sqlite3_stmt *statement;
	
	NSMutableArray *achievements = [NSMutableArray array];
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			[achievements addObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 0)]];
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return achievements;
}

/**
 ローカルDB上に記録されている、アンロックされたAchievementの合計ポイント(value)を返します
 */
- (int) unlockedPointsOfUser:(int)userId{
	NSArray* _unlockedAchievements = [self unlockedAchievementIdsOfUser:userId];
	int points = 0;
	if ([_unlockedAchievements count] > 0){
		for(NSNumber *achievementId in _unlockedAchievements){
			points += [[PNAchievementManager sharedObject] valueOfAchievementById:[achievementId intValue]];
		}
	}
	
	return points;
}

/**
 サーバーと同期します
 */
- (void)syncWithServer{
	PNCLog(PNLOG_CAT_DB, @"Sync unlocked achievements with server. Current user id is %d", [PNUser currentUserId]);
	
	//現在オーナー不在(UserID = 0)となっているレコードを、現在のユーザに結びつけます
	[self changeUnlockOwnerFrom:0 to:[PNUser currentUserId]];
	
	//サーバーからアンロック済みAchievement一覧を取得してきます
	[[PNAchievementManager sharedObject] 
	 getUnlockedAchievementsOfUser:[PNUser currentUser].username gameId:[PNUser currentUser].gameId onSuccess:^(NSArray *unlockedAchievements) {
		 NSMutableArray *serverUnlockedAchievementIds = [NSMutableArray array];
		 
		 for (PNAchievementModel *achievement in unlockedAchievements){
			 [serverUnlockedAchievementIds addObject:[NSNumber numberWithInt:achievement.id]];
		 }
		 [self sendUnsentAchievements:serverUnlockedAchievementIds];
		 [self mergePreviousAchievements:serverUnlockedAchievementIds];
	 } onFailure:^(PNError *arg1) {
		 PNWarn(@"Achievement sync error at getting unlocked achievements from the server.");
	 }];
}
- (void)syncWithServerWithArray:(NSArray *)achievementArray{
	NSMutableArray *serverUnlockedAchievementIds = [NSMutableArray array];
	
	for (PNAchievementModel *achievement in achievementArray){
		[serverUnlockedAchievementIds addObject:[NSNumber numberWithInt:achievement.id]];
	}
	[self sendUnsentAchievements:serverUnlockedAchievementIds];
	[self mergePreviousAchievements:serverUnlockedAchievementIds];
}

- (void)sendUnsentAchievements:(NSArray*)serverUnlockedAchievementIds{
	int currentUserId = [PNUser currentUserId];
	
	//ローカルにあって、サーバーにないAchievementを検索します
	NSMutableArray *unsentAchievements = [NSMutableArray array];
	NSArray* localUnlockedAchievements = [self unlockedAchievementIdsOfUser:currentUserId];
	for (NSNumber *unlockedAchievementId in localUnlockedAchievements){
		BOOL isInServerList = NO;
		for (NSNumber *achievementId in serverUnlockedAchievementIds){
			if ([achievementId intValue] == [unlockedAchievementId intValue]) isInServerList = YES;
		}
		
		if (!isInServerList){
			int retryCount = [self retryCountOfAchievementById:[unlockedAchievementId intValue]];
			if (retryCount <= kPNAchievementUnlockMaximumRetryCount){
				[unsentAchievements addObject:unlockedAchievementId];
			}else{
				PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Achievement %d will not be sent.", [unlockedAchievementId intValue]);
			}
		}
	}
	
	//サーバーに送信済みでないAchievementを送信します
	[[PNAchievementManager sharedObject] unlockAchievements:unsentAchievements];
}

- (void)mergePreviousAchievements:(NSArray*)serverUnlockedAchievementIds{
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"mergePreviousAchievements %@", serverUnlockedAchievementIds);
	
	int currentUserId = [PNUser currentUserId];
	//マージ前のUnlocked Achievementの数を記録しておきます。
	int unlockedAchievementsBefore = [[self unlockedAchievementIdsOfUser:currentUserId] count];
	
	//サーバーにあってローカルにないAchievementを検索します
	for (NSNumber *serverAchievementId in serverUnlockedAchievementIds) {
		if (![self isAchievementUnlocked:[serverAchievementId intValue] userId:currentUserId]){
			[self unlockAchievement:[serverAchievementId intValue] delegate:nil userId:currentUserId];
		}
	}
	
	// サーバーからアチーブメントを追加でダウンロードしたら、PNManagerのデリゲートを呼びます
	if ([[self unlockedAchievementIdsOfUser:currentUserId] count] != unlockedAchievementsBefore){
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Unlocked achievement merged.");
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Unlocked achievements: %@", [[self unlockedAchievementIdsOfUser:[PNUser currentUserId]] componentsJoinedByString:@","]);
	}
	
	PNManager* manager = [PNManager sharedObject];
	if (manager.delegate != nil && [manager.delegate respondsToSelector:@selector(managerDidDownloadAndUnlockedAchievementsFromServer:)]){
		[manager.delegate managerDidDownloadAndUnlockedAchievementsFromServer:manager];
	}
}



#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	if (self = [super init]){
		
		@synchronized(self){		
			PNCLog(PNLOG_CAT_ACHIEVEMENT, @"PNLocalAchievementDB init");
			
			//DBのインスタンスが作られていなければ作ります
			[PNLocalDB sharedObject];
			
			//マイグレーションを行います
			int currentMigrationNumber = [self currentMigrationNumber];
			PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Current achievement table version is %d", currentMigrationNumber);
			if (currentMigrationNumber < LATEST_TABLE_VERSION){
				[self doMigrationFrom:currentMigrationNumber to:LATEST_TABLE_VERSION];
			}
			
			[self changeUnlockOwnerFrom:0 to:[PNUser currentUserId]];
			
			//debug: アンロック済みAchievement一覧を取得します
			PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Unlocked achievements of user[%d]: %@",[PNUser currentUserId], [[self unlockedAchievementIdsOfUser:[PNUser currentUserId]] componentsJoinedByString:@","]);
			PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Unlocked points: %d", [self unlockedPointsOfUser:[PNUser currentUserId]]);
		}
	}
	return self;
}

- (void) dealloc{
	[self disconnectFromDatabase];
	[super dealloc];
}

+ (PNLocalAchievementDB*)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
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
