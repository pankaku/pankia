//
//  PNMyRoomViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNJoinedRoomCell.h"
#import "PNMyRoomEventCell.h"
#import "PNHeaderCell.h"
#import "PankiaNetworkLibrary.h"
 
#import "PNLobby.h"

@interface PNMyRoomViewController : PNTableViewController<PNRoomDelegate, PNRoomManagerDelegate, PNGameSessionDelegate> {
	IBOutlet PNMyRoomEventCell*			myRoomEventCell_;
	IBOutlet PNHeaderCell*				headerCell_;
	IBOutlet PNJoinedRoomCell*			joinedRoomCell;
	
	PNLobby*				lobby;	
	PNRoom*					myRoom;
	
	NSMutableArray*			joinedUsers;
	NSMutableDictionary*	speedLevels;
	NSString*				hostName;
	NSString*				roomName;
	NSString*				gradeFilter;
	UIButton*				leaveButton_;
	
	int						maxMemberNum;
	BOOL					isPublish;
	BOOL					isCreateRoom;
	BOOL					showedAlert;
	BOOL					enableInvite;
}

@property (retain) IBOutlet PNMyRoomEventCell*		myRoomEventCell_;
@property (assign) IBOutlet PNHeaderCell*			headerCell_;
@property (retain) IBOutlet	PNJoinedRoomCell*		joinedRoomCell;
@property (retain) UIButton*						leaveButton_;

@property (retain) PNLobby*							lobby;
@property (retain) PNRoom*							myRoom;

@property (retain) NSMutableArray*					joinedUsers;
@property (retain) NSMutableDictionary*				speedLevels;
@property (retain) NSString*						hostName;
@property (retain) NSString*						roomName;
@property (retain) NSString*						gradeFilter;

@property (assign) int								maxMemberNum;
@property (assign) BOOL								isPublish;
@property (assign) BOOL								isCreateRoom;


- (void)start;
- (void)leaveRoom;
- (void)invite;
- (void)resetRoomData;
- (void)didCreateRoom:(PNRoom*)room requestId:(int)requestId;

- (void)onOKSelectedBack;
- (void)onCancelSelectedBack;
- (void)hideLeaveButton;
- (UIButton*)setLeaveButton:(const UITableViewCell*)cell;

@end
