//
//  PNJoinedRoomEventCell.h
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PankiaNetworkLibrary.h"
#import "PNTableCell.h"
#import "PNDefaultButton.h"

typedef enum  {
	NOT_READY,
	NOT_JOINED,
	JOINING,
	JOINED
} JoinState;

 
@interface PNJoinedRoomEventCell : PNTableCell {
	IBOutlet PNDefaultButton* joinButton_;
	id delegate;
	JoinState joinState;
}

- (IBAction)joinMatchUpButtonDidPush;
- (void)onOKSelected;

@property (assign) JoinState joinState;
@property (assign) IBOutlet PNDefaultButton* joinButton_;
@property (retain) id delegate;

@end
