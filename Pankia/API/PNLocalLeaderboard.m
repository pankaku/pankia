//
//  PNLocalLeaderboard.m
//  PankakuNet
//
//  Created by pankaku on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLocalLeaderboard.h"
#import "PNLocalDB.h"
#import "PNLogger+Package.h"
#import "PNLeaderboardManager.h"
#import "PNLeaderboard.h"
#import "PNSettingManager.h"
#import "PNRank.h"
#import "PNRank+Package.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNLocalLeaderboardUpSyncQueue.h"
#import "PNError.h"
#import "PNGameManager.h"

#import "PNManager.h"

static const NSString* kPNLeaderboardTableName = @"leaderboard_scores";
static PNLocalLeaderboard* _sharedInstance = nil;

@implementation PNLocalLeaderboardScore
@synthesize recordId, leaderboardId, userId, score, scoredAt, dateKey, isDelta, upSyncHash, commitScore;
@end


@interface PNLocalLeaderboard(Private)
- (NSArray*)idsOfLeaderboardWithUnsentScoresOfUser:(int)userId;
- (NSArray*)idsOfLeaderboardWithUnsentDailyHighscoresOfUser:(int)userId;
- (int64_t)latestDownloadedScoreOnLeaderboard:(int)leaderboardId userId:(int)userId;
- (BOOL)hasDailyHighscoreOfDate:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId;
- (PNLocalLeaderboardScore*)highscoreOfDate:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId;
- (void)insertNewDailyHighscore:(int64_t)score delta:(BOOL)delta date:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId;
- (void)updateDailyHighscore:(int64_t)score delta:(BOOL)delta date:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId;
- (void)insertNewScoreToLeaderboard:(int)leaderboardId userId:(int)userId score:(int64_t)score result:(int64_t)result delta:(BOOL)delta;
- (void)insertDownloadedScoreToLeaderboard:(int)leaderboardId userId:(int)userId score:(int64_t)score;
- (void)setSyncScore:(int64_t)result onLeaderboard:(PNLeaderboard *)leaderboard userId:(int)userId toRecordId:(int)recordId;
- (BOOL)hasUnsentAbsoluteScoreCommitOnLeaderboard:(PNLeaderboard *)leaderboard userId:(int)userId;
- (int64_t)sumOfUnsentCommitDeltasOnLeaderboard:(PNLeaderboard *)leaderboard userId:(int)userId toRecordId:(int)recordId;
@end

@implementation PNLocalLeaderboard
@synthesize delegate;

- (void)doUpSync
{	
	[PNLocalLeaderboardUpSyncQueue sharedObject].delegate = self;
	[[PNLocalLeaderboardUpSyncQueue sharedObject] start];
}

/*!
 * サーバーから最新スコアを取得してきて同期します。
 * 未送信レコードがローカルに存在しないリーダーボードが対象です。
 */
- (void)doDownSync
{
	NSArray* leaderboards = [[PNGameManager sharedObject] leaderboards];	
	NSArray* leaderboardWithUnsentRecords = [self leaderboardsWithUnsentDailyHighscores];
	NSMutableArray* idsOfLeaderboardWithNoUnsentRecords = [NSMutableArray array];
	
	// 未送信レコードが存在しないリーダーボード一覧をしらべます
	for (PNLeaderboard* leaderboard in leaderboards) {
		BOOL hasUnsentRecords = NO;
		for (PNLeaderboard* leaderboardWithUnsentRecord in leaderboardWithUnsentRecords) {
			if (leaderboard.leaderboardId == leaderboardWithUnsentRecord.leaderboardId) {
				hasUnsentRecords = YES;
				break;
			}
		}
		
		if (hasUnsentRecords == NO) {
			[idsOfLeaderboardWithNoUnsentRecords addObject:[NSNumber numberWithInt:leaderboard.leaderboardId]];
		}
	}
	
	// 対象リーダーボードの最新スコアを取得しにいきます
	[[PNLeaderboardManager sharedObject] getLatestScoreOnLeaderboards:idsOfLeaderboardWithNoUnsentRecords onSuccess:^(NSArray *scores) {
		for (PNRank* rank in scores) {
			int64_t latestDownloadedScore = [self latestDownloadedScoreOnLeaderboard:rank.leaderboardId userId:[[PNUser currentUser].userId intValue]];
			if (latestDownloadedScore != rank.score) {
				[self insertDownloadedScoreToLeaderboard:rank.leaderboardId userId:[[PNUser currentUser].userId intValue] score:rank.score];
			}
			
			PNCLog(PNLOG_CAT_LOCALDB, @"Leaderboard[%d]\t server:%lld\tlocal:%lld", rank.leaderboardId, rank.score, latestDownloadedScore);
		}
	} onFailure:^(PNError *arg1) {
		PNWarn(@"Leaderboard downsync error. %@", arg1);
	}];
}

- (void)setSyncScore:(int64_t)result onLeaderboard:(PNLeaderboard*)leaderboard toRecordId:(int)recordId
{
	[self setSyncScore:result onLeaderboard:leaderboard userId:[[PNUser currentUser].userId intValue] toRecordId:recordId];
}

/**! 指定した日付の日付キーを返します。日付キーはUTC時間における日にち(yyyy/MM/dd)で表される文字列になります。 **/
- (NSString*)dateKeyFromDate:(NSDate*)date
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[dateFormatter setDateFormat:@"yyyyMMdd"];
	return [dateFormatter stringFromDate:date];
}
/**! スコア投稿に失敗した時に呼ばれるメソッドです */
- (BOOL)onPostScoreFailedWithError:(PNError*)error 
{
	if ([delegate respondsToSelector:@selector(postScoreFailedWithError:)]) {
		[delegate performSelector:@selector(postScoreFailedWithError:) withObject:error];
	}
	return NO;
}
- (BOOL)onPostScoreFailedWithErrorCode:(NSString*)errorCode message:(NSString*)message
{
	return [self onPostScoreFailedWithError:[PNError errorWithCode:errorCode message:message]];
}
/*!
 * ローカルのリーダーボードにスコアを追加します。
 * 必要に応じてサーバーとの同期も行います。
 */
- (BOOL)postScore:(int64_t)score leaderboardId:(int)leaderboardId userId:(int)userId delta:(BOOL)delta result:(int64_t*)result
{
	// マスターに存在しないリーダーボードであれば、失敗させます
	PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	if (leaderboard == nil) {
		PNWarn(@"LEADERBOARD not found with id: %d", leaderboardId);
		return [self onPostScoreFailedWithErrorCode:@"leaderboard_not_found" 
											message:[NSString stringWithFormat:@"Leaderboard with id (%d) not found.", leaderboardId]];
	}
	
	@synchronized (self) {
		// 現在のスコアを読みにいきます
		PNLocalLeaderboardScore* currentScore = [self currentScoreOnLeaderboard:leaderboard userId:userId];
		*result = currentScore.score;	// スコアのポストが完了するまで、resultには暫定スコア(前回までの総合ハイスコア)を代入しておきます
		
		// ボードの設定がmaxでデルタがマイナスの場合、ボードの設定がminでデルタがプラスの場合は無視します。
		if (delta == YES && ((leaderboard.sortBy == kPNSortByMaximum && score < 0) || (leaderboard.sortBy == kPNSortByMinimum && score > 0))) {
			if (score < 0) PNWarn(@"Warning: Tried to decrease score on acsending ordered leaderboard.");
			if (score > 0) PNWarn(@"Warning: Tried to increase score on descending oredered leaderboard.");
			return [self onPostScoreFailedWithErrorCode:@"score_was_ignored" message:@"score was ignored."];
		} 
		
		// 暫定スコアを計算します (デルタコミットの場合は現在のローカルハイスコアに加算、そうでない場合は今回のコミット値)
		int64_t provisionalScore = delta ? currentScore.score + score : score;
		
		// 暫定ハイスコアを計算します
		int64_t provisionalHighScore = provisionalScore;
		if (leaderboard.sortBy == kPNSortByMaximum && provisionalScore < currentScore.score) provisionalHighScore = currentScore.score;
		if (leaderboard.sortBy == kPNSortByMinimum && provisionalScore > currentScore.score && currentScore.score != 0) provisionalHighScore = currentScore.score;
		
		// 一度ローカルに今回の暫定スコアを記録します。この値は後でサーバーと同期され、必要に応じて修正されます
		[self insertNewScoreToLeaderboard:leaderboardId userId:userId score:score result:provisionalHighScore delta:delta];
		*result = provisionalHighScore;
		
		// 今日のハイスコアかどうかを調べます
		{
			NSString* keyForToday = [self dateKeyFromDate:[NSDate date]];	// 今日の日付キーを取得します
			
			// 今日すでにスコアがあるかしらべます
			BOOL hasScoreOfToday = [self hasDailyHighscoreOfDate:keyForToday leaderboard:leaderboardId userId:userId];

			if (!hasScoreOfToday) {	// なければ登録します
				// 登録します。デルタの場合は差分値が保存されます。
				[self insertNewDailyHighscore:score delta:delta date:keyForToday leaderboard:leaderboardId userId:userId];
			} else {	// あれば、現在のものより優れたスコアであれば上書きします
				// 今日のハイスコアを調べます
				PNLocalLeaderboardScore* highscoreOfToday = [self highscoreOfDate:keyForToday leaderboard:leaderboardId userId:userId];
				
				// ハイスコアより優れたスコアだったら更新します
				// 絶対値コミットの場合とデルタコミットの場合で処理はわかれます
				BOOL shouldUpdateDailyHighscore = NO;
				if (delta) {	// デルタコミットの場合は、かならず更新します。(maxにマイナスデルタが指定された場合等は、先の条件分岐ではじかれています)
					shouldUpdateDailyHighscore = YES;
				} else {
					if (highscoreOfToday.isDelta) {	// 現在のハイスコアがデルタコミットで、今回が絶対値コミットの場合は上書きします
						shouldUpdateDailyHighscore = YES;
						highscoreOfToday.isDelta = NO;	// 絶対値コミットにレコードの種類を変更します
					} else {	// 現在のハイスコアが絶対値コミットの場合は、リーダーボードの設定に応じて優れているかを判定します。
						if (leaderboard.sortBy == kPNSortByMaximum && provisionalScore > highscoreOfToday.score) 
							shouldUpdateDailyHighscore = YES;
						if (leaderboard.sortBy == kPNSortByMinimum && provisionalScore < highscoreOfToday.score)
							shouldUpdateDailyHighscore = YES;
						if (leaderboard.sortBy == kPNSortByLatest) shouldUpdateDailyHighscore = YES;
					}
				}
				
				if (shouldUpdateDailyHighscore) { // 上書きするべきだったら上書きします
					// 上書きするべき値を決定します。
					// デルタコミットの場合は、今日のハイスコアに今回の差分を加算した値、絶対値コミットの場合は今回のコミット値にします。
					int64_t scoreToSave = delta ? highscoreOfToday.score + score : provisionalScore;
					[self updateDailyHighscore:scoreToSave delta:highscoreOfToday.isDelta date:keyForToday leaderboard:leaderboardId userId:userId];
				} else {
					// 更新の必要がなければ、その旨を伝えて終了します。
					return [self onPostScoreFailedWithErrorCode:@"highscore_not_updated" message:@"highscore_not_updated"];
				}
			}
		}

		// オフライン状態だったら、同期に失敗した旨をすぐに伝えます。
		if (![PNManager sharedObject].isLoggedIn) return [self onPostScoreFailedWithError:[PNError connectionError]];
		
		// サーバーと同期します。
		[PNLocalLeaderboardUpSyncQueue sharedObject].delegate = self;
		[[PNLocalLeaderboardUpSyncQueue sharedObject] start];

	}
	return YES;
}

// 未送信レコードがある(UpSyncの必要がある)リーダーボード一覧を返します
- (NSArray*)leaderboardsWithUnsentRecords 
{
	NSArray* ids = [self idsOfLeaderboardWithUnsentScoresOfUser:[[PNUser currentUser].userId intValue]];
	NSMutableArray* leaderboards = [NSMutableArray array];
	for (NSNumber* leaderboardId in ids) {
		PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:[leaderboardId intValue]];
		if (leaderboard) {
			[leaderboards addObject:leaderboard];
		}
	}
	return leaderboards;
}
- (NSArray*)leaderboardsWithUnsentDailyHighscores
{
	NSArray* ids = [self idsOfLeaderboardWithUnsentDailyHighscoresOfUser:[[PNUser currentUser].userId intValue]];
	NSMutableArray* leaderboards = [NSMutableArray array];
	for (NSNumber* leaderboardId in ids) {
		PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:[leaderboardId intValue]];
		if (leaderboard) {
			[leaderboards addObject:leaderboard];
		}
	}
	return leaderboards;
}
- (BOOL)hasUnsentAbsoluteScoreCommitOnLeaderboard:(PNLeaderboard *)leaderboard
{
	return [self hasUnsentAbsoluteScoreCommitOnLeaderboard:leaderboard userId:[[PNUser currentUser].userId intValue]];
}
- (int64_t)sumOfUnsentCommitDeltasOnLeaderboard:(PNLeaderboard*)leaderboard toRecordId:(int)recordId;
{
	return [self sumOfUnsentCommitDeltasOnLeaderboard:leaderboard userId:[[PNUser currentUser].userId intValue] toRecordId:recordId];
}
#pragma mark DB-Access
- (void)changeRecordOwnerFrom:(int)oldUserId to:(int)newUserId
{
	const char *sql = "UPDATE leaderboard_scores SET user_id = ? WHERE user_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int(statement, 1, newUserId);
	sqlite3_bind_int(statement, 2, oldUserId);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNCLog(PNLOG_CAT_DB, @"Failed to update records in table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
- (int64_t)sumOfUnsentCommitDeltasOnLeaderboard:(PNLeaderboard*)leaderboard userId:(int)userId toRecordId:(int)recordId
{
	//問い合わせ用のSQLを生成します
	int64_t sum = 0;
	const char *sql = "SELECT score FROM leaderboard_scores WHERE user_id = ? and leaderboard_id = ? and up_sync_at is null and delta = 1 and id <= ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_int(statement, 2, leaderboard.leaderboardId);
		sqlite3_bind_int(statement, 3, recordId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			sum += sqlite3_column_int64(statement, 0);
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return sum;
}
- (BOOL)hasUnsentAbsoluteScoreCommitOnLeaderboard:(PNLeaderboard*)leaderboard userId:(int)userId
{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT id FROM leaderboard_scores WHERE user_id = ? and leaderboard_id = ? and up_sync_at is null and delta = 0";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_int(statement, 2, leaderboard.leaderboardId);
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
- (void)setSyncScore:(int64_t)result onLeaderboard:(PNLeaderboard *)leaderboard userId:(int)userId toRecordId:(int)recordId
{
	PNCLog(PNLOG_CAT_DB, @"setSyncScore:%lld toRecordId:%d", result, recordId);
	const char *sql = "UPDATE leaderboard_scores SET revised_score = ? , up_sync_at = current_timestamp WHERE user_id = ? and leaderboard_id = ? and up_sync_at is null and id <= ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int64(statement, 1, result);
	sqlite3_bind_int(statement, 2, userId);
	sqlite3_bind_int(statement, 3, leaderboard.leaderboardId);
	sqlite3_bind_int(statement, 4, recordId);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNCLog(PNLOG_CAT_DB, @"Failed to update records in table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
/*!
 * 指定したユーザのレコードで未送信のものがあるリーダーボードのIDをリストで返します。
 */
- (NSArray*)idsOfLeaderboardWithUnsentScoresOfUser:(int)userId
{
	NSMutableArray* ids = [NSMutableArray array];
	
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT distinct leaderboard_id FROM leaderboard_scores WHERE up_sync_at is null and down_sync_at is null and user_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int leaderboard_id = sqlite3_column_int(statement, 0);
			[ids addObject:[NSNumber numberWithInt:leaderboard_id]];
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return ids;
}
- (NSArray*)idsOfLeaderboardWithUnsentDailyHighscoresOfUser:(int)userId
{
	NSMutableArray* ids = [NSMutableArray array];
	
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT distinct leaderboard_id FROM leaderboard_dailyhighscores WHERE up_sync_at is null and user_id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int leaderboard_id = sqlite3_column_int(statement, 0);
			[ids addObject:[NSNumber numberWithInt:leaderboard_id]];
		}
	}else {
		PNWarn(@"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return ids;
}
- (void)insertDownloadedScoreToLeaderboard:(int)leaderboardId userId:(int)userId score:(int64_t)score
{
	const char *sql = "insert into leaderboard_scores (leaderboard_id, user_id, score, revised_score, down_sync_at) values (?, ?, ?, ?, current_timestamp)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int(statement, 1, leaderboardId);
	sqlite3_bind_int(statement, 2, userId);
	sqlite3_bind_int64(statement, 3, score);
	sqlite3_bind_int64(statement, 4, score);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
- (void)insertNewScoreToLeaderboard:(int)leaderboardId userId:(int)userId score:(int64_t)score result:(int64_t)result delta:(BOOL)delta
{
	const char *sql = "insert into leaderboard_scores (scored_at, leaderboard_id, user_id, score, commit_score, revised_score, delta) values (current_timestamp, ?, ?, ?, ?, ?, ?)";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int(statement, 1, leaderboardId);
	sqlite3_bind_int(statement, 2, userId);
	sqlite3_bind_int64(statement, 3, score);
	sqlite3_bind_int64(statement, 4, result);
	sqlite3_bind_int64(statement, 5, result);
	sqlite3_bind_int(statement, 6, delta ? 1 : 0);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNCLog(PNLOG_CAT_DB, @"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
- (PNLocalLeaderboardScore*)currentScoreOnLeaderboard:(PNLeaderboard*)leaderboard userId:(int)userId
{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT revised_score, id FROM leaderboard_scores WHERE user_id = ? and leaderboard_id = ? ORDER BY id desc limit 1";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_int(statement, 2, leaderboard.leaderboardId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//int score = sqlite3_column_int(statement, 0);
			
			PNLocalLeaderboardScore* score = [[[PNLocalLeaderboardScore alloc] init] autorelease];
			score.score = sqlite3_column_int64(statement, 0);
			score.recordId = sqlite3_column_int(statement, 1);
			score.leaderboardId = leaderboard.leaderboardId;
			score.userId = userId;
			
			sqlite3_finalize(statement);
			return score;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	
	// レコードが存在しなければ、scoreBaseを返すようにします
	PNCLog(PNLOG_CAT_LOCALDB, @"There are no records on leaderboard[%d]", leaderboard.leaderboardId);
	PNLocalLeaderboardScore* score = [[[PNLocalLeaderboardScore alloc] init] autorelease];
	score.score = leaderboard.scoreBase;
	score.recordId = 0;
	score.leaderboardId = leaderboard.leaderboardId;
	score.userId = userId;
	
	sqlite3_finalize(statement);
	return score;
}
- (int64_t)latestDownloadedScoreOnLeaderboard:(int)leaderboardId userId:(int)userId
{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT revised_score FROM leaderboard_scores WHERE user_id = ? and leaderboard_id = ? and down_sync_at is not null ORDER BY scored_at desc, id desc limit 1";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_int(statement, 2, leaderboardId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int64_t score = sqlite3_column_int64(statement, 0);
			sqlite3_finalize(statement);
			return score;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return 0;
}
// 一秒以内に複数件のスコア送信があった場合用のハッシュを作成
- (NSString*)newHashKey
{
	// 日付と乱数から生成
	// (10000分の1の確率で問題が発生する可能性があるが、基本的には1秒以内に複数回のスコア送信は想定していないので、保証しない)
	return [NSString stringWithFormat:@"%@-%d", [NSDate date], rand() % 10000];
}
#pragma mark Daily highscore 
- (void)insertNewDailyHighscore:(int64_t)score delta:(BOOL)delta date:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId
{
	const char *sql = "insert into leaderboard_dailyhighscores (leaderboard_id, user_id, score, scored_at, date_key, delta, up_sync_hash, commit_score) values (?, ?, ?, current_timestamp, ?, ?, ?, ?)";
	
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int(statement, 1, leaderboardId);
	sqlite3_bind_int(statement, 2, userId);
	sqlite3_bind_int64(statement, 3, score);
	sqlite3_bind_text(statement, 4, [dateKey cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, 5, delta ? 1 : 0);
	sqlite3_bind_text(statement, 6, [[self newHashKey] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int64(statement, 7, 0);
	
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNWarn(@"Failed to insert a record to table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
/**! 指定した日付のハイスコアを返します */
- (PNLocalLeaderboardScore*)highscoreOfDate:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId
{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT score, delta, up_sync_hash, up_sync_at, commit_score FROM leaderboard_dailyhighscores WHERE user_id = ? and leaderboard_id = ? and date_key = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_int(statement, 2, leaderboardId);
		sqlite3_bind_text(statement, 3, [dateKey cStringUsingEncoding:NSUTF8StringEncoding], -1, NULL);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			PNLocalLeaderboardScore* score = [[[PNLocalLeaderboardScore alloc] init] autorelease];
			score.score = sqlite3_column_int64(statement, 0);
			score.isDelta = sqlite3_column_int(statement, 1);
			score.leaderboardId = leaderboardId;
			score.userId = userId;
			score.upSyncHash = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
			score.commitScore = sqlite3_column_int64(statement, 2);
			sqlite3_finalize(statement);
			return score;
		}
	}else {
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
	
	return 0;
}
/**! 指定した日付のハイスコアがあるかどうかを調べます */
- (BOOL)hasDailyHighscoreOfDate:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId
{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT id FROM leaderboard_dailyhighscores WHERE user_id = ? and leaderboard_id = ? and date_key = ? limit 1";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_int(statement, 2, leaderboardId);
		sqlite3_bind_text(statement, 3, [dateKey cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
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
/**! 指定した日付のハイスコアを上書きします。またsyncのフラグを元に戻します。**/
- (void)updateDailyHighscore:(int64_t)score delta:(BOOL)delta date:(NSString*)dateKey leaderboard:(int)leaderboardId userId:(int)userId
{
	const char *sql = "UPDATE leaderboard_dailyhighscores SET score = ? , up_sync_at = null, scored_at = current_timestamp, delta = ?, up_sync_hash = ? WHERE user_id = ? and leaderboard_id = ? and date_key = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int64(statement, 1, score);
	sqlite3_bind_int(statement, 2, delta);
	sqlite3_bind_text(statement, 3, [[self newHashKey] UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, 4, userId);
	sqlite3_bind_int(statement, 5, leaderboardId);
	sqlite3_bind_text(statement, 6, [dateKey cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNWarn(@"Failed to update records in table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
- (PNLocalLeaderboardScore*)unsentDailyHighScoreOnLeaderboard:(PNLeaderboard*)leaderboard userId:(int)userId
{
	//問い合わせ用のSQLを生成します
	const char *sql = "SELECT score, id, scored_at, date_key, delta, up_sync_hash, commit_score FROM leaderboard_dailyhighscores WHERE user_id = ? and leaderboard_id = ? and up_sync_at is null ORDER BY id desc limit 1";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_int(statement, 1, userId);
		sqlite3_bind_int(statement, 2, leaderboard.leaderboardId);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			//int score = sqlite3_column_int(statement, 0);
			
			PNLocalLeaderboardScore* score = [[[PNLocalLeaderboardScore alloc] init] autorelease];
			score.score = sqlite3_column_int64(statement, 0);
			score.recordId = sqlite3_column_int(statement, 1);
			score.scoredAt = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
			score.dateKey = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
			score.isDelta = sqlite3_column_int(statement, 4);
			score.upSyncHash = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
			score.leaderboardId = leaderboard.leaderboardId;
			score.commitScore = sqlite3_column_int64(statement, 6);
			score.userId = userId;
			
			sqlite3_finalize(statement);
			return score;
		}
	}else {
		PNWarn(@"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	
	// レコードが存在しなければ、nilを返します
	sqlite3_finalize(statement);
	return nil;
}
- (void)setSyncDateOnDailyHighScore:(PNLocalLeaderboardScore*)synchronizedScore
{
	const char *sql = "UPDATE leaderboard_dailyhighscores SET up_sync_at = current_timestamp, commit_score= ? WHERE id = ?";
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2([PNLocalDB sharedObject].database, sql, -1, &statement, NULL) != SQLITE_OK){
		PNCLog(PNLOG_CAT_DB, @"prepare error. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_bind_int64(statement, 1, synchronizedScore.score);
	sqlite3_bind_int64(statement, 2, synchronizedScore.recordId);
//	sqlite3_bind_text(statement, 3, [synchronizedScore.upSyncHash UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) != SQLITE_DONE){
		PNWarn(@"Failed to update records in table. %s", sqlite3_errmsg([PNLocalDB sharedObject].database));
	}
	sqlite3_finalize(statement);
}
#pragma mark Migration
- (void)createTable
{
	PNCLog(PNLOG_CAT_LOCALDB, @"Creating local leaderboard db");
		   
	// テーブル作成用のSQLを実行します
	NSString* sqlFileForTable = [[NSBundle mainBundle] pathForResource:@"PNLeaderboardMigration1" ofType:@"sql"];
	[[PNLocalDB sharedObject] doPlainSQL:[NSString stringWithContentsOfFile:sqlFileForTable encoding:NSUTF8StringEncoding error:nil]];	
	
	// マイグレーション番号を更新します
	[[PNLocalDB sharedObject] updateMigrationNumber:1 forTable:kPNLeaderboardTableName];
}
- (void)createDailyHighscoreTable
{
	PNWarn(@"Local leaderboard migration: Creating daily highscore table...");
	
	// テーブル作成用のSQLを実行します
	NSString* sqlFileForTable = [[NSBundle mainBundle] pathForResource:@"PNLeaderboardMigration2" ofType:@"sql"];
	[[PNLocalDB sharedObject] doPlainSQL:[NSString stringWithContentsOfFile:sqlFileForTable encoding:NSUTF8StringEncoding error:nil]];	
	
	// マイグレーション番号を更新します
	[[PNLocalDB sharedObject] updateMigrationNumber:2 forTable:kPNLeaderboardTableName];
}
- (void)doMigrationIfNeeded
{
	// 現在のマイグレーション番号を取得しにいきます
	int currentMigrationNumber = [[PNLocalDB sharedObject] currentMigrationNumberOfTableNamed:kPNLeaderboardTableName];
	PNCLog(PNLOG_CAT_LOCALDB, @"CURRENT MIGRATION NUMBER: %d", currentMigrationNumber);

	// -1だったらテーブルを作ります
	if (currentMigrationNumber == -1) [self createTable];
	
	// 後々のアップグレードに関するマイグレーションの処理はここに書いてください。
	if (currentMigrationNumber <= 1) [self createDailyHighscoreTable];
}
#pragma mark -
- (void)postScoreSucceeded:(NSArray*)scores
{
	if ([delegate respondsToSelector:@selector(postScoreSucceeded:)]) {
		[delegate performSelector:@selector(postScoreSucceeded:) withObject:scores];
	}
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	if (self = [super init]){
		
		@synchronized(self){		
			PNCLog(PNLOG_CAT_LOCALDB, @"PNLocalLeaderboard init");
			
			//マイグレーションが必要だったらマイグレーションします
			[self doMigrationIfNeeded];
		}
	}
	return self;
}

- (void) dealloc{
	[super dealloc];
}

+ (PNLocalLeaderboard*)sharedObject
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
