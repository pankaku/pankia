//
//  PNQuickMatchmaker.m
//  no_dashboard
//
//  Created by sota2 on 10/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNQuickMatchmaker.h"

#import "PNInternetMatchManager.h"
#import "PNError.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNUDPConnectionService.h"
#import "PNPeer.h"

@interface PNQuickMatchmaker ()
@property (nonatomic, retain) PNRoom* currentRoom;
- (void)cancelImmediately;
- (void)leaveTheRoomAndCancel;
- (void)onFailed:(PNError *)error;
@end

@implementation PNQuickMatchmaker
@synthesize newRoomMemberCount, lobbyId, delegate, currentState, currentRoom;
- (id)init
{
	if (self = [super init]) {
		lobbyId = 0;
		newRoomMemberCount = 4;
		cancelFlag = NO;
	}
	return self;
}
+ (PNQuickMatchmaker*)quickMatchmaker
{
	id anInstance = [[[PNQuickMatchmaker alloc] init] autorelease];
	return anInstance;
}
- (void)dealloc
{
	self.currentRoom = nil;
	[super dealloc];
}
#pragma mark -
- (void)setCurrentState:(PNQuickMatchState)state
{
	currentState = state;
	if ([delegate respondsToSelector:@selector(quickMatchStateChanged:)]) {
		[delegate quickMatchStateChanged:state];
	}
}
- (PNRoom*)room
{
	return self.currentRoom;
}
#pragma mark -
- (void)start
{
	// まずはルーム一覧を取得しにいきます
	self.currentState = PNQuickMatchStateFindingRooms;
	[[PNInternetMatchManager sharedObject] findRooms:10 inLobby:lobbyId delegate:self
										 onSucceeded:@selector(findRoomsSucceeded:) onFailed:@selector(onFailed:)];
}
- (void)findRoomsSucceeded:(NSArray*)rooms
{
	self.currentState = PNQuickMatchStateFindingRoomsDone;
	
	if ([rooms count] == 0) {	// ルームがなければ、新しく部屋を作ります。
		self.currentState = PNQuickMatchStateCreatingRoom;
		[[PNInternetMatchManager sharedObject] createAnInternetRoomWithMaxMemberNum:newRoomMemberCount isPublic:YES 
																		   roomName:[NSString stringWithFormat:@"%@'s room", [PNUser currentUser].username]
																		 gradeRange:nil lobbyId:lobbyId delegate:self 
																		onSucceeded:@selector(createRoomDone:) 
																		   onFailed:@selector(onFailed:)];
		return;
	}

}
- (void)createRoomDone:(PNRoom*)room
{
	self.currentRoom = room;
	self.currentState = PNQuickMatchStateCreatingRoomDone;

	// 部屋の作成中にキャンセルが送られてきた場合は、退室してQuickMatchをキャンセルします。
	if (cancelFlag == YES) {
		[self leaveTheRoomAndCancel];
	}
	
	self.currentState = PNQuickMatchStateWaitingForOtherPlayers;
}
#pragma mark -
- (void)cancel
{
	cancelFlag = YES;
	
	switch (currentState) {
		case PNQuickMatchStateNone:
		case PNQuickMatchStateFindingRooms:
		case PNQuickMatchStateFindingRoomsDone:
			[self cancelImmediately];
			break;
		case PNQuickMatchStateCreatingRoomDone:
		case PNQuickMatchStateWaitingForOtherPlayers:
			[self leaveTheRoomAndCancel];
			break;
		default:
			// 部屋の作成中等、即座にキャンセルできない処理の途中であれば、
			// 処理が完了するのを待ってからキャンセルします。
			break;
	}
}
- (void)cancelImmediately
{
	PNError* error = [[[PNError alloc] init] autorelease];
	error.errorCode = @"cancelled.";
	error.message = @"cancelled.";
	[self onFailed:error];
}
- (void)leaveTheRoomAndCancel
{
	[[PNInternetMatchManager sharedObject] leaveInternetRoom:currentRoom delegate:self onSucceeded:@selector(leaveDone)
													onFailed:@selector(onFailed:)];
}
- (void)leaveDone
{
	self.currentRoom = nil;
	[self cancelImmediately];
}
#pragma mark -
- (void)onFailed:(PNError*)error
{
	self.currentState = PNQuickMatchStateFailed;
	if ([delegate respondsToSelector:@selector(quickMatchDidFailWithError:)]) {
		[delegate quickMatchDidFailWithError:error];
	}
}
@end
