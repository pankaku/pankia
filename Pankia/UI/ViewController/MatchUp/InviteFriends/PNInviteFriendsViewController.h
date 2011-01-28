//
//  PNInviteFriendsViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNInviteFriendCell.h"
#import "PNInviteFriendActionCell.h"
#import "PNInviteFriendsLoadMoreCell.h"
#import "PankiaNetworkLibrary.h"

@interface PNInviteFriendsViewController : PNTableViewController {
	PNInviteFriendCell*			 myInviteFriendCell;
	PNInviteFriendActionCell*	 myInviteFriendActionCell;
	PNInviteFriendsLoadMoreCell* loadMoreCell;
	
	NSMutableArray*				friends;
	NSMutableArray*				inviteFriends;
	
	BOOL						isCheckAll;
	
	BOOL						isLoadMore;
	NSUInteger                  _rowCount;
	int                         friendsOffset;
}

@property (retain) IBOutlet PNInviteFriendCell*			 myInviteFriendCell;
@property (retain) IBOutlet PNInviteFriendActionCell*	 myInviteFriendActionCell;
@property (retain) IBOutlet PNInviteFriendsLoadMoreCell* loadMoreCell;
@property					BOOL						 isLoadMore;
@property                	NSUInteger                   _rowCount;


- (IBAction)pressedInviteBtn;
- (IBAction)pressedCheckAllBtn;

- (void)addFriend:(int)cellRowIndex;
- (void)removeFriend:(int)cellRowIndex;

- (BOOL)isCheckAll;

@end
