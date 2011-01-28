#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNJoinedLocalRoomCell.h"
#import "PNMyLocalRoomActionCell.h"
#import "PankiaNetworkLibrary.h"
#import "PNMyLocalRoomActionCell.h"
#import "PNMyLocalRoomEventCell.h"
 

@class PNLobby;

@interface PNMyLocalRoomViewController : PNTableViewController<PNRoomDelegate, PNRoomManagerDelegate, PNGameSessionDelegate> {
	NSString*		hostName;
	NSString*		roomName;
	NSMutableArray*	joinedUsers;
	
	PNLobby*					lobby;	
	PNRoom*						localRoom;
	PNJoinedLocalRoomCell*		joinedLocalRoomCell;
	PNMyLocalRoomActionCell*	myRoomActionCell;
	PNMyLocalRoomEventCell*		myRoomEventCell_;
	
	BOOL isLeave;
}


@property (assign) IBOutlet PNJoinedLocalRoomCell*		joinedLocalRoomCell;
@property (assign) IBOutlet PNMyLocalRoomActionCell*	myRoomActionCell;
@property (assign) IBOutlet PNMyLocalRoomEventCell*		myRoomEventCell_;
@property (retain) NSString*	hostName;
@property (retain) NSString*	roomName;
@property (retain) PNRoom*		localRoom;
@property (retain) PNLobby*		lobby;

- (void)start;
- (void)leaveLocalRoom;

- (void)onOKSelected;
- (void)onOKSelectedLeave;
- (void)onCancelSelected;

@end
