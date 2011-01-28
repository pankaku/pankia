//
//  PNWDashboardViewController.m
//  PankakuNet
//
//  Created by あんのたん on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWDashboardViewController.h"
#import "PNWDashboard.h"
#import "PNLoggingConfig.h"
#import "PNLogger.h"
#import "PNUser.h"
#import "PNGameManager.h"
#import "NSURL+NativeConnection.h"
#import "PNNativeRequestManager.h"
#import "PNGlobal.h"

//NSString* const kPNWHomeViewURL = @"http://192.168.0.72/~annotunzdy/PankiaConnect/PankiaConnect.html";
//NSString* const kPNWHomeViewURL = @"http://127.0.0.1/~annotunzdy/test.html";
NSString* const kPNWHomeViewURL = kPNHomeScreenURL;
@implementation PNWDashboardViewController

@synthesize webView, indicatorView, URLCaches, nameLabel, lastestURL;

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
	self.URLCaches = [NSMutableArray array];
	[self home:nil];
	[self.indicatorView startAnimating];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeLastestSession:) name:kPNSessionManagerChangeLastestSessionNotification object:[PNSessionManager sharedObject]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close:) name:kPankiaNativeConnectionWindowCloseNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideIndicator:) name:kPankiaNativeConnectionHideIndicatorNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showIndicator:) name:kPankiaNativeConnectionShowIndicatorNotification object:nil];
	self.nameLabel.text = [PNUser currentUser].username ? [PNUser currentUser].username : @"PANKIA";
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.webView = nil;
	self.indicatorView = nil;
	self.nameLabel = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	[self viewDidUnload];
	self.URLCaches = nil;
	self.lastestURL = nil;
    [super dealloc];
}

- (IBAction)home:sender {
	NSString* URLString;
	if ([PNSessionManager sharedObject].latestSessionId) {
		URLString = kPNWHomeViewURL;
		//URLString = [NSString stringWithFormat:@"%@?session=%@", kPNWHomeViewURL, [PNSessionManager sharedObject].latestSessionId];
	} else {
		URLString = kPNWHomeViewURL;
	}
	[self loadURLWithString:URLString];
}

- (IBAction)close:sender {
	[[PNWDashboard sharedObject] close];
}

- (void)loadURLWithString:(NSString *)URLString {
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([[request URL] isNativeRequest]) {		
		if ([[request URL] nativeActionWithWebView:aWebView]) {
			return NO;
		} else {	// If unknown request, do nothing.
			PNWarn(@"NativeConnection: Unknown request received.");
			return NO;
		}
	} else { // Normal load request
		[[PNNativeRequestManager sharedObject] cancelAllRequests];
		return YES;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[self showIndicator:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
//	Please hide indicator from JS.
	[self hideIndicator:nil];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
//	Please hide indicator from JS.
	[self hideIndicator:nil];
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"PANKIA" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
//	[self close:nil];
}

- (void)didChangeLastestSession:(NSNotification *)aNotification {
	NSMutableString* URLString = [[[[[self.lastestURL absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0] mutableCopy] autorelease];
	if ([PNSessionManager sharedObject].latestSessionId) {
		//[URLString appendFormat:@"?session=%@", [PNSessionManager sharedObject].latestSessionId];
	}
	[self loadURLWithString:URLString];
	self.nameLabel.text = [PNUser currentUser].username; 
}

- (void)showIndicator:sender {
	if (self.webView.alpha == 1.0f) {
		[UIView beginAnimations:@"PNWWebViewStartLoadAnimation" context:nil];
		[UIView setAnimationDuration:0.5f];
		self.webView.alpha = 0.2f;
		[UIView commitAnimations];
	}
}

- (void)hideIndicator:sender {
	if (self.webView.alpha != 1.0f) {
		[UIView beginAnimations:@"ShowPNWWebViewAnimation" context:nil];
		[UIView setAnimationDuration:0.5f];
		self.webView.alpha = 1.0f;
		[UIView commitAnimations];
	}
}

@end
