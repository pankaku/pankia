#import "PNRoomRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNGradeModel.h"
#import "PNAPIHTTPDefinition.h"

@implementation PNRoomRequestHelper

+(void) remove:(NSString*)aSession
		  room:(NSString*)aRoom
		  user:(NSString*)aUser
	  delegate:(id)delegate
	  selector:(SEL)selector
	requestKey:(NSString*)key
{
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomRemove
						 requestType:@"GET"
						   isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  aSession,		@"session",
									  aRoom,		@"room",
									  aUser,		@"user",
									  nil]
							delegate:delegate
							selector:selector
						 callBackKey:key];
}

+(void) leave:(NSString*)session
		 room:(NSString*)room
	 delegate:(id)delegate
	 selector:(SEL)selector
   requestKey:(NSString*)key
{
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomLeave
						 requestType:@"GET"
						   isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  session,		@"session",
									  room,			@"room",
									  nil]
							delegate:delegate
							selector:selector
						 callBackKey:key];
}

+(void) find:(NSString*)session
			 except:(NSString*)except
			  limit:(int)limit
			gradeId:(int)gradeId
	 lobbyId:(int)lobbyId
		   delegate:(id)delegate
		   selector:(SEL)selector
		 requestKey:(NSString*)requestKey
{ 	

	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:session								forKey:@"session"];
	
	if (gradeId > 0) {
		[params setObject:[NSNumber numberWithInt:gradeId]	forKey:@"grade_id"];		
	}
	
	if (limit > 0) {
		[params setObject:[NSNumber numberWithInt:limit]	forKey:@"limit"];		
	}
	if (lobbyId > 0) {
		[params setObject:[NSNumber numberWithInt:lobbyId] forKey:@"lobby_id"];
	}
	
	if (except) {
		[params setObject:except	forKey:@"except"];
	}
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomFind
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:requestKey];
}

+(void) findLobbiesWithDelegate:(id)delegate
					   selector:(SEL)selector
					 requestKey:(NSString*)key
{
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandGameLobbies
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];
}

+(void) show_room:(NSString*)session
			roomId:(NSString*)roomId
		  delegate:delegate
		  selector:(SEL)selector
		requestKey:requestKey
{
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:session forKey:@"session"];
	[params setObject:roomId forKey:@"room"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomShow
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:requestKey];
}

+(void)create:(NSString*)session
  publishFlag:(BOOL)publishFlag
   maxMembers:(int)maxMembers
		 name:(NSString*)name
   gradeRange:(NSString*)gradeRange
	  lobbyId:(int)lobbyId
	 delegate:(id)delegate
	 selector:(SEL)selector
   requestKey:(NSString*)requestKey
{
	NSString* _publishFlag			= publishFlag? @"true" : @"false";
	NSNumber *_maxMembers			= [NSNumber numberWithInt:maxMembers];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:session				forKey:@"session"];
	[params setObject:_publishFlag			forKey:@"is_public"];
	[params setObject:_maxMembers			forKey:@"max_members"];
	[params setObject:name					forKey:@"name"];
	if (lobbyId > 0){
		[params setObject:[NSNumber numberWithInt:lobbyId] forKey:@"lobby_id"];
	}
	if (gradeRange != nil && ![gradeRange isEqualToString:kPNGradeAll]) {
		[params setObject:gradeRange		forKey:@"grade_range"];
	}
			
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomCreate
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:requestKey];
}


+(void) members:(NSString*)session
		   room:(NSString*)room
	   delegate:(id)delegate
	   selector:(SEL)selector
	 requestKey:(NSString*)key
{
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomMembers
						 requestType:@"GET"
						   isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  session,		@"session",
									  room,			@"room",
									  nil]
							delegate:delegate
							selector:selector
						 callBackKey:key];
	
}

+(void) join:(NSString*)session
		room:(NSString*)room
	delegate:(id)delegate
	selector:(SEL)selector
  requestKey:(NSString*)key
{
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomJoin
						 requestType:@"GET"
						   isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  session,		@"session",
									  room,			@"room",
									  nil]
							delegate:delegate
							selector:selector
						 callBackKey:key];
	
}


+(void) unlock:(NSString*)aSession
		  room:(NSString*)aRoom
	  delegate:(id)delegate
	  selector:(SEL)selector
	requestKey:(NSString*)key
{
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomUnlock
						 requestType:@"GET"
						   isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  aSession,		@"session",
									  aRoom,		@"room",
									  nil]
							delegate:delegate
							selector:selector
						 callBackKey:key];
}

+(void) lock:(NSString*)aSession
		room:(NSString*)aRoom
	delegate:(id)delegate
	selector:(SEL)selector
  requestKey:(NSString*)key
{
	[[self class] requestWithCommand:kPNHTTPRequestCommandRoomLock
						 requestType:@"GET"
						   isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  aSession,		@"session",
									  aRoom,		@"room",
									  nil]
							delegate:delegate
							selector:selector
						 callBackKey:key];
}




@end

