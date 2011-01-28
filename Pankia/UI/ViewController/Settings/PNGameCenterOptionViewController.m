//
//  PNGameCenterOptionViewController.m
//  PankakuNet
//
//  Created by Yujin TANG on 11/12/10.
//  Copyright 2010 Waseda University. All rights reserved.
//

#import "PNGameCenterOptionViewController.h"
#import "PNDashboard.h"
#import "PNManager.h"
#import "PNSettingManager.h"
#import <GameKit/GameKit.h>

@interface PNGameCenterOptionViewController (Private)
-(void)updateLabel;
@end


@implementation PNGameCenterOptionViewController

@synthesize gameCenterOptionSwitch, currentAccountLabel, currentAccount;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
- (void) updateLabel {
	if ([[PNManager sharedObject] gameCenterEnabled]) {
		if ([GKLocalPlayer localPlayer].authenticated) {
			[[self currentAccount] setText:[GKLocalPlayer localPlayer].alias];
			[[self currentAccountLabel] setText:@"Currently logged in as:"];
			[[self currentAccountLabel] setHidden:NO];
			[[self currentAccount] setHidden:NO];
		} else {
			[[self currentAccountLabel] setHidden:YES];
			[[self currentAccount] setHidden:YES];
		}
		
	} else {
		[[self currentAccountLabel] setText:@"Game Center option disabled."];
		[[self currentAccountLabel] setHidden:NO];
		[[self currentAccount] setHidden:YES];
	}
}

- (BOOL) shouldShowWrapperFrame{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([[PNManager sharedObject] gameCenterEnabled ]) {
		[[self gameCenterOptionSwitch] setOn:YES];
	}
	else {
		[[self gameCenterOptionSwitch] setOn:NO];
	}
	[self updateLabel];
}

-(IBAction)gameCenterOptionSwitchStateChanged
{
	BOOL state = [self gameCenterOptionSwitch].on;
	[[PNManager sharedObject] setGameCenterToState:state];
	if (state) {
		if (![GKLocalPlayer localPlayer].authenticated) {
			[[PNManager sharedObject] authenticateLocalPlayer];
		}
	} else {
		// log off the user if the user is logged in
	}
	[self updateLabel];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
