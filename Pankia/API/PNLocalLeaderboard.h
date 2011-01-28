//
//  PNLocalLeaderboard.h
//  PankakuNet
//
//  Created by pankaku on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNLeaderboard;
@class PNRank;

@interface PNLocalLeaderboardScore : NSObject {
	int64_t score;
	int64_t commitScore;
	int leaderboardId;
	int userId;
	int recordId;
	BOOL isDelta;
	NSString* dateKey;
	NSString* scoredAt;
	NSString* upSyncHash;
}
@property (nonatomic, assign) int leaderboardId, userId, recordId;
@property (nonatomic, assign) int64_t score, commitScore;
@property (nonatomic, copy) NSString* dateKey, *scoredAt, *upSyncHash;
@property (assign) BOOL isDelta;
@end

@interface PNLocalLeaderboard : NSObject {
	id delegate;
}
@property (nonatomic, assign) id delegate;
+ (PNLocalLeaderboard*)sharedObject;
- (BOOL)postScore:(int64_t)score leaderboardId:(int)leaderboardId userId:(int)userId delta:(BOOL)delta result:(int64_t*)result;
- (PNLocalLeaderboardScore*)currentScoreOnLeaderboard:(PNLeaderboard*)leaderboard userId:(int)userId;
- (PNLocalLeaderboardScore*)unsentDailyHighScoreOnLeaderboard:(PNLeaderboard*)leaderboard userId:(int)userId;
- (void)doDownSync;
- (void)doUpSync;
- (void)setSyncScore:(int64_t)result onLeaderboard:(PNLeaderboard*)leaderboard toRecordId:(int)recordId;
- (void)setSyncDateOnDailyHighScore:(PNLocalLeaderboardScore*)synchronizedScore;
- (BOOL)hasUnsentAbsoluteScoreCommitOnLeaderboard:(PNLeaderboard*)leaderboard;
- (int64_t)sumOfUnsentCommitDeltasOnLeaderboard:(PNLeaderboard*)leaderboard toRecordId:(int)recordId;
- (NSArray*)leaderboardsWithUnsentRecords;
- (NSArray*)leaderboardsWithUnsentDailyHighscores; /**! サーバーに送信していないデイリーハイスコアがあるリーダーボード(PNLeaderboard)の一覧を返します **/
- (void)changeRecordOwnerFrom:(int)oldUserId to:(int)newUserId;
@end
