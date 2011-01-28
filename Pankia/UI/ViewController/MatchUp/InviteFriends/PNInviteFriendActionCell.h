//
//  PNInviteFriendActionCell.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNFixedTableCell.h"

/**
 @brief 友人招待画面で、招待ボタンを表示するCellクラスです。
 1段目
 PNInviteFriendsViewControllerに所属。
 */
@interface PNInviteFriendActionCell : PNFixedTableCell {
	IBOutlet UIButton*					inviteBtn;
	IBOutlet UIButton*					checkAllBtn;
	IBOutlet UIButton*					cancelBtn;
	
	id									delegate;
}

@property (retain) IBOutlet UIButton*	inviteBtn;
@property (retain) IBOutlet UIButton*	checkAllBtn;
@property (retain) IBOutlet	UIButton*	cancelBtn;
@property (assign) id					delegate;

- (IBAction)pressedInviteBtn;
- (IBAction)pressedCheckAllBtn;
- (IBAction)pressedCancelBtn;

-(void)checkAllOn;
-(void)checkAllOff;
-(void)changeCheckAllState;
-(void)enableInviteBtn;
-(void)disableInviteBtn;

@end
