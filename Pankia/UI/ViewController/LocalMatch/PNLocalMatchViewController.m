//
//  PNLocalMatchViewController.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNLocalMatchViewController.h"
#import "PNControllerLoader.h"
#import "PNMyLocalRoomViewController.h"
#import "PNDashboard.h"
#import "PankiaNetworkLibrary.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNLocalRoomsViewController.h"
#import "PNCreateLocalRoomViewController.h"

@implementation PNLocalMatchViewController
@synthesize lobby_;

- (void)awakeFromNib {
	[super awakeFromNib];	
	UIBarButtonItem* rightItem =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
												   target:self
												   action:@selector(addButtonDidPush)] autorelease];
	self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	PNRoomManager* roomMan = [PNManager roomManager];
	[roomMan stopFindActiveRooms];
	[PNDashboard hideIndicator];
}

- (void)addButtonDidPush {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"Create Local Room!!!");
	if(kPNSelectionOfTheLocalRoomUse) {
		PNCreateLocalRoomViewController* controller =
		(PNCreateLocalRoomViewController*)[PNControllerLoader load:@"PNCreateLocalRoomViewController"
														filesOwner:nil];
		controller.lobby_ = lobby_;
		[PNDashboard pushViewController:controller];
	}
	else {
		PNMyLocalRoomViewController *controller =
		(PNMyLocalRoomViewController *)[PNControllerLoader load:@"PNMyLocalRoomViewController"
													 filesOwner:self];
		PNUser* user = [PNUser currentUser];
		
		if ([PNUser currentUser].username == nil || [[PNUser currentUser].username isEqualToString:@""]) {
			controller.roomName	= @"Player's Room";
		}
		else {
			controller.roomName	= [NSString stringWithFormat:@"%@'s Room",user.username];
		}
		controller.lobby = lobby_;
		
		[PNDashboard pushViewController:controller];
	}
}

- (void)dealloc {
	[nearbyMatch_ release];
	[dataSource_ release];
	[iconImages_ release];	
    [super dealloc];
}
@end
