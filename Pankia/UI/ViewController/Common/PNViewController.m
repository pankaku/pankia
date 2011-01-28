//
//  PNViewController.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNControllerLoader.h"
#import "PNDashboard.h"
#import "PankiaNet+Package.h"


@implementation PNViewController

- (UINavigationController*)getNavigationController
{
	return super.navigationController;
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization		
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];	
	//PNLog(@"awakeFromNib at PNViewController");	
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];	
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
/*	
	UIButton* dismissDashboardButton = [[[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)] autorelease];
	[dismissDashboardButton setImage:[UIImage imageNamed:@"PNDismissButton.png"] forState:UIControlStateNormal];
	[dismissDashboardButton addTarget:self action:@selector(dismissDashboard:) forControlEvents:UIControlEventTouchUpInside];
	dismissDashboardButton.showsTouchWhenHighlighted = YES;
	UIBarButtonItem* dismissDashboardButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:dismissDashboardButton] autorelease];
	self.navigationItem.rightBarButtonItem = dismissDashboardButtonItem;
*/ 
}


// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == [PNDashboard sharedObject].dashboardOrientation);//UIInterfaceOrientationLandscapeLeft);
//}

- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[PNDashboard hideIndicator];
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

-(void) dismissDashboard: (UIButton *) button
{
	PNLog(@"dismiss dashboard !!!");
	[PankiaNet dismissDashboard];
}

@end
