//
//  PNInvitedRoomsViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNRoomCell.h"
#import "PankiaNetworkLibrary.h"

@interface PNInvitedRoomsViewController : PNTableViewController {
	PNRoomCell*		matchUpRoomCell;
	NSMutableArray*			invitedRooms;
}

@property (retain) IBOutlet PNRoomCell*	matchUpRoomCell;

@end
