//
//  PNLeaderboardsSelectViewController.h
//  PankiaNet
//
//  Created by nakashima on 10/02/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"

@interface PNLeaderboardsSelectViewController : PNTableViewController {
	NSArray*										rankings;
	int												leaderboardId;
	NSString*                                       viewTitle;
}

@property (retain) NSArray*							rankings;
@property (assign) int								leaderboardId;
@property (retain) NSString*                        viewTitle;

- (void)setViewTitle:(NSString *)title;

@end
