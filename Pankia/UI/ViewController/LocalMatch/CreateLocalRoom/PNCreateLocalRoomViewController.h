//
//  PNCreateLocalRoomViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"

@class PNLobby;

@interface PNCreateLocalRoomViewController : PNViewController<UITextFieldDelegate> {
	UITextField*	roomNameField_;
	PNLobby*		lobby_;
}

@property (retain) IBOutlet UITextField* roomNameField_;
@property (retain) PNLobby *lobby_;

- (IBAction)endEditing:(id)sender;

@end
