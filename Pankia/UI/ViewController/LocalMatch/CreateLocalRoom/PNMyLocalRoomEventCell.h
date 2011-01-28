//
//  PNMyLocalRoomEventCell.h
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableCell.h"
#import "PNDefaultButton.h"
#import "PankiaNetworkLibrary.h"


@interface PNMyLocalRoomEventCell : PNTableCell {
	id delegate;
	IBOutlet PNDefaultButton* startLocalMatchButton_;
}

@property (retain) IBOutlet PNDefaultButton* startLocalMatchButton_;
@property (retain) id delegate;

- (IBAction)startLocalMatchButtonDidPush;
- (void)enableStartLocalMatchButton;
- (void)disableStartLocalMatchButton;

@end
