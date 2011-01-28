//
//  PNRegistrationViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PNRegistrationViewController : UIViewController{
	IBOutlet	UITextField*				usernameField;
	NSString*								controllerName;
	NSArray*								pushControllers;
	BOOL									isLaunchDashboard;
	IBOutlet	UIButton*					agreeButton;
	IBOutlet	UIButton*					disagreeButton;
	IBOutlet	UILabel*					pankiaDescriptionLabel;
	IBOutlet	UILabel*					useTwitterDescription;
	IBOutlet	UIButton*					useTwitterButton;
	IBOutlet	UILabel*					titleLabel;
	IBOutlet	UIButton*					submitButton;
	IBOutlet	UILabel*					usernameLabel;	
}
@property (retain) NSString*				controllerName;
@property (retain) NSArray*					pushControllers;
@property (assign) BOOL						isLaunchDashboard;
@property (retain) IBOutlet UILabel*		pankiaDescriptionLabel;
@property (retain) IBOutlet	UIButton*		agreeButton;
@property (retain) IBOutlet	UIButton*		disagreeButton;
@property (retain) IBOutlet UIButton*		useTwitterButton;
@property (retain) IBOutlet UILabel*		useTwitterDescription;
@property (retain) IBOutlet UILabel*		titleLabel;
@property (retain) IBOutlet UILabel*		usernameLabel;
@property (retain) IBOutlet UITextField*	usernameField;
@property (retain) IBOutlet	UIButton*		submitButton;

- (IBAction)endEditing:(id)sender;
- (IBAction)pressedTwitterRegisterBtn;
- (IBAction)agree;
- (IBAction)disagree;
- (IBAction)submit;
- (void)hide;

- (void)onOKSelected;

@end
