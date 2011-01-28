//
//  PNRootViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"

@interface PNRootViewController : PNViewController {
	UIViewController* contentController;
	
	NSString*	showTransition;
	NSString*	hideTransition;
	UIImageView* iPadBackgroundView;
	//UIWindow*	iPadLaunchAnimationWindow;
	UIImageView* backgroundView;
	
	BOOL hiding;
}

@property (retain) UIViewController* contentController;
//@property (retain) UIView* containerView;
@property (retain) NSString* showTransition;
@property (retain) NSString* hideTransition;

- (void)showController:(UIViewController*)controller;
- (void)hideController;

@end
