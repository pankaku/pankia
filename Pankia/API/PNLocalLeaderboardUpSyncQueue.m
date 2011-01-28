//
//  PNLocalLeaderboardUpSyncQueue.m
//  PankakuNet
//
//  Created by pankaku on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLocalLeaderboardUpSyncQueue.h"
#import "PNLogger+Package.h"
#import "PNLeaderboard.h"
#import "PNLocalLeaderboard.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNLeaderboardRequestHelper.h"
#import "PNRequestKeyManager.h"
#import "PNScoreModel.h"
#import "PNLeaderboardManager.h"
#import "PNRank.h"
#import "PNRank+Package.h"

static PNLocalLeaderboardUpSyncQueue* _sharedInstance;
static const int kPNLeaderboardRetryInterval = 10.0f;

@interface PNLocalLeaderboardUpSyncQueue()
@property (nonatomic, retain) NSString* currentRequestKey;
@end

@interface PNLocalLeaderboardUpSyncQueue(Private)
- (void)doUpSyncLeaderboard:(PNLeaderboard*)leaderboard;
- (void)doNextStep;
- (void)sendDailyHighscoreOnLeaderboard:(PNLeaderboard*)leaderboard;
- (void)stop;
@end

@implementation PNLocalLeaderboardUpSyncQueue
@synthesize currentRequestKey, delegate;
- (void)doUpSyncLeaderboard:(PNLeaderboard*)leaderboard
{
	PNSplitLog(PNLOG_CAT_LOCALDB);
	PNCLog(PNLOG_CAT_LOCALDB, @"Synchronizing [%d]%@", leaderboard.leaderboardId, leaderboard.name);
	
	PNLocalLeaderboardScore* latestScore = [[PNLocalLeaderboard sharedObject] currentScoreOnLeaderboard:leaderboard
																								 userId:[[PNUser currentUser].userId intValue]];
	if (latestScore == nil) {
		[self doNextStep];
		return;
	}
	
	NSString* requestKey = [PNRequestKeyManager registerDelegate:self onSucceededSelector:nil 
												onFailedSelector:nil withObject:latestScore];
	self.currentRequestKey = requestKey;
	
	if ([[PNLocalLeaderboard sharedObject] hasUnsentAbsoluteScoreCommitOnLeaderboard:leaderboard]) {
		// 絶対値コミットがひとつでもあれば、こっちをマスターにする
		[PNLeaderboardRequestHelper postScore:latestScore.score
								  leaderboard:leaderboard.leaderboardId
										delta:NO
									   period:@"forever"
									 delegate:self // コネクションエラー処理 -> error:userInfo:
									 selector:@selector(postScoreResponse:) // 応答処理delegate
								   requestKey:requestKey];
	} else {
		PNCLog(PNLOG_CAT_LOCALDB, @"DELTA COMMIT");
		// 現在のサーバーの値を取得して、それに差分をマージした上でコミットします	
		currentScoreToSync = latestScore;
		
		[[PNLeaderboardManager sharedObject] getLatestScoreOnLeaderboards:[NSArray arrayWithObject:[NSNumber numberWithInt:leaderboard.leaderboardId]] onSuccess:^(NSArray *scores) {
			PNRank* currentScore = (PNRank*)[scores objectAtIndex:0];
			PNRequestObject* request = [PNRequestKeyManager requestForKey:currentRequestKey];
			PNLocalLeaderboardScore *scoreToPost = (PNLocalLeaderboardScore*)(request.object);
			int64_t sumOfDeltas = [[PNLocalLeaderboard sharedObject] sumOfUnsentCommitDeltasOnLeaderboard:[PNLeaderboardManager leaderboardById:scoreToPost.leaderboardId]
																							   toRecordId:scoreToPost.recordId];
			
			PNCLog(PNLOG_CAT_LOCALDB, @"DELTA COMMIT: %lld", sumOfDeltas);
			[PNLeaderboardRequestHelper postScore:currentScore.score + sumOfDeltas
									  leaderboard:currentScore.leaderboardId
											delta:NO
										   period:@"forever"
										 delegate:self // コネクションエラー処理 -> error:userInfo:
										 selector:@selector(postScoreResponse:) // 応答処理delegate
									   requestKey:@"allok"];
		} onFailure:^(PNError *error) {
			PNWarn(@"Leaderboard upsync error. %@", error);
			[self performSelector:@selector(doNextStep) withObject:nil afterDelay:kPNLeaderboardRetryInterval];
		}];
	}
}
- (void)sendDailyHighscoreOnLeaderboard:(PNLeaderboard*)leaderboard
{
	PNLocalLeaderboardScore* dailyHighScoreToSync = [[PNLocalLeaderboard sharedObject] unsentDailyHighScoreOnLeaderboard:leaderboard 
																							  userId:[[PNUser currentUser].userId intValue]];
	int64_t diff = 0;
	if (dailyHighScoreToSync.isDelta) {
		diff = dailyHighScoreToSync.score - dailyHighScoreToSync.commitScore;
		NSLog(@"Send daily highscore. scoreToday: %lld, commited: %lld, diff: %lld", dailyHighScoreToSync.score, dailyHighScoreToSync.commitScore, diff);
	}
	
	NSString* requestKey = [PNRequestKeyManager registerDelegate:self onSucceededSelector:nil 
												onFailedSelector:nil withObject:dailyHighScoreToSync];
	[PNLeaderboardRequestHelper postScore:dailyHighScoreToSync.isDelta ? diff : dailyHighScoreToSync.score
							  leaderboard:dailyHighScoreToSync.leaderboardId
									delta:dailyHighScoreToSync.isDelta
								   period:@"forever"
								 delegate:self // コネクションエラー処理 -> error:userInfo:
								 selector:@selector(postDailyHighScoreResponse:) // 応答処理delegate
							   requestKey:requestKey];
}
- (void)postDailyHighScoreResponse:(PNHTTPResponse*)response
{
	PNLocalLeaderboardScore* scoreToPost = (PNLocalLeaderboardScore*)(response.request.object);
	if (response.isValidAndSuccessful) {	// ポストに成功したらフラグをたてます
		NSLog(@"%@", response.jsonString);
		[[PNLocalLeaderboard sharedObject] setSyncDateOnDailyHighScore:scoreToPost];
		[self doNextStep];
	} else {
		// 失敗した場合は、処理を中断します。
		PNWarn(@"Server error at posting daily high score. %@", response.error.errorCode);
		return;
	}
}

- (void)postScoreResponse:(PNHTTPResponse*)response
{
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:self.currentRequestKey];
	PNLocalLeaderboardScore *scoreToPost = (PNLocalLeaderboardScore*)(request.object);	

	if (response.isValidAndSuccessful) {
		// そのリーダーボードの最新を読みにいきます
		currentScoreToSync = scoreToPost;
		
		[[PNLeaderboardManager sharedObject] getLatestScoreOnLeaderboards:[NSArray arrayWithObject:[NSNumber numberWithInt:scoreToPost.leaderboardId]] onSuccess:^(NSArray *scores) {
			PNRequestObject* request = [PNRequestKeyManager requestForKey:self.currentRequestKey];
			PNLocalLeaderboardScore *scoreToPost = (PNLocalLeaderboardScore*)(request.object);
			PNRank* currentScore = (PNRank*)[scores objectAtIndex:0];
			[[PNLocalLeaderboard sharedObject] setSyncScore:currentScore.score
											  onLeaderboard:[PNLeaderboardManager leaderboardById:scoreToPost.leaderboardId]
												 toRecordId:currentScoreToSync.recordId];
			
			[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:self.currentRequestKey];
			self.currentRequestKey = nil;
			
			[self doNextStep];
		} onFailure:^(PNError *error) {
			PNWarn(@"ERROR in getLatestScoreFailed, PNLocalLeaderboardUpSyncQueue %@", error.message);
		} ];

		// delegate callback
		if ([delegate respondsToSelector:@selector(postScoreSucceeded:)]) {
			NSArray* scoreModels = [PNScoreModel dataModelsFromArray:[json objectForKey:@"scores"]];
			NSMutableArray* scores = [NSMutableArray array];
			for (PNScoreModel* scoreModel in scoreModels) {
				PNRank* score = [[[PNRank alloc] initWithScoreModel:scoreModel] autorelease];
				score.leaderboardId = ((PNLocalLeaderboardScore*)(request.object)).leaderboardId;
				[scores addObject:score];
			}
			[delegate performSelector:@selector(postScoreSucceeded:) withObject:scores];
		}
	} else {
		// TODO: 失敗した時の処理をいれる
		PNWarn(@"ERROR in postScoreResponse, PNLocalLeaderboardUpSyncQueue %@", resp);
	}
}
// コネクション・エラーの後処理
- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNCLog(PNLOG_CAT_LEADERBOARDS, @"%s", __FUNCTION__);
	
	//タイムアウトエラーなどでリクエストに失敗した場合は、少し待った後でもう一度試します。
	[self performSelector:@selector(doNextStep) withObject:nil afterDelay:kPNLeaderboardRetryInterval];
}

- (void)doNextStep
{
	PNCLog(PNLOG_CAT_LOCALDB, @"doNextStep");
	
	// オフラインだったらあきらめます
	if ([PNUser currentUser].sessionId == nil){
		PNCLog(PNLOG_CAT_LOCALDB, @"Offline.");
		[self stop];
		return;
	}
	
	// 2010.12.13 ロジック変更
	// まず未送信デイリーハイスコアがある場合は、そっちを同期します。
	NSArray* leaderboardsWithUnsentDailyHighscores = [[PNLocalLeaderboard sharedObject] leaderboardsWithUnsentDailyHighscores];
	if ([leaderboardsWithUnsentDailyHighscores count] > 0) {
		// 未送信デイリーハイスコアを送信します
		PNLeaderboard* leaderboardToUpSync = [leaderboardsWithUnsentDailyHighscores objectAtIndex:0];
		[self sendDailyHighscoreOnLeaderboard:leaderboardToUpSync];
	} else {
		[self stop];
		return;
		/*
		// アップシンクしていないレコードがあるリーダーボードを一つ取得します
		NSArray* leaderboardsWithUnsentScores = [[PNLocalLeaderboard sharedObject] leaderboardsWithUnsentRecords];
		
		// 一件もなければ終了します
		if ([leaderboardsWithUnsentScores count] == 0) {
			[self stop];
			return;
		}
		
		PNLeaderboard* leaderboardToUpSync = [leaderboardsWithUnsentScores objectAtIndex:0];
		[self doUpSyncLeaderboard:leaderboardToUpSync];
		 */
	}
}

- (void)start {
	@synchronized (self) {		
		if (isRunning) {
			PNCLog(PNLOG_CAT_LOCALDB, @"LocalLeaderboardUpSyncQueue is already running.");
			return;
		}
		
		isRunning = YES;
		PNCLog(PNLOG_CAT_LOCALDB, @"LocalLeaderboardUpSyncQueue start");
		[self doNextStep];
	}
}
- (void)stop
{
	@synchronized (self) {
		PNCLog(PNLOG_CAT_LOCALDB, @"LocalLeaderboardUpSyncQueue stopped.");
		isRunning = NO;
	}
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	if (self = [super init]){
		isRunning = NO;
	}
	return self;
}

- (void) dealloc{
	[super dealloc];
}

+ (PNLocalLeaderboardUpSyncQueue*)sharedObject
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
