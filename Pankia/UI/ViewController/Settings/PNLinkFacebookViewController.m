    //
//  PNLinkFacebookViewController.m
//  PankakuNet
//
//  Created by pankaku on 10/08/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLinkFacebookViewController.h"
#import "FBConnect.h"
#import "PNDashboard.h"
#import "PNFacebookManager.h"
#import "PNUser.h"
#import "PNUser+Package.h"
@interface PNLinkFacebookViewController()
@property (nonatomic, retain) FBSession* fbSession;
@end

@implementation PNLinkFacebookViewController
@synthesize fbSession;
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.fbSession = [FBSession sessionForApplication:@"1d7a71b630b815b771f151e53452224b" secret:@"859d8f0a7d4921b183d193a56f71f535" delegate:self];
}
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	self.fbSession = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] init] autorelease];
	dialog.delegate = self;
	[dialog show];
}

// Facebookにログインできたときに呼ばれます
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	// Pankia サーバー上に登録しにいきます
	[PNDashboard showIndicator];
	[[PNFacebookManager sharedObject] linkWithUid:uid sessionKey:session.sessionKey sessionSecret:session.sessionSecret delegate:self 
									  onSucceeded:@selector(linkSucceeded:) onFailed:@selector(linkFailed:)];
	
}
- (void)linkSucceeded:(PNUserModel*)userModel;
{
	[self.fbSession logout];
	[[PNUser currentUser] updateFieldsFromUserModel:userModel];
	[PNDashboard hideIndicator];
	[PNDashboard updateDashboard];
	[[PNDashboard sharedObject] showAlertWithTitle:@"Facebook" description:@"Linked" okButtonTitle:@"PNTEXT:BUTTON:Ok" delegate:nil];
	[PNDashboard popViewController];
}
- (void)linkFailed:(PNError*)error
{
	NSLog(@"linkFailed.");
	[self.fbSession logout];
	[PNDashboard hideIndicator];
	[[PNDashboard sharedObject] showAlertWithTitle:@"Facebook" description:@"Link failed" okButtonTitle:@"PNTEXT:BUTTON:Ok" delegate:nil];
	[PNDashboard popViewController];
}
- (void)dialogDidCancel:(FBDialog*)dialog {
	[PNDashboard popViewController];
}

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
	NSLog(@"ok");
}


- (void)dealloc {
    [super dealloc];
}


@end
