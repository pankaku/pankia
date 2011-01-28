//
//  PNQuickMatchmaker.h
//  no_dashboard
//
//  Created by sota2 on 10/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNError;
@class PNRoom;

typedef enum {
	PNQuickMatchStateNone,
	PNQuickMatchStateFindingRooms,
	PNQuickMatchStateFindingRoomsDone,
	PNQuickMatchStateCreatingRoom,
	PNQuickMatchStateCreatingRoomDone,
	PNQuickMatchStateWaitingForOtherPlayers,
	PNQuickMatchStateCancelling,
	PNQuickMatchStateFailed
} PNQuickMatchState;

@protocol PNQuickMatchmakerDelegate
- (void)quickMatchStateChanged:(PNQuickMatchState)state;
- (void)quickMatchDidFailWithError:(PNError*)error;
@end


/**!
 * @brief インターネットマッチにおけるQuickMatchをサポートするクラスです
 */
@interface PNQuickMatchmaker : NSObject {
	int newRoomMemberCount;
	int lobbyId;
	id<NSObject, PNQuickMatchmakerDelegate> delegate;
	PNQuickMatchState currentState;
	BOOL cancelFlag;
	PNRoom* currentRoom;
}
@property (assign) int newRoomMemberCount;
@property (assign) int lobbyId;
@property (nonatomic, assign) id<NSObject, PNQuickMatchmakerDelegate> delegate;
@property (assign) PNQuickMatchState currentState;
@property (readonly) PNRoom* room;
+ (PNQuickMatchmaker*)quickMatchmaker;
- (void)start;
- (void)cancel;
@end
