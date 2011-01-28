    //
//  PNAlertViewController.m
//  PankakuNet
//
//  Created by あんのたん on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNAutoRotateViewController.h"

@implementation PNAutoRotateViewController
@synthesize rotationDelegate;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (rotationDelegate != nil) {
		NSObject<PNAutoRotateViewControllerDelegate>* delegateObject = (NSObject*)rotationDelegate;
		if ([delegateObject respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
			return [delegateObject shouldAutorotateToInterfaceOrientation:interfaceOrientation];
		} else {
			return YES;
		}
	} else {
		return YES;
	}
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (rotationDelegate != nil) {
		NSObject<PNAutoRotateViewControllerDelegate>* delegateObject = (NSObject*)rotationDelegate;
		if ([delegateObject respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]) {
			[delegateObject willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
		}
	}
}
@end
