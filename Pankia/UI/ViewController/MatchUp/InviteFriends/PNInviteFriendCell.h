//
//  PNInviteFriendCell.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableCell.h"

/**
 @brief 友人招待画面上で、招待可能なフレンドの情報を表示するCellクラスです。
 PNInviteFriendsViewControllerに所属。
 */
@interface PNInviteFriendCell : PNTableCell {
	IBOutlet UIButton*				checkBtn;
	int								cellRowIndex;
	
	id								delegate;
}

@property (retain) IBOutlet UIButton*	checkBtn;
@property (assign)			int			cellRowIndex;
@property (assign) id					delegate;

-(IBAction)pressedCheckBtn;
-(void)checkOn;

-(void)checkOff;
-(void)changeCheckState;

@end
