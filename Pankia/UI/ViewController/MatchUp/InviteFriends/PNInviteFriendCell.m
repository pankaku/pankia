//
//  PNInviteFriendCell.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNInviteFriendCell.h"
#import "PNInviteFriendsViewController.H"


@implementation PNInviteFriendCell

@synthesize delegate,checkBtn,cellRowIndex;

- (void)dealloc {
    [super dealloc];
}

-(IBAction)pressedCheckBtn
{
	[self changeCheckState];
	
}

-(void)checkOn
{
	checkBtn.selected = YES;
}

-(void)checkOff
{
	checkBtn.selected = NO;
}

-(void)changeCheckState
{
	PNInviteFriendsViewController* v;
	if ([delegate isKindOfClass:[PNInviteFriendsViewController class]]) {
		v = delegate;
	} else {
		return;
	}
	
	if (checkBtn.selected || [v isCheckAll]) {
		checkBtn.selected = NO;
		[v removeFriend:self.cellRowIndex];
	}
	else {
		checkBtn.selected = YES;
		[v addFriend:self.cellRowIndex];
	}
}


@end
