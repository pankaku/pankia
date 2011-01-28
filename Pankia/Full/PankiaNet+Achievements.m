//
//  PankiaNet+Achievements.m
//  PankakuNet
//
//  Created by sota2 on 10/10/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PankiaNet.h"
#import "PankiaNet+Package.h"

#import "PNUser.h"
#import "PNUser+Package.h"

#import "PNAchievement.h"
#import "PNAchievement+Package.h"

#import "PNAchievementManager.h"
#import "PNGameManager.h"

#import "PNDashboard.h"

@implementation PankiaNet(Achievements)
#pragma mark Achievements
+ (NSArray*)achievements {
	return [[PNGameManager sharedObject] achievements];
}
+ (NSArray*)unlockedAchievements
{
	return [[PNAchievementManager sharedObject] unlockedAchievements];
}

#pragma mark Get unlocked achievements

/**
 Achievementをアンロックします。
 AchievementをアンロックするとNortificationが表示されます。
 Achievementの情報(タイトル／説明など)がローカルで利用可能な場合はこのメソッドを呼んだ直後に、
 そうでない場合はサーバーとの通信後にNoritificationが表示されます。
 */
+ (void)unlockAchievement:(int)achievementId
{
	[[PNAchievementManager sharedObject] unlockAchievementById:achievementId];
}

+ (void)unlockAchievements:(NSArray*)achievementsToUnlock{
	[[PNAchievementManager sharedObject] unlockAchievements:achievementsToUnlock];
}
+ (BOOL)isAchievementUnlocked:(int)achievementId{
	return [[PNLocalAchievementDB sharedObject] isAchievementUnlocked:achievementId userId:[PNUser currentUserId]];
}

+ (void)achievementNoticeTouched:(id)sender{
	BOOL shouldLaunchDashboard = YES;
	
	if ([[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(shouldLaunchDashboardWithAchievementsView)]){
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"delegate responds to shouldLaunchDashboardWithAchievementsView");
		shouldLaunchDashboard = [[PankiaNet sharedObject].pankiaNetDelegate shouldLaunchDashboardWithAchievementsView];
	}
	
	if (shouldLaunchDashboard) {
		[PankiaNet launchDashboardWithAchievementsView];		
	}
}
/**
 サーバーとアチーブメントを同期した際、新たにアチーブメントがアンロックされた時に呼ばれます
 */
- (void)managerDidDownloadAndUnlockedAchievementsFromServer:(PNManager *)manager{
	if (pankiaNetDelegate != nil && [pankiaNetDelegate respondsToSelector:@selector(achievementsDidUpdate)]){
		[pankiaNetDelegate achievementsDidUpdate];
	}
}

- (void)achievementUnlocked:(NSNotification*)n
{
	PNAchievement* unlockedAchievement = (PNAchievement*)(n.object);

	//そのAchievementに関する文字情報がpListにある場合はローカルでアンロック後
	//すぐにNortificationを出します
	if ([[PNAchievementManager sharedObject] hasDetailsForAchievementId:unlockedAchievement.id]){
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Show nortification soon.");
		[[PNDashboard sharedObject] showAchievementNotice: unlockedAchievement];
	}
	
	if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(unlockAchievementDone:) ]) {
		[[PankiaNet sharedObject].pankiaNetDelegate unlockAchievementDone:unlockedAchievement];
	}	
}

-(void)manager:(PNAchievementManager*)manager didFailUnlockAchievementWithError:(PNError*)error
{
	if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(unlockAchievementFailedWithError:) ]) {
		[[PankiaNet sharedObject].pankiaNetDelegate unlockAchievementFailedWithError:error];
	}	
}
@end
