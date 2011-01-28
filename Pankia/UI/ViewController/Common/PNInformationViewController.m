//
//  PNInformationViewController.m
//  PankakuNet
//
//  Created by nakashima on 10/02/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNInformationViewController.h"


@implementation PNInformationViewController

@synthesize informationMessageLabel;
- (BOOL) shouldShowWrapperFrame{
	return YES;
}
- (void)setInformationMessage:(NSString*)informationMessage
{
	[informationMessageLabel setText:informationMessage];
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
	self.informationMessageLabel	= nil;
    [super dealloc];
}

@end
