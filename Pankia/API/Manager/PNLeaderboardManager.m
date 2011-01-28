// Frameworks
#import <GameKit/GameKit.h>

// Managers
#import "PNGameManager.h"
#import "PNLeaderboardManager.h"
#import "PNManager.h"
#import "PNSettingManager.h"

// Helper
#import "PNHTTPRequestHelper.h"

// Logger
#import "PNLogger+Package.h"

// Models
#import "PNLeaderboard.h"
#import "PNLeaderboardModel.h"
#import "PNRank.h"
#import "PNRank+Package.h"
#import "PNRankModel.h"
#import "PNScoreModel.h"
#import "PNUser.h"
#import "PNUser+Package.h"


#define kPNLeaderboardsLimit					10
#define kPNCachedataPostdataList				@"CACHED_POSTDATA"
#define kPNHTTPCacheLeaderboardRankLifeSpan		30
#define kPNHTTPCacheLeaderboardScoreLifeSpan	30
#define kPNLeaderboardRanksAmongFriends			@"friends"

static PNLeaderboardManager* _sharedInstance;

@interface PNLeaderboardManager(Private)
- (void)loadGameCenterLeaderBoards;
@end

@implementation PNLeaderboardManager
@synthesize leaderboardsFromPlist, gameCenterLeaderBoards;

- (void)loadLeaderboardsFromPlist {
	NSMutableArray *leaderboards = [NSMutableArray array];
	
	NSArray* leaderboardDictionaries = [[[PNSettingManager sharedObject] offlineSettings] objectForKey:@"leaderboards"];
	for (NSDictionary* dictionary in leaderboardDictionaries) {
		PNLeaderboard* leaderboard = [[[PNLeaderboard alloc] initWithLocalDictionary:dictionary] autorelease];
		if (leaderboard != nil) {
			[leaderboards addObject:leaderboard];
		}
	}
	self.leaderboardsFromPlist = leaderboards;
}

+ (PNLeaderboard*)leaderboardById:(int)leaderboardId {
	for (PNLeaderboard* leaderboard in [[PNGameManager sharedObject] leaderboards]) {
		if (leaderboard.leaderboardId == leaderboardId) return leaderboard;
	}
	return nil;
}

#pragma mark -

- (void)getScoresOnLeaderboard:(int)leaderboardId among:(NSString*)among period:(NSString*)period offset:(int)offset
					 onSuccess:(void (^)(NSArray *)) onSuccess onFailure:(void (^)(PNError *))onFailure
{
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:[NSString stringWithFormat:@"%d",leaderboardId] forKey:@"leaderboard"];
	[params setObject:period forKey:@"period"];
	if (among) [params setObject:among forKey:@"among"];		
	if (offset) [params setObject:[NSString stringWithFormat:@"%d",offset] forKey:@"offset"];
	[params setObject:[NSString stringWithFormat:@"%d",kPNLeaderboardsLimit] forKey:@"limit"];	
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandLeaderboardScores params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			NSArray* scoreModels = [PNScoreModel dataModelsFromArray:[response.jsonDictionary objectForKey:@"scores"]];
			NSMutableArray* scores = [NSMutableArray array];
			for (PNScoreModel* scoreModel in scoreModels) {
				[scores addObject:[[[PNRank alloc] initWithScoreModel:scoreModel] autorelease]];
			}
			onSuccess(scores);
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}

	} onFailure:onFailure];
}

/**
 @brief Retrives latest score of current user on specified leaderboards.
 */
- (void)getLatestScoreOnLeaderboards:(NSArray*)leaderboardIds
						   onSuccess:(void (^)(NSArray *scores)) onSuccess onFailure:(void (^)(PNError *error))onFailure
{
	// create param string for leaderboard id array
	NSMutableArray* idArray = [NSMutableArray array];
	for (id obj in leaderboardIds){
		if ([obj isKindOfClass:[NSNumber class]]) {
			[idArray addObject:obj];
		}
	}
	NSString* idsString = [idArray componentsJoinedByString:@","];
	
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[PNUser currentUser].sessionId, @"session",
							idsString, @"leaderboards", nil];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandLeaderboardLatests params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			NSArray* rawScoresArray = [response.jsonDictionary objectForKey:@"latests"];
			NSMutableArray *scores = [NSMutableArray array];
			for (NSDictionary* rawScore in rawScoresArray){
				PNRank* rank = [[[PNRank alloc] init] autorelease];
				if (![[rawScore objectForKey:@"value"] isKindOfClass:[NSNull class]]) {
					rank.score = [[rawScore objectForKey:@"value"] longLongValue];
					rank.leaderboardId = [[rawScore objectForKey:@"leaderboard_id"] intValue];
					[scores addObject:rank];
				} else {
					PNWarn(@"Warning. NSNull class found in score array. (getLatestScoreOnLeaderboards)");
				}
			}
			onSuccess(scores);
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
- (void)getRankOnLeaderboard:(int)leaderboardId username:(NSString *)username period:(NSString *)period among:(PNLeaderboardRankAmongType)among
				   onSuccess:(void (^)(PNRank *rank)) onSuccess onFailure:(void (^)(PNError *error))onFailure
{
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:[NSString stringWithFormat:@"%d",leaderboardId] forKey:@"leaderboards"];
	[params setObject:period forKey:@"period"];
	[params setObject:username forKey:@"user"];
	if (among == PNLeaderboardRankAmongFriends) [params setObject:kPNLeaderboardRanksAmongFriends forKey:@"among"];	
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandLeaderboardRank params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			PNRankModel* rankModel = [PNRankModel dataModelWithDictionary:[[response.jsonDictionary objectForKey:@"ranks"] objectAtIndex:0]];
			PNRank* rank = [[[PNRank alloc] initWithRankModel:rankModel] autorelease];
			onSuccess(rank);
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
- (void)getRankOnLeaderboards:(NSArray*)leaderboardIdArray username:(NSString *)username period:(NSString *)period among:(PNLeaderboardRankAmongType)among
				   onSuccess:(void (^)(NSArray *ranks)) onSuccess onFailure:(void (^)(PNError *error))onFailure
{
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:[leaderboardIdArray componentsJoinedByString:@","] forKey:@"leaderboards"];
	[params setObject:period forKey:@"period"];
	[params setObject:username forKey:@"user"];
	if (among == PNLeaderboardRankAmongFriends) [params setObject:kPNLeaderboardRanksAmongFriends forKey:@"among"];	
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandLeaderboardRank params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			 NSArray* rankModels = [PNRankModel dataModelsFromArray:[response.jsonDictionary objectForKey:@"ranks"]];
			 NSMutableArray* ranks = [NSMutableArray array];
			 for (PNRankModel* rankModel in rankModels) {
				 PNRank* rank = [[[PNRank alloc] initWithRankModel:rankModel] autorelease];
				 [ranks addObject:rank];
			 }
			onSuccess(ranks);
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
#pragma mark GameCenter 

- (void)loadGameCenterLeaderBoards {
	if (self.gameCenterLeaderBoards == nil) {
		NSString* errorDesc = nil;
		NSPropertyListFormat format;
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"PNGameCenter" ofType:@"plist"];
		NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
		NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization
													propertyListFromData:plistXML
													mutabilityOption:NSPropertyListMutableContainersAndLeaves
													format:&format
													errorDescription:&errorDesc];
		[self setGameCenterLeaderBoards:[dictionary objectForKey:@"LeaderBoard"]];
		PNCLog(PNLOG_CAT_LEADERBOARDS, @"GameCenterLeaderBoards loaded from plist");
	}
}
- (void)postScoreToGameCenter:(int64_t)score leaderboardId:(int)leaderboardId {
	PNLogMethodName;
	NSString* key = [NSString stringWithFormat:@"%d", leaderboardId];
	NSString* category = [[self gameCenterLeaderBoards] objectForKey:key];
	if (category == nil) {
		PNCLog(PNLOG_CAT_LEADERBOARDS, @"LeaderBoard ID=%d does not exist.", leaderboardId);
		return;
	}
	if ([GKLocalPlayer localPlayer].authenticated) {
		GKScore* scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
		scoreReporter.value = score;
		[scoreReporter reportScoreWithCompletionHandler:^(NSError* error) {
			if (error != nil) {
				// resend process
				PNCLog(PNLOG_CAT_LEADERBOARDS, @"Error occured when posting score to game center: %@", error);
			} else {
				PNCLog(PNLOG_CAT_LEADERBOARDS, @"Score posted to Game Center");
			}

		}];
	}
}



#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	PNLogMethodName;
	if (self = [super init]){	
		[self loadLeaderboardsFromPlist];
		// begin - lerry added code
		[self loadGameCenterLeaderBoards];
		// end - lerry added code
	}
	return self;
}

- (void) dealloc{
	[[self gameCenterLeaderBoards] release];
	self.gameCenterLeaderBoards = nil;
	[super dealloc];
}

+ (PNLeaderboardManager *)sharedObject {
	PNLogMethodName;
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	PNLogMethodName;
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone {
	PNLogMethodName;
	return self;
}

- (id)retain {
	PNLogMethodName;
	return self;
}

- (unsigned)retainCount {
	PNLogMethodName;
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release {
	PNLogMethodName;
	// 何もしない
}

- (id)autorelease {
	PNLogMethodName;
	return self;
}

@end
