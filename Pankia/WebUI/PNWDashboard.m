//
//  PNWDashboard.m
//  PankakuNet
//
//  Created by あんのたん on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWDashboard.h"

#define kPNWDashboardAnimationDuration 0.5f

#define kPNWDashboardWidth ([UIScreen mainScreen].bounds.size.height)
#define kPNWDashboardHeight ([UIScreen mainScreen].bounds.size.width)

static PNWDashboard* _sharedInstance;

@implementation PNWDashboard

@synthesize gameWindow, pankiaWindow, dashboardViewController;

+ (PNWDashboard *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}

- (void)launch {
	
	if (self.pankiaWindow) {
		return;
	}
	
	self.pankiaWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, kPNWDashboardWidth, kPNWDashboardHeight)];
	self.pankiaWindow.transform = CGAffineTransformMakeRotation(M_PI_2);
	self.pankiaWindow.frame = CGRectMake(-1.0f * kPNWDashboardHeight, 0, kPNWDashboardHeight, kPNWDashboardWidth);
	self.pankiaWindow.backgroundColor = [UIColor blackColor];
	self.gameWindow = [[UIApplication sharedApplication] keyWindow];
	[self.pankiaWindow makeKeyAndVisible];
	self.dashboardViewController = [[[PNWDashboardViewController alloc] init] autorelease];
	self.dashboardViewController.view.frame = CGRectMake(0, 0, kPNWDashboardWidth, kPNWDashboardHeight);
	[self.pankiaWindow addSubview:self.dashboardViewController.view];
	
	[UIView beginAnimations:@"ShowPNWWindowAnimation" context:nil];
	[UIView setAnimationDuration:kPNWDashboardAnimationDuration];
	self.pankiaWindow.frame = CGRectMake(0, 0, kPNWDashboardHeight, kPNWDashboardWidth);
	[UIView commitAnimations];
	
}

- (void)close {
	[UIView beginAnimations:@"HidePNWWindowAnimation" context:nil];
	[UIView setAnimationDuration:kPNWDashboardAnimationDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	self.pankiaWindow.frame = CGRectMake(-1.0f * kPNWDashboardHeight, 0, kPNWDashboardHeight, kPNWDashboardWidth);
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.pankiaWindow = nil;
	[self.gameWindow makeKeyAndVisible];
	self.gameWindow = nil;
	self.dashboardViewController = nil;
}

@end
