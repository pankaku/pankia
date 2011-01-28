//
//  PNRoomsViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNRoomCell.h"
#import "PNTableViewController.h"
#import "PankiaNetworkLibrary.h"
#import "PNRoomsReloadActionCell.h"
#import "PNRoomNoneCell.h"
#import "PNHeaderCell.h"
#import "PNLobby.h"

@interface PNRoomsViewController : PNTableViewController <PNRoomManagerDelegate, PNRoomDelegate> {
	PNLobby*					lobby;
	PNRoomCell*					matchUpRoomCell;
	PNRoomNoneCell*				noneCell;
	PNRoomsReloadActionCell*	reloadCell;
	IBOutlet PNHeaderCell*		headerCell_;
	
	NSMutableArray* activeRooms;
	
	BOOL hasAppeared;
}

- (void)reload;
- (void)setBackgroundImage:(UITableViewCell *)cell;

@property (retain) PNLobby* lobby;
@property (assign) IBOutlet PNRoomCell *matchUpRoomCell;
@property (assign) IBOutlet PNRoomsReloadActionCell* reloadCell;
@property (assign) IBOutlet PNRoomNoneCell* noneCell;
@property (assign) IBOutlet PNHeaderCell* headerCell_;

@end
