//
//  PNSettingsViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 12/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"
#import "PNMainMenuButton.h"

@interface PNSettingsViewController : PNViewController {
	IBOutlet	PNMainMenuButton*				linkTwitterBtn;
	IBOutlet	PNMainMenuButton*				secureAccountBtn;
	IBOutlet	PNMainMenuButton*				editAccountBtn;
	IBOutlet	PNMainMenuButton*				editProfileBtn;
	IBOutlet	PNMainMenuButton*				switchAccountBtn;
	// begin - lerry added code
	IBOutlet	PNMainMenuButton*				gameCenterBtn;
	// end - lerry added code
	IBOutlet	PNMainMenuButton*				helpBtn; 
	IBOutlet    UIButton*                       licenseBtn;
}

@property (retain) IBOutlet	PNMainMenuButton*	 linkTwitterBtn;
@property (retain) IBOutlet PNMainMenuButton*	 secureAccountBtn;
@property (retain) IBOutlet	PNMainMenuButton*	 editAccountBtn;
@property (retain) IBOutlet	PNMainMenuButton*	 editProfileBtn;
@property (retain) IBOutlet	PNMainMenuButton*	 switchAccountBtn;
// begin - lerry added code
@property (retain) IBOutlet PNMainMenuButton*	 gameCenterBtn;
// end - lerry added code
@property (retain) IBOutlet PNMainMenuButton*	 helpBtn;
@property (retain) IBOutlet UIButton*            licenseBtn;

- (IBAction)pressedLinkTwitterBtn;
- (IBAction)pressedSecureAccountBtn;
- (IBAction)pressedEditProfileBtn;
- (IBAction)pressedSwitchAccountBtn;
// begin - lerry added code
- (IBAction)pressedGameCenterBtn;
// end - lerry added code
- (IBAction)pressedHelpBtn;
- (IBAction)pressedLicenseBtn;

@end
