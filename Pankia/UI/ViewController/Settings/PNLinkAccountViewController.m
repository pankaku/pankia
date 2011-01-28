//
//  PNLinkAccountViewController.m
//  PankakuNet
//
//  Created by あんのたん on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLinkAccountViewController.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNDashboard.h"

@implementation PNLinkAccountViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL) shouldShowWrapperFrame{
	return YES;
}

- (IBAction)editTwitter:sender {
	NSLog(@"Edit twitter");
	if ([PNUser currentUser].isLinkTwitter) {
		[PNDashboard pushViewControllerNamed:@"PNUnLinkTwitterViewController"];
	} else {
		[PNDashboard pushViewControllerNamed:@"PNLinkTwitterViewController"];
	}
}

- (IBAction)editFacebook:sender {
	NSLog(@"Edit facebook");
	if ([PNUser currentUser].isLinkFacebook) {
		[PNDashboard pushViewControllerNamed:@"PNUnLinkTwitterViewController"];
	} else {
		[PNDashboard pushViewControllerNamed:@"PNLinkTwitterViewController"];
	}
}

@end
