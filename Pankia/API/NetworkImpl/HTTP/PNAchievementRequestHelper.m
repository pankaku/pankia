#import "PNAchievementRequestHelper.h"
#import "PNGame.h"
#import "Helpers.h"
#import "PNSettingManager.h"
#import "PNInstallModel.h"
#import "PNAchievementModel.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNVerifyUtil.h"
#import "PNManager.h"
#import "PNAPIHTTPDefinition.h"
#import "PNGlobalManager.h"
@implementation PNAchievementRequestHelper

+ (void)getAchievementsWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString *)key{
	PNHTTPRequestParams *params = [PNHTTPRequestParams params:[PNUser currentUser].sessionId];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandGameAchievement
						 requestType:@"GET"
						   isMutable:NO
					      parameters:[params dictionary]
							delegate:delegate
							selector:selector
						 callBackKey:key];
}

+ (void)unlockAchievements:(NSArray *)achievements delegate:(id)delegate selector:(SEL)selector requestKey:(NSString *)key{
	PNHTTPRequestParams *params = [PNHTTPRequestParams params:[PNUser currentUser].sessionId];
	
	//重複をチェックして、同じものがあれば削除します。また、ID昇順で並び替えます。
	NSMutableArray* achievementIds = [NSMutableArray array];
	for (NSNumber* n in [achievements sortedArrayUsingSelector:@selector(compare:)]){
		if (![achievementIds containsObject:n]){
			[achievementIds addObject:n];
		}
	}
	
	NSMutableArray* achievementIdStrings = [NSMutableArray array];	
	for (NSNumber* n in achievementIds) {
		[achievementIdStrings addObject:[NSString stringWithFormat:@"%d", [n intValue]]];
	}
	
	[params setObject:[achievementIdStrings componentsJoinedByString:@","] forKey:@"achievements"];
	
	int dedupCounter = [PNUser countUpDedupCounter];
	[params setObject:[NSString stringWithFormat:@"%d",dedupCounter] forKey:@"dedup_counter"];
	[params setObject:[[PNUser currentUser] verifierStringWithGameSecret:[PNGlobalManager sharedObject].gameSecret]
			   forKey:@"verifier"];
	
	
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandAchievementUnlock
						 requestType:@"POST"
						   isMutable:YES
						  parameters:[params dictionary]
							delegate:delegate
							selector:selector
						 callBackKey:key];		
}

@end
