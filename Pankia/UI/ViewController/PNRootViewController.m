//
//  PNRootViewController.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//ww

#import "PNRootViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import <QuartzCore/QuartzCore.h>
#import "PNDashboard.h"
#import "PankiaNet+Package.h"
#import "UIView+Slide.h"
 

#define kPNRootViewWidth 480.0f
#define kPNRootViewHeight 320.0f
#define kPNRootViewPortraitWidth 320.0f
#define kPNRootViewPortraitHeight 480.0f

@interface PNRootViewController (Private)
- (void)showiPadBackground:(UIViewController *)controller;
- (void)showCommonController:(UIViewController *)controller;
@end


@implementation PNRootViewController

@synthesize contentController,showTransition,hideTransition;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		if(!self.view){
			CGRect frame;
			if ([[PNDashboard sharedObject] isLandscapeMode]){
				frame = CGRectMake(0.0f, 0.0f, kPNRootViewWidth, kPNRootViewHeight);
			}
			else {
				frame = CGRectMake(0.0f, 0.0f, kPNRootViewPortraitWidth, kPNRootViewPortraitHeight);
			}
			self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
		}
    }
    return self;
}

- (void)showController:(UIViewController*)controller {
	CGRect screenRect = [UIScreen mainScreen].bounds;
	BOOL isIPad = screenRect.size.width != 320 || screenRect.size.height != 480;
	
	if (isIPad) {
		PNCLog(YES, @"iPad Mode.");
		[self showiPadBackground:controller];
	} else {
		// ipod/iphone
		[self showCommonController:controller];
	}
}

/* iPad用背景を表示する */
- (void)showiPadBackground:(UIViewController*)controller {
//	CGRect screenRect = [UIScreen mainScreen].bounds;
	
	backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNiPadFilledBackground.png"]];
//	backgroundView.frame = CGRectMake(-1 * (screenRect.size.height - screenRect.size.width) / 2,(screenRect.size.height - screenRect.size.width) / 2, screenRect.size.height, screenRect.size.width);
	//backgroundView.transform = CGAffineTransformMakeRotation(M_PI_2);
	backgroundView.alpha = 0.0f;
	[self.view addSubview:backgroundView];
	[UIView beginAnimations:@"ShowiPadBackground" context:[controller retain]];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(iPadBackgroundShowAnimationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.16f];
	backgroundView.alpha = 1.0f;
	[UIView commitAnimations];
}

/* iPad用背景表示アニメーション終了 */
- (void)iPadBackgroundShowAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	/* 共通部分を表示する */
	UIViewController* controller = (UIViewController*)context;
	[self showCommonController:[controller autorelease]];
	[[PNDashboard sharedObject] rootViewAppeared];
}

/* iPadとiPhone共通の表示部分 */
- (void)showCommonController:(UIViewController *)controller {
	CGRect screenRect = [UIScreen mainScreen].bounds;
	BOOL isIPad = screenRect.size.width != 320 || screenRect.size.height != 480;
	
	float dashboardMargin = isIPad ? 20.0f : 0.0f;
	float rootViewWidth = kPNRootViewWidth + dashboardMargin * 2.0f;
	float rootViewHeight = kPNRootViewHeight + dashboardMargin * 2.0f;
	
	self.contentController = controller;
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		UIView* innerView = self.contentController.view;
		UIView* outerView;
		CGRect outerFrame;
		outerView = [[[UIView alloc] init] autorelease];
		outerFrame = CGRectMake((screenRect.size.height - rootViewWidth) / 2, 
								(screenRect.size.width - rootViewHeight) / 2, 
								rootViewWidth, rootViewHeight);
		outerView.frame = outerFrame;
		
		innerView.frame = CGRectMake(dashboardMargin, 
									 dashboardMargin, 
									 rootViewWidth - dashboardMargin * 2.0f, 
									 rootViewHeight - dashboardMargin * 2.0f);
		innerView.clipsToBounds = YES;
		self.contentController.view = outerView;
		[outerView addSubview:innerView];
	}
	else {
		self.contentController.view.frame = CGRectMake((screenRect.size.width - kPNRootViewPortraitWidth) / 2, (screenRect.size.height - kPNRootViewPortraitHeight) / 2, kPNRootViewPortraitWidth, kPNRootViewPortraitHeight);
	}
	[contentController viewWillAppear:YES];
	
	UIImage* bgImageFileForPod = [UIImage imageNamed:([PNDashboard sharedObject].dashboardOrientation == UIInterfaceOrientationLandscapeRight ||
							 [PNDashboard sharedObject].dashboardOrientation == UIInterfaceOrientationLandscapeLeft) ?
							@"PNBackgroundImageLandscape.png" : @"PNBackgroundImage.png"];
	NSString* bgImageFileForPad = @"PNiPadWindowFrame.png";
	UIImageView* bgImage = [[[UIImageView alloc] initWithImage:isIPad ? [UIImage imageNamed:bgImageFileForPad] : bgImageFileForPod] autorelease];
	[self.contentController.view addSubview:bgImage];
	[self.contentController.view sendSubviewToBack:bgImage];
	

	[self.view addSubview:contentController.view];
	
	//太さ対策　暫定版
	if (isIPad) {
		if ([controller isKindOfClass:[UINavigationController class]]) {
			CGRect barRect = [(UINavigationController *)controller navigationBar].frame;
			barRect.size.height = 32;
			[(UINavigationController *)controller navigationBar].frame = barRect;
			[(UINavigationController *)controller navigationBar].bounds = barRect;
		}
	}
	
	
	if (iPadBackgroundView) {
		[self.view addSubview:iPadBackgroundView];
	}
	
	CATransition* animation = [CATransition animation];
	animation.type = kCATransitionMoveIn;
	animation.subtype = kCATransitionFromBottom;//showTransition;
	animation.duration = 0.4f;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.delegate = self;
	[[self.contentController.view layer] addAnimation:animation forKey:@"showController4iPod"];
}

- (void)hideController {
	
	if (self.contentController == nil)
		return;
	
	[self.contentController viewWillDisappear:YES];

	if (backgroundView) {
		[UIView beginAnimations:@"HideiPadBackground" context:nil];
		[UIView setAnimationDuration:0.4f];
		backgroundView.alpha = 0.0f;
	//	CGRect screenRect = [UIScreen mainScreen].bounds;
	//	iPadBackgroundView.frame = CGRectMake(-1 * (screenRect.size.height - screenRect.size.width) / 2 + kPNRootViewWidth, (screenRect.size.height - screenRect.size.width) / 2, screenRect.size.height, screenRect.size.width);
		[UIView commitAnimations];
	}
	
	CATransition* animation = [CATransition animation];
	animation.type = kCATransitionReveal;
	animation.subtype = kCATransitionFromTop;//hideTransition;
	animation.duration = 0.4f;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.delegate = self;
	
	self.contentController.view.hidden = YES;
	hiding = YES;
	[[self.contentController.view layer] addAnimation:animation forKey:@"hideController"];
	
	PNCLog(PNLOG_CAT_UI, @"%s", __FUNCTION__);
}

- (void)animationDidStop:(CAAnimation*)_animation finished:(BOOL)_finished {
	PNLogMethodName;
	PNCLog(PNLOG_CAT_UI, @"%s", __FUNCTION__);
	
	PNCLog(PNLOG_CAT_UI, @"Animation Key");
	//ちゃんと動いてない
	//if ( _animation == [[self.contentController.view layer] animationForKey:@"hideController"] ) {
	if (hiding) {
		
		hiding = NO;
		
		if ( ! self.contentController.view.hidden ) {
		    PNWarn(@"%s: contentController did not disappeared!", __FUNCTION__);
		}

		//PNLog(@"contentController.view is hidden");
		[self.contentController viewDidDisappear:YES];	
		[self.contentController.view removeFromSuperview];

		// what's the difference between iPadBackgroundView and backgroundView? (wencheng)
		if (iPadBackgroundView) {
			[iPadBackgroundView removeFromSuperview];
			[iPadBackgroundView release];
			iPadBackgroundView = nil;
		}
		
		if (backgroundView) {
			[UIView beginAnimations:@"HideiPadBackground" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(backgroundHideAnimationDidStop:finished:context:)];
			[UIView setAnimationDuration:0.16f];
			backgroundView.alpha = 0.0f;
			[UIView commitAnimations];
		} else {
			
			[[PNDashboard sharedObject] rootViewDisappeared];
		}
		
		//PNSafeDelete(contentController);
	//} else if ( _animation == [[self.contentController.view layer] animationForKey:@"showController4iPod"] ) {
	} else {
		[[PNDashboard sharedObject] rootViewAppeared];
		
		[self.contentController viewDidAppear:YES];
		
//		NSDictionary* defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PankiaNetDefaults" ofType:@"plist"]];
//		if (iPadBackgroundView && ![[defaults objectForKey:@"iPadZoomEnabled"] boolValue]) {
//			iPadBackgroundView.image = [UIImage imageNamed:@"PNiPadBackground.png"];
//		}
		
//		if (iPadLaunchAnimationWindow) {
//			[iPadLaunchAnimationWindow resignKeyWindow];
//			[iPadLaunchAnimationWindow release];
//			[self.view.window makeKeyWindow];
//		}
		
	}
	
	[PankiaNet animationDidStop:_animation finished:_finished];
}

- (void)backgroundHideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[backgroundView removeFromSuperview];
	[backgroundView release];
	backgroundView = nil;

	[[PNDashboard sharedObject] rootViewDisappeared];
}

#pragma mark AutoRotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [[PNDashboard sharedObject] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
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
	self.contentController		= nil;
	self.showTransition			= nil;
	self.hideTransition			= nil;
    [super dealloc];
}

@end
