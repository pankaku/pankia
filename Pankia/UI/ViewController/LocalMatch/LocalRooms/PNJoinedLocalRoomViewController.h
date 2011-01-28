#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNJoinedLocalRoomCell.h"
#import "PNJoinedLocalRoomEventCell.h"
#import "PankiaNetworkLibrary.h"

@interface PNJoinedLocalRoomViewController : PNTableViewController<PNRoomDelegate, PNRoomManagerDelegate, PNGameSessionDelegate> {

	PNJoinedLocalRoomEventCell*	joinedLocalRoomEventCell_;
	PNJoinedLocalRoomCell*		joinedLocalRoomCell;
	PNRoom*						localRoom;
	
	NSMutableArray*			joinedUsers;
	UIBarButtonItem*		backButton;
	
	BOOL	isFlag_;
}

@property (assign) IBOutlet PNJoinedLocalRoomEventCell*	joinedLocalRoomEventCell_;
@property (assign) IBOutlet PNJoinedLocalRoomCell*		joinedLocalRoomCell;
@property (retain) PNRoom*			localRoom;
@property (retain) NSMutableArray*	joinedUsers;
@property (retain) UIBarButtonItem* backButton;

- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)onOKSelected;
- (void)onCancelSelected;

@end
