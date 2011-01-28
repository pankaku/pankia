//
//  PNMatchUpViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNHeaderCell.h"
#import "PNLobby.h"

@interface PNMatchUpViewController : PNTableViewController {
	IBOutlet PNHeaderCell*	headerCell_;
	NSArray*				dataSource_;
	PNLobby*				lobby;
}

@property (assign) IBOutlet PNHeaderCell* headerCell_;
@property (retain) PNLobby *lobby;

- (void)onOKSelected;

@end
