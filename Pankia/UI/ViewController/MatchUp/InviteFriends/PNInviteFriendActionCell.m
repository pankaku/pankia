//
//  PNInviteFriendActionCell.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNInviteFriendActionCell.h"


@implementation PNInviteFriendActionCell

@synthesize delegate, inviteBtn, checkAllBtn, cancelBtn;

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)dealloc {
	self.inviteBtn			= nil;
	self.checkAllBtn		= nil;
	self.cancelBtn			= nil;
	self.delegate			= nil;
    [super dealloc];
}

- (void)pressedInviteBtn
{
	PNLog(@"pressed invite btn");
	if ([delegate respondsToSelector:@selector(pressedInviteBtn)]) {
		[self disableInviteBtn];
		[delegate pressedInviteBtn];
	}
}

- (void)pressedCheckAllBtn
{
	PNLog(@"pressed check all btn");
	[self changeCheckAllState];
	if ([delegate respondsToSelector:@selector(pressedCheckAllBtn)])
		[delegate pressedCheckAllBtn];
}

- (void)pressedCancelBtn
{
	PNLog(@"pressed cancel btn");
	if ([delegate respondsToSelector:@selector(pressedCancelBtn)])
		[delegate pressedCancelBtn];
}

-(void)enableInviteBtn
{
	inviteBtn.enabled = YES;
}

-(void)disableInviteBtn
{
	inviteBtn.enabled = NO;
}

-(void)checkAllOn
{
	checkAllBtn.selected = YES;
}

-(void)checkAllOff
{
	checkAllBtn.selected = NO;
}

-(void)changeCheckAllState
{
	if (checkAllBtn.selected) {
		checkAllBtn.selected = NO;
	}
	else {
		checkAllBtn.selected = YES;
	}	
}


@end
