//
//  PNItemHistory.m
//  PankakuNet
//
//  Created by sota on 10/09/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemHistory.h"
#import "PNLocalDB.h"
#import "PNLogger+Package.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNStoreManager.h"
#import "PNError.h"
#import "PNItemOwnershipModel.h"
#import "PNItemCategory.h"
#import "PNItem.h"
#import "PNItemManager.h"
#import "PNManager.h"
#import <Foundation/Foundation.h>
#import "PNGameManager.h"

static PNItemHistory *_sharedInstance;

NSString* kItemHistoryTableName = @"item_acquirements";
NSString* kItemTableDefinitionFileName = @"PNItemMigration1";

@interface PNItemHistory (Private)
- (BOOL)hasRecordsWithItemId:(NSString*)itemId userId:(int)userId;
- (BOOL)hasUnsentRecordsWithItemId:(NSString*)itemId userId:(int)userId;
- (void)newItemWithId:(NSString*)itemId quantity:(int64_t)quantity userId:(int)userId;
- (void)updateQuantity:(int64_t)quantity itemId:(NSString*)itemId userId:(int)userId;
- (int64_t)currentQuantityForItemId:(NSString *)itemId userId:(int)userId;
- (int64_t)increaseOrDecreaseQuantityForItemId:(NSString*)itemId delta:(int64_t)delta userId:(int)userId;
- (int)lastRecordIdForItemId:(NSString*)itemId userId:(int)userId;
- (void)sendUnsentRecords;
- (int64_t)sumOfDeltaForItemId:(NSString*)itemId userId:(int)userId;
- (void)updateOwnerships:(NSDictionary *)ownerships;
@end

@interface PNItemHistory ()
@property (nonatomic, retain) NSMutableDictionary* synchronizingRecordId;
@end

@implementation PNItemHistory
@synthesize synchronizingRecordId;
- (void)sync
{
	// Get latest item ownership data from the server
	[[PNItemManager sharedObject] getItemOwnershipsFromServerWithOnSuccess:^(NSDictionary *ownerships) {
		[self updateOwnerships:ownerships];
	} onFailure:^(PNError *error) {
		PNWarn(@"ItemHistory sync error. %@", error);
	}];
}
- (void)updateOwnership:(PNItemOwnershipModel*)ownership
{
	int userId = [PNUser currentUserId];
	NSString* itemId = ownership.item_id;
	
	// 指定したitemIdのレコードが存在するか調べます
	BOOL hasRecordWithItemId = [self hasRecordsWithItemId:itemId userId:userId];
	
	// レコードが存在しなければ作ります
	if (hasRecordWithItemId == NO) {
		// レコードを作ります
		[self newItemWithId:itemId quantity:ownership.quantity userId:userId];
	} else {
		// 未送信(オフライン時に使用した)の履歴があるか調べます
		BOOL hasUnsentRecordsWithItemId = [self hasUnsentRecordsWithItemId:itemId userId:userId];
		
		// なければ上書きします
		if (hasUnsentRecordsWithItemId == NO) {
			PNCLog(PNLOG_CAT_ITEM, @"Item(%@) has no unsent records", itemId);
			[synchronizingRecordId setObject:[NSNumber numberWithInt:[self lastRecordIdForItemId:itemId userId:[PNUser currentUserId]]] forKey:itemId];
			[self updateQuantity:ownership.quantity itemId:itemId userId:userId];
		} else {
			PNWarn(@"Error. You should not reach here. updateOwnership:");
		}
	}
	
	PNItem* item = [PNItem itemWithId:[itemId intValue]];
	if ([item isCoin]) {
		[PNUser currentUser].coins = ownership.quantity;
	}
}
- (void)updateOwnerships:(NSDictionary*)ownerships
{
	PNCLog(PNLOG_CAT_ITEM, @"item ownerships down sync");
	int userId = [PNUser currentUserId];
	for (PNItemCategory* category in [[PNGameManager sharedObject] categories]) {
		for (PNItem* item in [category items]) {
			NSString* itemId = [item stringId];
			
			// 指定したITEM_IDのownership情報がサーバー上に存在するか調べます
			PNItemOwnershipModel* ownership = [ownerships objectForKey:itemId];
			
			if (ownership != nil) {	//ある場合
				// 指定したitemIdのレコードが存在するか調べます
				BOOL hasRecordWithItemId = [self hasRecordsWithItemId:itemId userId:userId];
				
				// レコードが存在しなければ作ります
				if (hasRecordWithItemId == NO) {
					// レコードを作ります
					[self newItemWithId:itemId quantity:ownership.quantity userId:userId];
				} else {
					// 未送信(オフライン時に使用した)の履歴があるか調べます
					BOOL hasUnsentRecordsWithItemId = [self hasUnsentRecordsWithItemId:itemId userId:userId];
					
					// なければ上書きします
					if (hasUnsentRecordsWithItemId == NO) {
						PNCLog(PNLOG_CAT_ITEM, @"Item(%@) has no unsent records", itemId);
						[synchronizingRecordId setObject:[NSNumber numberWithInt:[self lastRecordIdForItemId:itemId userId:[PNUser currentUserId]]] forKey:itemId];
						[self updateQuantity:ownership.quantity itemId:itemId userId:userId];
					}
					
					// 未送信データがあるものは、ここでは更新せず後で更新されます。
				}
			} else {				//ない場合
				// 未送信データがあれば、無視します。なければローカルの値もゼロにします
				if ([self hasUnsentRecordsWithItemId:itemId userId:userId] == NO) {
					[synchronizingRecordId setObject:[NSNumber numberWithInt:[self lastRecordIdForItemId:itemId userId:[PNUser currentUserId]]] forKey:itemId];
					[self updateQuantity:0 itemId:itemId userId:userId];
				}
			}
		}
	}
	
	//未送信データをコミットします
	[self sendUnsentRecords];
}
- (void)sendUnsentRecords
{
	if ([PNManager sharedObject].isLoggedIn == NO){
		// begin - lerry added code
		PNCLog(PNLOG_CAT_ITEM, @"sendUnsentRecords(): isLoggedIn=NO");
		// end - lerry added code
		return;
	}
	if (synchronizingWithServer) {
		// begin - lerry added code
		PNCLog(PNLOG_CAT_ITEM, @"sendUnsentRecords(): synchronizingWithServer=YES");
		// end - lerry added code
		return;
	}
	synchronizingWithServer = YES;
	PNCLog(PNLOG_CAT_ITEM, @"item ownerships up sync");
	
	NSMutableDictionary* acquires = [NSMutableDictionary dictionary];
	NSMutableDictionary* consumes = [NSMutableDictionary dictionary];
	
	int userId = [PNUser currentUserId];
	for (PNItemCategory* category in [[PNGameManager sharedObject] categories]) {
		for (PNItem* item in [category items]) {
			NSString* itemId = [item stringId];
			
			//TODO: Non-consumable, subscriptionを別に扱う
			NSNumber* latestRecordId = [NSNumber numberWithInt:[self lastRecordIdForItemId:itemId userId:userId]];
			if ([self hasUnsentRecordsWithItemId:itemId userId:userId] == YES) {
				int64_t sum = [self sumOfDeltaForItemId:itemId userId:userId];
				[synchronizingRecordId setObject:latestRecordId forKey:itemId];
				if (sum == 0) {
					[self updateQuantity:[self currentQuantityForItemId:itemId] itemId:itemId userId:userId];
				} else if (sum > 0) {
					[acquires setObject:[NSNumber numberWithLongLong:sum] forKey:itemId];
				} else {
					[consumes setObject:[NSNumber numberWithLongLong:-sum] forKey:itemId];
				}
			}
		}
	}
	
	if ([acquires count] > 0) {
		[[PNItemManager sharedObject] acquireItems:acquires delegate:self onSucceeded:@selector(sentRecord:) onFailed:@selector(sentFailed:)];
		return;
	}
	if ([consumes count] > 0) {
		[[PNItemManager sharedObject] consumeItems:consumes delegate:self onSucceeded:@selector(sentRecord:) onFailed:@selector(sentFailed:)];
		return;
	}
	
	synchronizingWithServer = NO;
}
- (void)sentRecord:(NSArray*)ownerships
{
	// begin - lerry added code
	retryDelay = 1;
	// end - lerry added code
	for (PNItemOwnershipModel* ownership in ownerships){
		[self updateQuantity:ownership.quantity itemId:ownership.item_id userId:[PNUser currentUserId]];
	}
	synchronizingWithServer = NO;
	self.synchronizingRecordId = [NSMutableDictionary dictionary];
	
	[self sendUnsentRecords];
}
- (void)sentFailed:(PNError*)error
{
	PNWarn(@"[WARNING]Item critical error. can't sync with server. %@", error.errorCode);
	[[PNManager sharedObject] sendReport:[NSString stringWithFormat:@"item sync failed. details:\n%@", error.errorCode]];
	if (retryDelay == 0) {
		retryDelay = 1;
	}else {
		retryDelay = retryDelay << 1;
	}
	PNCLog(PNLOG_CAT_ITEM,@"PNItemHistory.sentFailed(): to start timer with interval=%d", retryDelay);
	[self performSelector:@selector(sendUnsentRecords) withObject:nil afterDelay:retryDelay];
}

#pragma mark -

- (int64_t)currentQuantityForItemId:(NSString*)itemId
{
	return [self currentQuantityForItemId:itemId userId:[PNUser currentUserId]];
}

- (int64_t)increaseOrDecreaseQuantityForItemId:(NSString*)itemId delta:(int64_t)delta
{
	int64_t newQuantity = [self increaseOrDecreaseQuantityForItemId:itemId delta:delta userId:[PNUser currentUserId]];
	[self sendUnsentRecords];
	return newQuantity;
}

#pragma mark DB Access
// DB Access層のメソッドはユーザと切り離された形で実装してください

- (BOOL)hasRecordsWithItemId:(NSString*)itemId userId:(int)userId
{
	const char *sql = "SELECT count(id) FROM item_acquirements WHERE user_id = ? and item_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_text(statement, 2, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int recordId = sqlite3_column_int(statement, 0);
			return recordId > 0;
		}
		sqlite3_finalize(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return NO;
}
- (BOOL)hasUnsentRecordsWithItemId:(NSString*)itemId userId:(int)userId
{
	const char *sql = "SELECT count(id) FROM item_acquirements WHERE user_id = ? and item_id = ? and revised_at is NULL";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_text(statement, 2, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int recordId = sqlite3_column_int(statement, 0);
			sqlite3_finalize(statement);
			return recordId > 0;
		}
		sqlite3_finalize(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return NO; 
}
- (int64_t)sumOfDeltaForItemId:(NSString*)itemId userId:(int)userId
{
	const char *sql = "SELECT quantity FROM item_acquirements WHERE user_id = ? and item_id = ? and revised_at is NULL";
	sqlite3_stmt *statement;
	
	int64_t sum = 0;
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_text(statement, 2, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sum += sqlite3_column_int(statement, 0);
		}
		sqlite3_finalize(statement);
		return sum;
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return 0;
}

- (int64_t)currentQuantityForItemId:(NSString *)itemId userId:(int)userId
{
	const char *sql = "SELECT revised_quantity FROM item_acquirements WHERE user_id = ? and item_id = ? ORDER BY id desc LIMIT 1";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_text(statement, 2, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int64_t quantity = sqlite3_column_int64(statement, 0);
			sqlite3_finalize(statement);
			return quantity;
		}
		sqlite3_finalize(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return 0;
}
- (int)lastRecordIdForItemId:(NSString*)itemId userId:(int)userId
{
	const char *sql = "SELECT id FROM item_acquirements WHERE user_id = ? and item_id = ? ORDER BY id desc LIMIT 1";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_text(statement, 2, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int recordId = sqlite3_column_int(statement, 0);
			sqlite3_finalize(statement);
			return recordId;
		}
		sqlite3_finalize(statement);
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return 0;
}

- (void)newItemWithId:(NSString*)itemId quantity:(int64_t)quantity userId:(int)userId
{
	PNCLog(PNLOG_CAT_ITEM, @"newItemWithId:%@ quantity:%lld userId:%d", itemId, quantity, userId);
	
	//TODO: 知らないアイテムは無視します
	
	//Non-consumable / Subscriptionのアイテムはquantity = 1として扱います。
	const char *sql = "insert into item_acquirements (created_at, user_id, item_id, quantity, revised_quantity, revised_at) values (current_timestamp, ?, ?, ?, ?, current_timestamp)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int(statement, 1, userId);
	sqlite3_bind_text(statement, 2, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
	sqlite3_bind_int64(statement, 3, quantity);
	sqlite3_bind_int64(statement, 4, quantity);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
- (void)updateQuantity:(int64_t)quantity itemId:(NSString*)itemId userId:(int)userId
{
	PNCLog(PNLOG_CAT_ITEM, @"update itemId:%@ quantity:%lld userId:%d", itemId, quantity, userId);
	
	//TODO: 知らないアイテムは無視します
	
	int recordId = UINT_MAX;
	if ([synchronizingRecordId objectForKey:itemId] != nil) {
		recordId = [[synchronizingRecordId objectForKey:itemId] intValue];
	} else {
		PNWarn(@"oops, record id is null. %@", synchronizingRecordId);
	}
	
	
	{
		const char *sql = "UPDATE item_acquirements SET revised_quantity = ?, revised_at = current_timestamp WHERE user_id = ? and item_id = ? and revised_at is NULL and id <= ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
			PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		}
		sqlite3_bind_int64(statement, 1, quantity);
		sqlite3_bind_int(statement, 2, userId);
		sqlite3_bind_text(statement, 3, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		sqlite3_bind_int(statement, 4, recordId);
		
		if (sqlite3_step(statement) != SQLITE_DONE){
			PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		}
		sqlite3_finalize(statement);
	}
	
	int lastRecordId = [self lastRecordIdForItemId:itemId userId:userId];
	if (lastRecordId > recordId) lastRecordId = recordId;
	{
	//	NSLog(@"record to update: %d", lastRecordId);
		const char *sql = "UPDATE item_acquirements SET revised_quantity = ?, revised_at = current_timestamp WHERE user_id = ? and item_id = ? and id = ?";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
			PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		}
		sqlite3_bind_int64(statement, 1, quantity);
		sqlite3_bind_int(statement, 2, userId);
		sqlite3_bind_text(statement, 3, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		sqlite3_bind_int(statement, 4, lastRecordId);
		
		if (sqlite3_step(statement) != SQLITE_DONE){
			PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
		}
		sqlite3_finalize(statement);
	}
}

- (int64_t)increaseOrDecreaseQuantityForItemId:(NSString *)itemId delta:(int64_t)delta userId:(int)userId
{
	PNCLog(PNLOG_CAT_ITEM, @"increaseOrDecrease itemId:%@ delta:%lld userId:%d", itemId, delta, userId);
	
	//TODO: 知らないアイテムは無視します
	
	int64_t quantity = [self currentQuantityForItemId:itemId userId:userId] + delta;
	PNItem* item = [[PNItemManager sharedObject] itemWithIdentifier:itemId];
	if (item) {
		int64_t maxQuantity = [[PNItemManager sharedObject] itemWithIdentifier:itemId].maxQuantity;
		if (quantity >= maxQuantity) {
			delta = maxQuantity - [self currentQuantityForItemId:itemId];
			quantity = maxQuantity;
		}
		// begin - lerry added code
		if (quantity < 0) {
			delta = -[self currentQuantityForItemId:itemId];
			quantity = 0;
		}
		// end - lerry added code
	}
	
	//Non-consumable / Subscriptionのアイテムはquantity = 1として扱います。
	const char *sql = "insert into item_acquirements (created_at, user_id, item_id, quantity, revised_quantity) values (current_timestamp, ?, ?, ?, ?)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int(statement, 1, userId);
	sqlite3_bind_text(statement, 2, [itemId cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
	sqlite3_bind_int64(statement, 3, delta);
	sqlite3_bind_int64(statement, 4, quantity);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return quantity;
}

#pragma mark Migration
- (void)createTable
{
	PNCLog(PNLOG_CAT_ITEM, @"Creating payment history db");
	
	// テーブル作成用のSQLを実行します
	if([[PNLocalDB sharedObject] processSQLFile:kItemTableDefinitionFileName ofType:@"sql"]) {
		// マイグレーション番号を更新します
		[[PNLocalDB sharedObject] updateMigrationNumber:1 forTable:kItemHistoryTableName];
	} else {
		PNWarn(@"[WARNING]failed to create payment history table.");
	}
}
- (void)doMigrationIfNeeded
{
	// 現在のマイグレーション番号を取得しにいきます
	int currentMigrationNumber = [[PNLocalDB sharedObject] currentMigrationNumberOfTableNamed:kItemHistoryTableName];
	PNCLog(PNLOG_CAT_ITEM, @"[PAYMENT HISTORY]CURRENT MIGRATION NUMBER: %d", currentMigrationNumber);
	
	// -1だったらテーブルを作ります
	if (currentMigrationNumber == -1) [self createTable];
	
	// 後々のアップグレードに関するマイグレーションの処理はここに書いてください。
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	if (self = [super init]){
		
		@synchronized(self){		
			//マイグレーションが必要だったらマイグレーションします
			[self doMigrationIfNeeded];
			
			self.synchronizingRecordId = [NSMutableDictionary dictionary];
			// begin - lerry added code
			retryDelay = 0;
			// end - lerry added code
		}
	}
	return self;
}

- (void) dealloc{
	self.synchronizingRecordId = nil;
	[super dealloc];
}

+ (PNItemHistory*)sharedObject
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
