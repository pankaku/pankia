//
//  PNLicenseViewController.m
//  PankakuNet
//
//  Created by nakashima on 10/06/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLicenseViewController.h"


@implementation PNLicenseViewController

@synthesize licenseTextView;

- (BOOL) shouldShowWrapperFrame{
	return YES;
}

- (void)viewDidLoad
{
	licenseTextView.editable = NO;
	[licenseTextView setText:[[[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pn_lib_licenses" ofType:@"txt"] 
															  encoding:NSUTF8StringEncoding error:nil] autorelease]];
	[licenseTextView setDelegate:self];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	[UIMenuController sharedMenuController].menuVisible = NO;
	return NO;
}

- (void)dealloc
{
	licenseTextView = nil;
	
	[super dealloc];
}
@end
