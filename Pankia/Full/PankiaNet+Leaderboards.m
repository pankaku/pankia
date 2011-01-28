//
//  PankiaNet+Leaderboards.m
//  PankakuNet
//
//  Created by sota2 on 10/10/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PankiaNet.h"
#import "PankiaNet+Package.h"

#import "PNUser.h"
#import "PNUser+Package.h"

#import "PNLeaderboardManager.h"
#import "PNLocalLeaderboard.h"
#import "PNLeaderboard.h"
#import "PNGameManager.h"

@implementation PankiaNet(Leaderboards)

+ (NSArray*)leaderboards
{
	return [[PNGameManager sharedObject] leaderboards];
}

/*!
 * リーダーボードにスコアをポストします。
 * ここでポストしたスコアはローカルのデータベースに保存され、必要に応じてサーバーと同期されます。
 */
+ (int64_t)postScore:(int64_t)score 
	   leaderboardId:(int)leaderboardId			
	   isIncremental:(BOOL)isIncremental
{
	int64_t result = 0;
	
	// ローカルのデータベースにスコアを送信します。
	// 必要に応じて自動的にサーバーと同期が行われます。
	[[PNLocalLeaderboard sharedObject] postScore:score leaderboardId:leaderboardId 
										  userId:[[PNUser currentUser].userId intValue] 
										   delta:isIncremental result:&result];
	
	// スコアをポストした結果の最新スコアを返します。
	// 注意：この状態で返されるスコアはローカルデータベース上で計算したものになります。
	// 複数端末を使用している場合などにサーバー上の値と結果が異なる場合があります。
	return result;
}

+ (int64_t)postScore:(int64_t)score 
	   leaderboardId:(int)leaderboardId
{
	return [self postScore:score leaderboardId:leaderboardId isIncremental:NO];
}

+ (float)postFloatScore:(float)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental
{
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	float result = 0;
	
	if( leaderboard.format == kPNLeaderboardFormatFloat1 ){
		
        result = [self postScore:(int64_t)round(score * 10.0f) leaderboardId:leaderboardId isIncremental:isIncremental]/10.0f;
	}
	else if ( leaderboard.format == kPNLeaderboardFormatFloat2 ){
		
        result = [self postScore:(int64_t)round(score * 100.0f) leaderboardId:leaderboardId isIncremental:isIncremental]/100.0f;
	}
	else if( leaderboard.format == kPNLeaderboardFormatFloat3 ){
		
        result = [self postScore:(int64_t)round(score * 100.0f) leaderboardId:leaderboardId isIncremental:isIncremental]/1000.0f;
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return result;
}

+ (float)postFloatScore:(float)score leaderboardId:(int)leaderboardId{
	
	return [self postFloatScore:score leaderboardId:leaderboardId isIncremental:NO]; 
}

+ (NSTimeInterval)postTimeScore:(NSTimeInterval)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental{
	
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	NSTimeInterval result = 0;
	
	// TODO: NSTimeInterval value should be converted to int64_t.
	// ex.
	//  input: 12345.67
	//  format is to the minute: 123
	//  format is to the second: 12345
	//  format is to the hundreth: 1234567
	
	if( leaderboard.format == kPNLeaderboardFormatElaspedTimeToMinute ){
		
        result = (NSTimeInterval)[self postScore:(int64_t)round(score / 60.0f) leaderboardId:leaderboardId isIncremental:isIncremental];
	}
	else if ( leaderboard.format == kPNLeaderboardFormatElaspedTimeToSecond ){
		
        result = (NSTimeInterval)[self postScore:(int64_t)round(score) leaderboardId:leaderboardId isIncremental:isIncremental];
	}
	else if( leaderboard.format == kPNLeaderboardFormatElaspedTimeToTheHunsredthOfASecond ){
		
        result = (NSTimeInterval)[self postScore:(int64_t)round(score * 100.0f) leaderboardId:leaderboardId isIncremental:isIncremental];
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return result;
}

+ (NSTimeInterval)postTimeScore:(NSTimeInterval)score leaderboardId:(int)leaderboardId{
	
	return [self postTimeScore:score leaderboardId:leaderboardId isIncremental:NO];
}

+ (int64_t)postMoneyScore:(int64_t)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental{
	
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	if( leaderboard.format == kPNLeaderboardFormatMoneyWholeNumbers ){
		
		return [self postScore:score leaderboardId:leaderboardId isIncremental:isIncremental];
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return 0;
}

+ (int64_t)postMoneyScore:(int64_t)score leaderboardId:(int)leaderboardId{
	
	return [self postMoneyScore:score leaderboardId:leaderboardId isIncremental:NO];
}

+ (float)postFloatMoneyScore:(float)score leaderboardId:(int)leaderboardId isIncremental:(BOOL)isIncremental{
	
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	float result = 0;
	
	if( leaderboard.format == kPNLeaderboardFormatMoneyTwoDecimals ){
		
        result = [self postScore:(int64_t)round(score * 100.0f) leaderboardId:leaderboardId isIncremental:isIncremental]/100.0f;
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return result;
}

+ (float)postFloatMoneyScore:(float)score leaderboardId:(int)leaderboardId{
	
	return [self postFloatMoneyScore:score leaderboardId:leaderboardId isIncremental:NO];
}

+ (void)fetchRankOnLeaderboard:(int)leaderboardId onSuccess:(void (^)(PNRank* rank))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[[PNLeaderboardManager sharedObject] getRankOnLeaderboard:leaderboardId username:[PNUser currentUser].username period:@"forever" among:PNLeaderboardRankAmongWorld onSuccess:onSuccess onFailure:onFailure];
}
- (void)getRankOnLeaderboardSucceeded:(NSArray*)ranks
{
	if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(fetchRankOnLeaderboardDone:) ]) {
		[[PankiaNet sharedObject].pankiaNetDelegate fetchRankOnLeaderboardDone:ranks];
	}
}
- (void)getRankOnLeaderboardFailed:(PNError*)error
{
	if ([pankiaNetDelegate respondsToSelector:@selector(fetchRankOnLeaderboardFailedWithError:)]){
		[pankiaNetDelegate fetchRankOnLeaderboardFailedWithError:error];
	}
}
+ (void)fetchLatestLeaderboardsScore:(NSArray*)leaderboardIds onSuccess:(void (^)(NSArray* scores))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[[PNLeaderboardManager sharedObject] getLatestScoreOnLeaderboards:leaderboardIds onSuccess:onSuccess onFailure:onFailure];
}
- (void)getLatestScoresSucceeded:(NSArray*)rankArray
{
	if ([pankiaNetDelegate respondsToSelector:@selector(fetchScoresOnLeaderboardDone:)]){
		[pankiaNetDelegate fetchScoresOnLeaderboardDone:rankArray];
	}
}
- (void)getLatestScoresFailed:(PNError*)error
{
	if ([pankiaNetDelegate respondsToSelector:@selector(fetchScoresOnLeaderboardFailedWithError:)]){
		[pankiaNetDelegate fetchScoresOnLeaderboardFailedWithError:error];
	}
}

+ (void)fetchAllLeaderboardsRankWithOnSuccess:(void (^)(NSArray* ranks))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	NSMutableArray* leaderboardIds = [NSMutableArray array];
	for (PNLeaderboard* leaderboard in [[PNGameManager sharedObject] leaderboards]) {
		[leaderboardIds addObject:[NSNumber numberWithInt:leaderboard.id]];
	}
	[[PNLeaderboardManager sharedObject] getRankOnLeaderboards:leaderboardIds username:[PNUser currentUser].username period:@"forever" among:PNLeaderboardRankAmongWorld onSuccess:onSuccess onFailure:onFailure];
}
+ (int64_t)latestScoreOnLeaderboard:(int)leaderboardId
{
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	if( leaderboard.format == kPNLeaderboardFormatInteger ){
		
		PNLocalLeaderboardScore *latestScore = [[PNLocalLeaderboard sharedObject] currentScoreOnLeaderboard:
												[PNLeaderboardManager leaderboardById:leaderboardId] userId:[PNUser currentUserId]];
		return latestScore.score;
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return 0;	
}

+ (float)latestFloatScoreOnLeaderboard:(int)leaderboardId{
	
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	PNLocalLeaderboardScore *latestScore = [[PNLocalLeaderboard sharedObject] currentScoreOnLeaderboard:
											[PNLeaderboardManager leaderboardById:leaderboardId] userId:[PNUser currentUserId]];
	float result = 0;
	
	if( leaderboard.format == kPNLeaderboardFormatFloat1 ){
		
        result = latestScore.score/10.0f;
	}
	else if ( leaderboard.format == kPNLeaderboardFormatFloat2 ){
		
        result = latestScore.score/100.0f;
	}
	else if( leaderboard.format == kPNLeaderboardFormatFloat3 ){
		
        result = latestScore.score/1000.0f;
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return result;
}

+ (NSTimeInterval)latestTimeScoreOnLeaderboard:(int)leaderboardId{
	
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	PNLocalLeaderboardScore *latestScore = [[PNLocalLeaderboard sharedObject] currentScoreOnLeaderboard:
											[PNLeaderboardManager leaderboardById:leaderboardId] userId:[PNUser currentUserId]];
	NSTimeInterval result = 0;
	
	if( leaderboard.format == kPNLeaderboardFormatElaspedTimeToMinute ){
		
        result = (NSTimeInterval)latestScore.score;
	}
	else if ( leaderboard.format == kPNLeaderboardFormatElaspedTimeToSecond ){
		
        result = (NSTimeInterval)latestScore.score;
	}
	else if( leaderboard.format == kPNLeaderboardFormatElaspedTimeToTheHunsredthOfASecond ){
		
        result = (NSTimeInterval)latestScore.score;
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return result;
}

+ (int64_t)latestMoneyScoreOnLeaderboard:(int)leaderboardId{
	
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	if( leaderboard.format == kPNLeaderboardFormatMoneyWholeNumbers ){
		
		PNLocalLeaderboardScore *latestScore = [[PNLocalLeaderboard sharedObject] currentScoreOnLeaderboard:
												[PNLeaderboardManager leaderboardById:leaderboardId] userId:[PNUser currentUserId]];
		return latestScore.score;
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return 0;
}

+ (float)latestFloatMoneyScoreOnLeaderboard:(int)leaderboardId{
	
    PNLeaderboard* leaderboard = [PNLeaderboardManager leaderboardById:leaderboardId];
	float result = 0;
	
	if( leaderboard.format == kPNLeaderboardFormatMoneyTwoDecimals ){
		
		PNLocalLeaderboardScore *latestScore = [[PNLocalLeaderboard sharedObject] currentScoreOnLeaderboard:
												[PNLeaderboardManager leaderboardById:leaderboardId] userId:[PNUser currentUserId]];
		result = latestScore.score/100.0f;
	}
	else {
		
        NSLog(@"Invalid format.");
	}
	
	return result;
}
- (void)postScoreSucceeded:(NSArray*)scores
{
	if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(postScoreDone:) ]) {
		[[PankiaNet sharedObject].pankiaNetDelegate postScoreDone:scores];
	}	
}
- (void)postScoreFailedWithError:(PNError*)error
{
	if ([[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(postScoreFailedWithError:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate postScoreFailedWithError:error];
	}
}
@end
