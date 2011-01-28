//
//  PNNavigationController.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PNRootNavigationController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNAppMainViewController.h"
#import "PNControllerLoader.h"
#import "PNWebViewController.h"
#import "PNGlobal.h"
#import "PNGlobalManager.h"

@implementation PNRootNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	PNLogMethodName;
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// NavigationBar
		self.navigationBar.barStyle = UIBarStyleBlackOpaque;
		self.navigationBar.translucent = YES;

		// iPadで、ナビゲーションバーが自動的に画面の幅にリサイズされてしまうのを防止。もっとスマートな方法があれば書き換える。
		if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
			self.navigationBar.autoresizingMask = UIViewAutoresizingNone;
		}
		
		// Insert webview-based home screen at first.
		PNWebViewController* homeViewController = (PNWebViewController*)[PNControllerLoader load:@"PNWebViewController" filesOwner:self];
		[self pushViewController:homeViewController animated:NO];	
		[homeViewController loadURL:kPNHomeScreenURL];
		homeViewController.title = [PNGlobalManager sharedObject].gameTitle;
    }
	return self;
}

- (void)viewDidLoad {
	PNLogMethodName;
	[super viewDidLoad];
	
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNNavigationBarBackgroundImage.png"]] autorelease];
	[self.toolbar addSubview:imageView];
}


- (void)viewDidAppear:(BOOL)animated {
	PNLogMethodName;
	[super viewDidAppear:animated];
	
	// NavigationBarの配置を決めます。
	CGRect navigationBarRect = self.navigationBar.frame;
#ifndef PNWPortraitMode
	navigationBarRect = CGRectMake(0.0f, 24.0f, 480.0f, 32.0f);
#else
	navigationBarRect = CGRectMake(0.0f, 24.0f, 320.0f, 32.0f);
#endif
	self.navigationBar.frame = navigationBarRect;
	
	// NavigationBarに背景画像を挿入します。
	UIImage *image = [[UIImage imageNamed:@"PNNavigationBarBackgroundImage.png"] 
					  stretchableImageWithLeftCapWidth:0 topCapHeight:1];
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
	imageView.frame = self.navigationBar.bounds;
	imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	imageView.layer.zPosition = -FLT_MAX;
	[self.navigationBar insertSubview:imageView atIndex:0];
	
	// Set tintColor of navigationBar
	// BarButtonItemsの色もここの設定によって反映することができます。
	UIColor *tintColor;
	tintColor = [UIColor colorWithRed:0.29f
								green:0.29f
								 blue:0.29f
								alpha:1.00f];
	self.navigationBar.tintColor = tintColor;
}

- (void)dealloc {
	PNLogMethodName;
    [super dealloc];
}

@end
