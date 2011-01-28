#import "PNAchievement.h"
#import "PNAchievement+Package.h"
#include <sqlite3.h>
#import "PNLogger+Package.h"
#import "PNGlobal.h"
#import "PNLocalDB.h"


@interface PNLocalAchievementDB(MigrationPrivate)
- (void)doMigrationFrom1To2;
- (void)dropCurrentTable;
- (void)createTableVersion2;
- (void)updateMigrationInfo:(int)version;

//for migration purpose only.
- (NSArray*)unlockedAchievementIds;
@end

@implementation PNLocalAchievementDB(Migration)
- (void)doMigrationFrom:(int)oldVersion to:(int)newVersion{
	@synchronized(self){
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Achievement DB migration %d -> %d", oldVersion, newVersion);
	if (oldVersion == 1 && newVersion == 2){
		[self doMigrationFrom1To2];
	}
	}
}

- (void)dropCurrentTable{
	const char *sql = "drop table unlocked_achievements";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_step(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}

- (void)createTableVersion2{
	const char *sql = "create table unlocked_achievements (id int, unlocked_at datetime, retry_count int, retry_reason_code int, user_id int)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_step(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}

- (void)updateMigrationInfo:(int)version{
	//問い合わせ用のSQLを生成します
	const char *sql = "UPDATE migration_info SET version = ? WHERE key = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, version);
		sqlite3_bind_text(statement, 2, "unlocked_achievements", -1 ,SQLITE_TRANSIENT );
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sqlite3_finalize(statement);
			return;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		sqlite3_finalize(statement);
	}
	
}

- (void)doMigrationFrom1To2{
	NSArray *_unlockedAchievements = [self unlockedAchievementIdsVersion1];
	
	//現在のテーブルを削除します
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"DROPPING current table");
	[self dropCurrentTable];
	
	//新しいテーブルを作ります
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"CREATING new table");
	[self createTableVersion2];
	
	//データを移します
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"IMPORTING data from old table");
	for(NSNumber *achievementId in _unlockedAchievements){
		[self unlockAchievementWithoutNotification:[achievementId intValue] byUser:0];
	}
	
	//マイグレーションのバージョンを更新します
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"UPDATING migration info");
	[self updateMigrationInfo:2];
}
@end
