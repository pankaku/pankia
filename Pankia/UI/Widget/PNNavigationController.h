//
//  PNNavigationController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNDashboardHeaderView.h"
#import "PNProfileAreaView.h"
#import "PNIndicator.h"

@interface PNNavigationController : UINavigationController <UINavigationControllerDelegate, PNDashboardHeaderDelegate> {
	UIImageView*			framedView;
	PNDashboardHeaderView*	dashboardHeaderView_;
	PNProfileAreaView*		profileAreaView_;
	PNIndicator*			indicator;
	NSInteger				viewId;
	BOOL					showTwitterLink;
}

- (NSInteger)viewId;
- (void)setViewId:(NSInteger)value;

- (void)hideFramedViewEnd;
- (void)showFramedView;
- (void)hideFramedViewRight;
- (void)hideFramedViewLeft;
- (void)hideFramedView:(BOOL)isHide :(float)x;
- (void)hideFooterAndLeftPane;

- (void)update;
- (void)updateDashboardHeader;
- (BOOL)showTwitterLink;
- (void)returnRootView;
- (void)showIndicator;
- (void)showLargeIndicator;
- (void)hideIndicator;
- (BOOL)isIndicatorAnimating;
- (void)updateIndicatorDescription:(NSString*)text;

- (void)disableAllButtons;
- (void)resetAllButtons;

- (void)popViewControllerAnimated:(BOOL)animated;

@end
