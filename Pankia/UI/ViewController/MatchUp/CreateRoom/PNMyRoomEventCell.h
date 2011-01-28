//
//  PNMyRoomEventCell.h
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PankiaNetworkLibrary.h"
//#import "PNTableViewCell.h"
#import "PNTableCell.h"


@interface PNMyRoomEventCell : /*PNTableViewCell*/PNTableCell {
	id delegate;
	IBOutlet UIButton* inviteButton_;
}

- (IBAction)inviteButtonDidPush;

@property (retain) id delegate;
@property (assign) IBOutlet UIButton* inviteButton_;

@end
