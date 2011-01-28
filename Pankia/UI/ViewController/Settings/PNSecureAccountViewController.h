//
//  PNSecureAccountViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"
#import "PNDefaultButton.h"

@interface PNSecureAccountViewController : PNViewController <UITextFieldDelegate>{
	UILabel*         email;
	UILabel*         password;
	UILabel*         confirm;
	UITextField*     emailField;
	UITextField*     passwordField;
	UITextField*     confirmField;
	UILabel*         informationLabel;
	PNDefaultButton* submitBtn;
}

@property (retain) IBOutlet	UILabel*         email;
@property (retain) IBOutlet	UILabel*         password;
@property (retain) IBOutlet	UILabel*         confirm;
@property (retain) IBOutlet	UITextField*	 emailField;
@property (retain) IBOutlet	UITextField*	 passwordField;
@property (retain) IBOutlet	UITextField*	 confirmField;
@property (retain) IBOutlet UILabel*         informationLabel;
@property (retain) IBOutlet PNDefaultButton* submitBtn;

- (IBAction)pressedSubmitBtn;
- (IBAction)endEditing:(id)sender;

- (void)onOKSelectedNil;

@end
