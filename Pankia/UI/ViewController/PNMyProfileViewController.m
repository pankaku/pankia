    //
//  PNMyProfileViewController.m
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMyProfileViewController.h"
#import "PNProfileContentView.h"

#import "PNLogger.h"

@implementation PNMyProfileViewController

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

- (void)loadView {
	PNLogMethodName;
	CGRect profileViewFrame = CGRectMake(0, 0, 480, 320);
	UIView *profileView = [[UIView alloc] initWithFrame:profileViewFrame];
	self.view = profileView;
	[profileView release];
	
	CGRect profileContentViewFrame = CGRectMake(0, 66, 480, 90);
	UIView *profileContentView = [[PNProfileContentView alloc] initWithFrame:profileContentViewFrame];
	[self.view addSubview:profileContentView];
	[profileContentView release];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
*/
- (void)didReceiveMemoryWarning {
	PNLogMethodName;
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	PNLogMethodName;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	PNLogMethodName;
    [super dealloc];
}


@end
