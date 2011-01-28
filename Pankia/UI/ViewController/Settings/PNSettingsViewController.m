//
//  PNSettingsViewController.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 12/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNSettingsViewController.h"
#import "PNControllerLoader.h"
#import "PNSecureAccountViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNDashboard.h"

@implementation PNSettingsViewController

@synthesize linkTwitterBtn, secureAccountBtn ,editProfileBtn, switchAccountBtn, editAccountBtn, gameCenterBtn, licenseBtn, helpBtn;

- (void) viewWillAppear:(BOOL)animated{
	if ([PNUser currentUser].isSecured) {
		
		secureAccountBtn.hidden = YES;
		editAccountBtn.hidden = NO;
	} else {
		secureAccountBtn.hidden = NO;
		editAccountBtn.hidden = YES;
	}
	// begin - lerry added code
	if (![[PNManager sharedObject] gameCenterOptionSet]) {
		[[self gameCenterBtn] setTitle:nil forState:UIControlStateNormal];
		[[self gameCenterBtn] setAlpha:0.6f];
	} else {
		[[self gameCenterBtn] setAlpha:1.0f];
		[[self gameCenterBtn] setTitle:@"Game Center" forState:UIControlStateNormal];
	}
	// end - lerry added code	
}

- (IBAction)pressedLinkTwitterBtn;
{
	if ([PNUser currentUser].isLinkTwitter) {
		[PNDashboard pushViewControllerNamed:@"PNUnLinkTwitterViewController"];
	} else {
		[PNDashboard pushViewControllerNamed:@"PNLinkTwitterViewController"];
	}
	
//	[PNDashboard pushViewControllerNamed:@"PNLinkAccountViewController"];
}

- (IBAction)pressedSecureAccountBtn
{
	UIViewController* secure = [PNControllerLoader load:@"PNSecureAccountViewController" filesOwner:nil];
	if ([PNUser currentUser].isSecured) {
		[secure setTitle:@"PNTEXT:UI:Edit_Account"];
	} else {
		[secure setTitle:@"PNTEXT:UI:MENU:Secure_Account"];
	}
	[PNDashboard pushViewController:secure];	
}

- (IBAction)pressedEditProfileBtn
{
	[PNDashboard pushViewControllerNamed:@"PNEditProfileViewController"];	
}

- (IBAction)pressedSwitchAccountBtn
{
	[PNDashboard pushViewControllerNamed:@"PNSwitchAccountAccountSelectorViewController"];	
}

// begin - lerry added code
-(IBAction)pressedGameCenterBtn
{
	if ([[PNManager sharedObject] gameCenterOptionSet]) {
		PNCLog(YES, @"GameCenterBtn clicked");
		[PNDashboard pushViewControllerNamed:@"PNGameCenterOptionViewController"];
	}
}
// end - lerry added code

- (IBAction)pressedHelpBtn
{
	[PNDashboard pushViewControllerNamed:@"PNHelpViewController"];
}

- (IBAction)pressedLicenseBtn
{
	[PNDashboard pushViewControllerNamed:@"PNLicenseViewController"];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
