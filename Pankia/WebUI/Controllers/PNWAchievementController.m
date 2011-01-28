//
//  PNWAchievementController.m
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWAchievementController.h"
#import "PNAchievementRequestHelper.h"
#import "PNJSONCacheManager.h"
#import "PNNativeRequest.h"
#import "PNAchievementManager.h"

@implementation PNWAchievementController

- (void)unlocks
{
	if ([request.params objectForKey:@"user"] == nil && [request.params objectForKey:@"game"] == nil) {
		NSArray* unlockedAchievements = [[PNAchievementManager sharedObject] unlockedAchievements];
		NSMutableArray* achievementIdArray = [NSMutableArray array];
		for (PNAchievement* achievement in unlockedAchievements) {
			[achievementIdArray addObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:achievement.id] forKey:@"id"]];
		}
		[request setAsOKWithObject:achievementIdArray forKey:@"unlocks"];
	} else {
		// TODO: 他のユーザ／ゲームにおけるアンロック情報の取得
		[self asyncRequest:kPNHTTPRequestCommandAchievementUnlocks];
	}
}
@end
