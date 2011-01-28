//
//  PNLocalDB.m
//  PankakuNet
//
//  Created by pankaku on 10/08/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLocalDB.h"
#import "PNLogger+Package.h"

static PNLocalDB* _sharedInstance;

@implementation PNLocalDB
@synthesize database;

- (void)doPlainSQL:(const NSString*)sqlString{
	const char *sql = [sqlString cStringUsingEncoding:NSUTF8StringEncoding];
	sqlite3_stmt *statement;
		
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_step(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}

- (BOOL)processSQLFile:(const NSString*)fileName ofType:(const NSString*)ofType
{
	NSString* filePath = [[NSBundle mainBundle] pathForResource:(NSString*)fileName ofType:(NSString*)ofType];
	if (filePath == nil){
		PNWarn(@"[WARNING]sql file not found. %@.%@",fileName,ofType);
		return NO;
	}
	
	NSString* sqlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	if (sqlString == nil || [sqlString length] == 0) {
		PNWarn(@"[WARNING]sql file is empty. %@.%@",fileName,ofType);
		return NO;
	}
	
	[self doPlainSQL:sqlString];
	return YES;
}

- (int)currentMigrationNumberOfTableNamed:(const NSString*)tableName{
	const char *sql = "SELECT version from migration_info where key = ?";
	sqlite3_stmt *statement;
	
	int result = -1;
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_text(statement, 1, [tableName cStringUsingEncoding:NSASCIIStringEncoding], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int table_version = sqlite3_column_int(statement, 0);
			sqlite3_finalize(statement);
			return table_version;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return result;
}
- (void)updateMigrationNumber:(int)migrationNumber forTable:(const NSString*)tableName{
	//問い合わせ用のSQLを生成します
	char *sql;
	if ([self currentMigrationNumberOfTableNamed:tableName] >= 0) {
		sql = "UPDATE migration_info SET version = ? WHERE key = ?";
	} else {
		sql = "INSERT into migration_info (version,key) values (?, ?)";
	}

	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, migrationNumber);
		sqlite3_bind_text(statement, 2, [tableName cStringUsingEncoding:NSASCIIStringEncoding], -1 ,SQLITE_TRANSIENT );
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sqlite3_finalize(statement);
			return;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		sqlite3_finalize(statement);
	}
	
}

+ (NSString*)dbFilePath 
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"pn_local.sqlite"];
}

/**
 アンロック済みAchievement一覧、リーダーボードスコアを管理するためのテーブルがなければ作ります。
 */
- (void)createCopyOfDatabaseIfNeeded{
	NSString* pathToCreate = [PNLocalDB dbFilePath];
	
	//既にファイルが存在すればなにもしない
	if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCreate]) {
		PNCLog(PNLOG_CAT_LOCALDB, @"Database already exists.");
		return;
	}
	
	//オリジナルのDBをアプリケーションのドキュメントディレクトリにコピーする
	NSString *originalSchemaFilePath = [[NSBundle mainBundle] pathForResource:@"pn_local" ofType:@"sqlite"];
	NSError *error;
	if (![[NSFileManager defaultManager] copyItemAtPath:originalSchemaFilePath 
												 toPath:pathToCreate error:&error]){
		PNCLog(PNLOG_CAT_LOCALDB, @"Failed to copy original database.");
	}else{
		PNCLog(PNLOG_CAT_LOCALDB, @"Database created.");
	}
}

- (BOOL)connectToDatabase{
	if (sqlite3_open([[PNLocalDB dbFilePath] UTF8String], &database) == SQLITE_OK){
		return YES;
	}else{
		PNCLog(PNLOG_CAT_DB, @"Error connecting to database.");
		return NO;
	}
}
- (void)disconnectFromDatabase{
	sqlite3_close(database);
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	if (self = [super init]){
		
		@synchronized(self){		
			PNCLog(PNLOG_CAT_LOCALDB, @"PNLocalDB init");
			
			//データベースが初期化されていなければ用意します
			[self createCopyOfDatabaseIfNeeded];
			
			//データベースに接続します
			[self connectToDatabase];
		}
	}
	return self;
}

- (void) dealloc{
	[self disconnectFromDatabase];
	[super dealloc];
}

+ (PNLocalDB*)sharedObject
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
