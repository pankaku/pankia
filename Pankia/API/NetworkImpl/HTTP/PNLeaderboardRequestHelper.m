#import "PNLeaderboardRequestHelper.h"
#import "PNHTTPRequestHelper.h"
#import "Helpers.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNManager.h"
#import "PNLogger+Package.h"
#import "PNHTTPRequestCacheManager.h"
#import "PNAPIHTTPDefinition.h"
#import "PNGlobalManager.h"
#import "PNLeaderboardManager.h"
#import <GameKit/GameKit.h>

@implementation PNLeaderboardRequestHelper

+(void)scoresInLeaderboard:(int)leaderboard
	 period:(NSString*)period
	  among:(NSString*)among
	 offset:(int)offset
	  limit:(int)limit
	reverse:(NSString*)reverse
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:[NSString stringWithFormat:@"%d",leaderboard] forKey:@"leaderboard"];
		[params setObject:period forKey:@"period"];
		
		if (among) {
			[params setObject:among forKey:@"among"];		
		}
		
		if (offset) {
			[params setObject:[NSString stringWithFormat:@"%d",offset] forKey:@"offset"];
		}
		
		if (limit) {
			[params setObject:[NSString stringWithFormat:@"%d",limit] forKey:@"limit"];
		}
		
		if (reverse) {
			[params setObject:reverse forKey:@"reverse"];		
		}
		NSString* requestURL = [PNHTTPRequestHelper createRequestString:kPNHTTPRequestCommandLeaderboardScores parameters:params];
		if (false){ //[[PNHTTPRequestCacheManager sharedObject] hasCacheForURL:requestURL]){
			NSLog(@"HAS CACHE: %@", [[PNHTTPRequestCacheManager sharedObject] cachedValueForURL:requestURL]);
			NSMutableDictionary* response = [NSMutableDictionary dictionary];
			[response setObject:[[PNHTTPRequestCacheManager sharedObject] cachedValueForURL:requestURL] forKey:@"json"];
			[response setObject:key forKey:@"requestKey"];
			[delegate performSelector:selector withObject:response afterDelay:0.0f];
			return;
		}else{
			[[self class] requestWithCommand:kPNHTTPRequestCommandLeaderboardScores
								 requestType:@"GET"
								   isMutable:NO
								  parameters:params
									delegate:delegate
									selector:selector
								 callBackKey:key];	
		}
	}
}

+(void)rankInLeaderboard:(int)leaderboard
	   user:(NSString*)user
	 period:(NSString*)period
	  among:(NSString*)among
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {

	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:session forKey:@"session"];
	[params setObject:[NSString stringWithFormat:@"%d",leaderboard] forKey:@"leaderboards"];
	[params setObject:period forKey:@"period"];
	[params setObject:user forKey:@"user"];
	
	if (among) {
		[params setObject:among forKey:@"among"];		
	}
		
		NSString* requestURL = [PNHTTPRequestHelper createRequestString:kPNHTTPRequestCommandLeaderboardRank parameters:params];
		if ([[PNHTTPRequestCacheManager sharedObject] hasCacheForURL:requestURL]){
			NSLog(@"HAS CACHE: %@", [[PNHTTPRequestCacheManager sharedObject] cachedValueForURL:requestURL]);
			NSMutableDictionary* response = [NSMutableDictionary dictionary];
			[response setObject:[[PNHTTPRequestCacheManager sharedObject] cachedValueForURL:requestURL] forKey:@"json"];
			[response setObject:key forKey:@"requestKey"];
			[delegate performSelector:selector withObject:response afterDelay:0.0f];
			return;
		}else{
			[[self class] requestWithCommand:kPNHTTPRequestCommandLeaderboardRank
								 requestType:@"GET"
								   isMutable:NO
								  parameters:params
									delegate:delegate
									selector:selector
								 callBackKey:key];
		}
	}
}
+(void)rankInLeaderboards:(NSString*)leaderboardIds
	   user:(NSString*)user
	 period:(NSString*)period
	  among:(NSString*)among
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:leaderboardIds forKey:@"leaderboards"];
		[params setObject:period forKey:@"period"];
		[params setObject:user forKey:@"user"];
		
		if (among) {
			[params setObject:among forKey:@"among"];		
		}
		
		[[self class] requestWithCommand:kPNHTTPRequestCommandLeaderboardRank
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];	
	}
}

+(void)postScore:(long long int)score
leaderboard:(int)leaderboard
	  delta:(BOOL)delta
	 period:(NSString*)period
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {

	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:session forKey:@"session"];
	[params setObject:[NSString stringWithFormat:@"%lld",score] forKey:@"scores"];
	[params setObject:[NSString stringWithFormat:@"%d",leaderboard] forKey:@"leaderboard"];
	
	int dedupCounter = [PNUser countUpDedupCounter];
	[params setObject:[NSString stringWithFormat:@"%d",dedupCounter] forKey:@"dedup_counter"];
		
	//	[params setObject:delta ? @"true" : @"false" forKey:@"delta"];

	[params setObject:[[PNUser currentUser] verifierStringWithGameSecret:[PNGlobalManager sharedObject].gameSecret]
			   forKey:@"verifier"];
	
		[[self class] requestWithCommand:delta ? kPNHTTPRequestCommandLeaderboardIncrement :  kPNHTTPRequestCommandLeaderboardPost
						 requestType:@"POST"
						   isMutable:YES
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];
		
		// begin - lerry added code
		if ([[PNManager sharedObject] gameCenterOptionSet] && 
			[[PNManager sharedObject] gameCenterEnabled] && 
			[GKLocalPlayer localPlayer].authenticated) {
			[[PNLeaderboardManager sharedObject] postScoreToGameCenter:score leaderboardId:leaderboard];
		}
		// end - lerry added code
	}	
}


+(void)leaderboardsWithDelegate:(id)delegate
			  selector:(SEL)selector
			requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {

	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:session forKey:@"session"];
		
	[[self class] requestWithCommand:kPNHTTPRequestCommandGameLeaderboads
								  requestType:@"GET"
									isMutable:NO
								   parameters:params 
									 delegate:delegate
									 selector:selector
								  callBackKey:key];
	}
}

+(void)latestScoreOnLeaderboards:(NSArray*)leaderboardIds
						delegate:(id)delegate
						selector:(SEL)selector
					  requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		//リーダーボードidの配列を作ります(NSNumber以外のものを除外します)
		NSMutableArray* idArray = [NSMutableArray array];
		for (id obj in leaderboardIds){
			if ([obj isKindOfClass:[NSNumber class]]) {
				[idArray addObject:obj];
			}
		}
		NSString* idsString = [idArray componentsJoinedByString:@","];
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:idsString forKey:@"leaderboards"];
		
		[[self class] requestWithCommand:kPNHTTPRequestCommandLeaderboardLatests
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params 
								delegate:delegate
								selector:selector
							 callBackKey:key];
	}
}

- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNLog(@"%s %@ %d", __FUNCTION__, error.message, error.errorType);
	[super error:error userInfo:userInfo];
}

@end
