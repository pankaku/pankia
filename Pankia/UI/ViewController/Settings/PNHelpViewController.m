//
//  PNHelpViewController.m
//  PankakuNet
//
//  Created by shunter on 10/11/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PankiaNetworkLibrary+Package.h"
#import "PNControllerLoader.h"
#import "PNNavigationController.h"
#import "PNHelpViewController.h"
#import "PNDashboard.h"


@implementation PNHelpViewController

@synthesize helpView;

- (BOOL) shouldShowWrapperFrame{
	return YES;
}

- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	if ([[PNDashboard sharedObject] isIPad]) {
		CGRect r = self.view.frame;
		r.origin.y = -14;
		self.view.frame = r;
	}
	
	helpView.backgroundColor = [UIColor blackColor];
	helpView.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[PNDashboard hideIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
	[helpView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kPNHelpSiteAddr]]];
	[PNDashboard showIndicator];
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
	[helpView release];
}


@end
