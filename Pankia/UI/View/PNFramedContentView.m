//
//  PNFramedContentView.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNFramedContentView.h"
#import "PNDashboard.h"

@implementation PNFramedContentView

@synthesize myView,navigationController;

- (id)initWithView:(UITableView*)_view {
	self = [super initWithFrame:_view.frame];
	if (self != nil) {
		myView = [_view retain];
		myInsets = UIEdgeInsetsZero;
		
		UIImage* mainPaneBackgroundImage = 
			[UIImage imageNamed:
				[[PNDashboard sharedObject] isLandscapeMode] ? @"PNBackgroundImageLandscape.png" :
															   @"PNMainPaneBackgroundImagePortrait.png"];

		UIImageView* bgView = [[[UIImageView alloc] initWithImage:mainPaneBackgroundImage] autorelease];

		[self addSubview:bgView];
		[self addSubview:myView];
	}	
	return self;
}

- (void)reloadData {
	[myView reloadData];
	
}

// 反映されていない！
- (void)_updateView {
	if (isTable) {
		CGRect insetFrame = self.frame;
		insetFrame.origin		= CGPointMake(0.0f, 24.0f + 32.0f);
		insetFrame.size.width	= 480.0f;
		insetFrame.size.height -= myInsets.top + myInsets.bottom;// + 50.0f;
	
		[myView setFrame:insetFrame];

		if ([myView isKindOfClass:[UIScrollView class]]) {
			UIScrollView* scrollView = (UIScrollView*)myView;
			[scrollView setContentSize:CGSizeMake(insetFrame.size.width, scrollView.contentSize.height)];
		}
	}
}

- (void)setPNNavigationController:(PNNavigationController*)_navigationController {
	self.navigationController = _navigationController;
}

- (void)showIndicator {
	[navigationController showIndicator];
}

- (void)hideIndicator {
	[navigationController hideIndicator];
}

- (void)setInsets:(UIEdgeInsets)_insets {
	myInsets = _insets;
	[self _updateView];
}

- (void)setFrame:(CGRect)_frame {
	[super setFrame:_frame];
	[self _updateView];
}

- (void)isTable:(BOOL)boo {
	isTable = boo;
}

- (void)dealloc {
	self.myView					= nil;
	self.navigationController	= nil;
    [super dealloc];
}


@end
