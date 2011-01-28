#import "PNMatchRequestHelper.h"
#import "PNHTTPRequestHelper.h"
#import "Helpers.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNManager.h"
#import "PNAPIHTTPDefinition.h"
#import "PNGlobalManager.h"

@implementation PNMatchRequestHelper

+ (void)start:(NSString*)aSession
		 room:(NSString*)aRoom
	 delegate:(id)aDelegate
	 selector:(SEL)aSelector
   requestKey:(NSString*)aKey
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:aSession forKey:@"session"];
	[params setObject:aRoom forKey:@"room"];
	[params setObject:@"true" forKey:@"lock"];
	[[self class] requestWithCommand:kPNHTTPRequestCommandMatchStart
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:aDelegate
							selector:aSelector
						 callBackKey:aKey];	
}


+ (void)finish:(NSString*)aSession
		  room:(NSString*)aRoomId
		 users:(NSArray*)aUsers
   gradePoints:(NSArray*)aGradePoints
    matchScores:(NSArray*)matchScores
	  delegate:(id)aDelegate
	  selector:(SEL)aSelector
	requestKey:(NSString*)aKey
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:aSession forKey:@"session"];
	
	NSString* _users = [aUsers componentsJoinedByString:@","];
	NSString* _gradePoints = [aGradePoints componentsJoinedByString:@","];
	NSString* _matchScores = @"";
	if (matchScores != nil && [matchScores count] > 0) {
		_matchScores = [matchScores componentsJoinedByString:@","];
	}
	
	[params setObject:aRoomId forKey:@"room"];
	[params setObject:_users forKey:@"users"];
	[params setObject:_matchScores forKey:@"match_scores"];
	[params setObject:_gradePoints forKey:@"grade_points"];
		
	int dedupCounter = [PNUser countUpDedupCounter];
	[params setObject:[NSString stringWithFormat:@"%d",dedupCounter] forKey:@"dedup_counter"];

	[params setObject:[[PNUser currentUser] verifierStringWithGameSecret:[PNGlobalManager sharedObject].gameSecret] 
			   forKey:@"verifier"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandMatchFinish
						 requestType:@"POST"
						   isMutable:NO
						  parameters:params
							delegate:aDelegate
							selector:aSelector
						 callBackKey:aKey];	
}

+ (void)find:(NSString*)aSession
	   users:(NSArray*)aUsers
	delegate:(id)aDelegate
	selector:(SEL)aSelector
  requestKey:(NSString*)aKey
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:aSession forKey:@"session"];
	
	NSMutableString* _users = [NSMutableString string];
	int c = 0;
	for(NSString* u in aUsers) {
		if(c++ < [aUsers count]){
			[_users appendFormat:@"%@,",u];
		} else {
			[_users appendFormat:@"%@",u];
		}
	}
	
	[params setObject:_users forKey:@"users"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandMatchFind
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:aDelegate
							selector:aSelector
						 callBackKey:aKey];	
}

@end
