//
//  PNJoinedRoomEventCell.h
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewCell.h"
#import "PankiaNetworkLibrary.h"


@interface PNJoinedLocalRoomEventCell : PNTableViewCell {
	IBOutlet UILabel* notHostText_;
}

@property (retain) IBOutlet UILabel* notHostText_;

- (void)showNotHostText;
- (void)hideNotHostText;

@end
