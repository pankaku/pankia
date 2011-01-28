//
//  PNLocalRoomsViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PankiaNetworkLibrary.h"


@class PNLobby;

@interface PNLocalRoomsViewController : PNTableViewController <PNRoomManagerDelegate> {
	NSMutableArray*		activeRooms;
	PNLobby*			lobby;
}

@property (retain) PNLobby* lobby;
@property (retain) NSMutableArray *activeRooms;

- (void)searchTimeout:(NSNumber *)counter;
- (void)onOKSelected;

@end
