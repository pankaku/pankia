//
//  PNWebViewController.m
//  PankakuNet
//
//  Created by 横江 宗太 on 11/01/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNWebViewController.h"
#import "PNDashboard.h"
#import "PNControllerLoader.h"
#import "PNWDashboard.h"
#import "PNLoggingConfig.h"
#import "PNLogger.h"
#import "PNUser.h"
#import "PNGameManager.h"
#import "NSURL+NativeConnection.h"
#import "PNNativeRequestManager.h"
#import "PNGlobal.h"
#import "PNNativeRequest.h"
#import "PNLocalResourceUtil.h"
#import "UIWebView+PankiaDashboardExtension.h"


@implementation PNWebViewController

- (void)loadURL:(NSString*)urlString
{
	NSURL* url = [NSURL URLWithString:urlString];
	NSLog(@"open: %@", url);
	
	//[currentWebView loadDashboardURL:[NSURL URLWithString:url]];
	currentWebView.delegate = self;
	currentWebView.backgroundColor = [UIColor blackColor];

	// If url has [nav_bar_title] option, set it as a title.
	self.title = [url navigationBarTitle];
	
	[currentWebView loadDashboardURL:url];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (firstRequest == NO) {
		firstRequest = YES;
		return YES;
	}
	
	if ([[request URL] isNativeRequest]) {		
		if ([[request URL] nativeActionWithWebView:webView]) {
			return NO;
		} else {	// If unknown request, do nothing.
			PNWarn(@"NativeConnection: Unknown request received.");
			return NO;
		}
	} else { // Normal load request
		[[PNNativeRequestManager sharedObject] cancelAllRequests];
		NSString* URLString = [[[request URL] standardizedURL] absoluteString];
		
		PNWebViewController* controller = (PNWebViewController*)[PNControllerLoader load:@"PNWebViewController" filesOwner:self];
		[self.navigationController pushViewController:controller animated:YES];
		[controller loadURL:URLString];
		return NO;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[PNDashboard hideIndicator];
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
	currentWebView.delegate = nil;
    [super dealloc];
}


@end
