    //
//  PNUnlinkFacebookViewController.m
//  PankakuNet
//
//  Created by pankaku on 10/08/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNUnlinkFacebookViewController.h"
#import "PNFacebookManager.h"
#import "PNDashboard.h"
#import "PNUser.h"
#import "PNUser+Package.h"

@implementation PNUnlinkFacebookViewController
- (BOOL) shouldShowWrapperFrame{
	return YES;
}

- (IBAction)unlink
{
	[PNDashboard showIndicator];
	[[PNFacebookManager sharedObject] unlinkWithDelegate:self 
											 onSucceeded:@selector(unlinkSucceeded)
												onFailed:@selector(unlinkFailed:)];
}

- (void)unlinkSucceeded
{
	[[PNDashboard sharedObject] showAlertWithTitle:@"PNTEXT:UI:Link_with_Facebook" description:@"PNTEXT:UI:Unlink_facebook_completion" okButtonTitle:@"PNTEXT:BUTTON:Ok" delegate:nil];
	[PNUser currentUser].facebookId = @"0";
	[PNUser currentUser].facebookAccount = @"";
	[PNDashboard hideIndicator];
	[PNDashboard updateDashboard];
	[PNDashboard popViewController];
}
- (void)unlinkFailed:(PNError*)error
{
	NSLog(@"ng");
}

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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
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
