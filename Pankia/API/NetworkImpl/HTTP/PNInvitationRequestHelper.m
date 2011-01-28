#import "PNInvitationRequestHelper.h"
#import "PNHTTPRequestHelper.h"
#import "Helpers.h"
#import "PNLogger+Package.h"
#import "PNAPIHTTPDefinition.h"


@implementation PNInvitationRequestHelper

- (id) init
{
	if(self = [super init]){
		
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

+(void)show:(NSString*)session
	 filter:(NSString*)filter
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:session forKey:@"session"];
	[params setObject:filter forKey:@"filter"];

	[[self class] requestWithCommand:kPNHTTPRequestCommandInvitationShow
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];	
	
}

+(void)post:(NSString*)session
	   room:(NSString*)room
	   user:(NSString*)user
	  group:(NSString*)group
	   text:(NSString*)text
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:session forKey:@"session"];
	[params setObject:room forKey:@"room"];
	if (user) {
		[params setObject:user forKey:@"users"];		
	}
	if (group) {
		[params setObject:group forKey:@"group"];
	}
	[params setObject:text forKey:@"text"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandInvitationPost
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];	
	
}

+(void)deleteInvitation:(NSString*)session
			 invitation:(NSString*)invitation
			   delegate:(id)delegate
			   selector:(SEL)selector
			 requestKey:(NSString*)key
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:session forKey:@"session"];
	[params setObject:invitation forKey:@"invitation"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandInvitationDelete
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];		
	
}

+(void)rooms:(NSString*)session
	delegate:(id)delegate
	selector:(SEL)selector
  requestKey:(NSString*)key
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:session forKey:@"session"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandInvitationRooms
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];	
	
}

/*
+(NSMutableArray*)setInvitationRoomsDataWithJson:(NSDictionary*)jsonData
{
	
	
	NSArray *_roomList = [jsonData objectForKey:@"rooms"];
	int numOfRooms = [_roomList count];
	
	NSMutableArray *_roomArray = [[[NSMutableArray alloc] init] autorelease];
	
	for (int i = 0; i < numOfRooms; i++) {
		//		
	}
	
	return _roomArray;
}
 */

- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNLog(@"%@ %d",error.message,error.errorType);
}

@end
