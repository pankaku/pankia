#import "PNInvitationManager.h"
#import "PNInvitationManagerDelegate.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNInvitationRequestHelper.h"
#import "JsonHelper.h"
#import "PNRoomModel.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNManager.h"
#import "PNRoomManager.h"
#import "PNLogger+Package.h"

@implementation PNInvitationManager

- (void)showInvitationList {
	
}

- (void)postInvitationForAllUsersWithDelegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector {
	NSString* session = [PNUser session];
	
	delegate = aDelegate;
	succeedSelector = onSucceededSelector;
	failedSelector = onFailedSelector;
	
	PNRoomManager* roomManager = [PNManager sharedObject].roomManager;
	if (roomManager.currentRoom) {		
		[PNInvitationRequestHelper post:session 
								   room:roomManager.currentRoom.roomId
								   user:nil 
								  group:@"all_followees"
								   text:[NSString stringWithFormat:@"%@ invite you!",[PNUser currentUser].username] 
							   delegate:self 
							   selector:@selector(postInvitationForAllUsersResponse:)
							 requestKey:@"inviteUser"];
	}
	
}

-(void)postInvitationForAllUsersResponse:(PNHTTPResponse*)response {
	NSDictionary*	json = [response jsonDictionary];
	NSString*		key = [response requestKey];

	PNLog(@"invitateResponse response!!! %@",json);
	
	if(response.isValidAndSuccessful) {
		PNLog(@"session = %@",[json description]);
		if ([delegate respondsToSelector:succeedSelector]){
			[delegate performSelector:succeedSelector withObject:key];
		}
		
	} else {
		PNError *error = [PNError errorWithType:kPNRoomErrorFailedInvitation message:@"It was not possible to invite it."];
		if ([delegate respondsToSelector:failedSelector]){
			[delegate performSelector:failedSelector withObjects:[NSArray arrayWithObjects:error, key, nil]];
		}
	}
	
}

- (void)postInvitationForUsers:(NSMutableArray*)userArray delegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector
{
	
	delegate = aDelegate;
	succeedSelector = onSucceededSelector;
	failedSelector = onFailedSelector;
	
	PNRoomManager* roomManager = [PNManager sharedObject].roomManager;
	if (roomManager.currentRoom && [userArray count] > 0) {		
		
		NSString* session = [PNUser session];
		NSString* userString = @"";
		int userCount = [userArray count];
		for(int i = 0; i < userCount; i++){
			userString = [userString stringByAppendingString:[userArray objectAtIndex:i]];
			if (i != userCount-1) {
				userString = [userString stringByAppendingString:@","];
			}
		}
		
		[PNInvitationRequestHelper post:session 
								   room:roomManager.currentRoom.roomId
								   user:userString 
								  group:nil
								   text:[NSString stringWithFormat:@"%@ invite you!",[PNUser currentUser].username] 
							   delegate:self
							   selector:@selector(postInvitationForUsersResponse:)
							 requestKey:@"inviteUser"];
	}
	else {
		PNError *error = [PNError errorWithType:kPNRoomErrorFailedInvitation message:@"It was not possible to invite it."];
		if ([delegate respondsToSelector:failedSelector]){
			[delegate performSelector:failedSelector withObjects:[NSArray arrayWithObjects:error, @"postInvitationForUsers", nil]];
		}		
	}

}

-(void)postInvitationForUsersResponse:(PNHTTPResponse*)response 
{
	NSDictionary*	json = [response jsonDictionary];
	NSString*		key = [response requestKey];
	
	PNLog(@"invitateResponse response!!! %@",json);
	
	if(response.isValidAndSuccessful) {
		PNLog(@"session = %@",[json description]);
		if ([delegate respondsToSelector:succeedSelector]){
			[delegate performSelector:succeedSelector withObject:key];
		}
	} else {
		PNError *error = [PNError errorWithType:kPNRoomErrorFailedInvitation message:@"It was not possible to invite it."];
		if ([delegate respondsToSelector:failedSelector]){
			[delegate performSelector:failedSelector withObjects:[NSArray arrayWithObjects:error, key, nil]];
		}
	}
	
}


- (void)deleteInvitation {
	
}


- (void)findInvitedRoomsWithDelegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector {
	
	delegate = aDelegate;
	succeedSelector = onSucceededSelector;
	failedSelector = onFailedSelector;
	
	NSString* session = [PNUser session];
	[PNInvitationRequestHelper rooms:session
							delegate:self
							selector:@selector(findInvitedRoomsResponse:)
						  requestKey:@"PNRoomInvitedRooms"];

}


-(void)findInvitedRoomsResponse:(PNHTTPResponse*)response
{
	NSDictionary*	json = [response jsonDictionary];
	NSString*		key = [response requestKey];
	NSString*		resp = [response jsonString];
	
	PNLog(@"json = %@", json);
	
	if(response.isValidAndSuccessful) {
		NSMutableArray* invitedRooms = [NSMutableArray array];
		NSArray *roomsDic = [json objectForKey:@"rooms"];
		for(NSDictionary *roomDic in roomsDic) {
			PNRoomModel* roomModel	= [PNRoomModel dataModelWithDictionary:roomDic];
			PNRoom* room			= [[[PNRoom alloc] init] autorelease];
			[room setRoomModel:roomModel];
			room.lobby = [[[PNLobby alloc] init] autorelease];
			room.lobby.lobbyId = roomModel.lobby_id;
			[invitedRooms addObject:room];
		}
		if ([delegate respondsToSelector:succeedSelector]) {
			[delegate performSelector:succeedSelector withObject:key];
		}

	} else {
		// 失敗
		PNError* error = [PNError errorFromResponse:resp];
		if ([delegate respondsToSelector:failedSelector]){
			[delegate performSelector:failedSelector withObjects:[NSArray arrayWithObjects:error, key, nil]];
		}
	}
	
}


@end
