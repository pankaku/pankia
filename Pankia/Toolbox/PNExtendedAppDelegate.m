//
//  PNExtendedAppDelegate.m
//  PankiaLite
//
//  Created by sota2 on 10/10/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNExtendedAppDelegate.h"
#import "PNLogger.h"

static PNExtendedAppDelegate* _sharedInstance;

@interface PNExtendedAppDelegate ()
@property(retain) NSMutableArray*	delegates;
@property(assign) BOOL				idleTimerDisabled;
@end

@implementation PNExtendedAppDelegate
@synthesize delegates,idleTimerDisabled;

- (id)init 
{
	if (self = [super init]) {
		//古いデリゲートを保持しておく
		self.delegates = [NSMutableArray array];
		self.idleTimerDisabled = [UIApplication sharedApplication].idleTimerDisabled;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.delegates = nil;
	[super dealloc];
}

- (void)registerDelegate:(id<PNAppDelegateProtocol>)aDelegate
{
	if ([delegates containsObject:aDelegate]) return;
	[delegates addObject:aDelegate];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(applicationDidFinishLaunching:)])
			[delegate applicationDidFinishLaunching:application];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)])
			return [delegate application:application  didFinishLaunchingWithOptions:launchOptions];
	}
	
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	for(id<PNAppDelegateProtocol, UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(pnApplicationDidBecomeActive:)])
			[delegate pnApplicationDidBecomeActive:application];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	for(id<PNAppDelegateProtocol, UIApplicationDelegate> delegate in delegates) {
		
		if([delegate respondsToSelector:@selector(pnApplicationWillResignActive:)])
			[delegate pnApplicationWillResignActive:application];
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url  // no equiv. notification. return NO if the application can't open for some reason
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		
		if([delegate respondsToSelector:@selector(application:handleOpenURL:)])
			return [delegate application:application handleOpenURL:url];
	}
	
	return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;      // try to clean up as much memory as possible. next step is to terminate app
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		
		if([delegate respondsToSelector:@selector(applicationDidReceiveMemoryWarning:)])
			[delegate applicationDidReceiveMemoryWarning:application];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application;
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		
		if([delegate respondsToSelector:@selector(applicationWillTerminate:)])
			[delegate applicationWillTerminate:application];
	}
	[UIApplication sharedApplication].idleTimerDisabled = self.idleTimerDisabled;
}

- (void)applicationSignificantTimeChange:(UIApplication *)application;        // midnight, carrier time update, daylight savings time change
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		
		if([delegate respondsToSelector:@selector(applicationSignificantTimeChange:)])
			[delegate applicationSignificantTimeChange:application];
	}
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	for(id<PNAppDelegateProtocol, UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(pnApplicationWillEnterForeground:)])
			[delegate pnApplicationWillEnterForeground:application];
	}
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	for(id<PNAppDelegateProtocol, UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(pnApplicationDidEnterBackground:)])
			[delegate pnApplicationDidEnterBackground:application];
	}
}


- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration;
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(application:willChangeStatusBarOrientation:duration:)])
			[delegate application:application willChangeStatusBarOrientation:newStatusBarOrientation duration:duration];
	}
}
- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation;
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(application:didChangeStatusBarOrientation:)])
			[delegate application:application didChangeStatusBarOrientation:oldStatusBarOrientation];
	}
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame;   // in screen coordinates
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(application:willChangeStatusBarFrame:)])
			[delegate application:application willChangeStatusBarFrame:newStatusBarFrame];
	}
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame;
{
	for(id<UIApplicationDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(application:didChangeStatusBarFrame:)])
			[delegate application:application didChangeStatusBarFrame:oldStatusBarFrame];
	}
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	for(id<PNAppDelegateProtocol, UIApplicationDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(pnApplication:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
			[delegate pnApplication:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
		}
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	//ここに、受け取ったプッシュ通知が飛んでくる
	for(id<PNAppDelegateProtocol, UIApplicationDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(pnApplication:didReceiveRemoteNotification:)]) {
			[delegate pnApplication:application didReceiveRemoteNotification:userInfo];
		}
	}
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if (TARGET_IPHONE_SIMULATOR)
#else
	for(id<PNAppDelegateProtocol, UIApplicationDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(pnApplication:didFailToRegisterForRemoteNotificationsWithError:)]) {
			[delegate pnApplication:application didFailToRegisterForRemoteNotificationsWithError:error];
		}
	}
#endif
}



#pragma mark -
#pragma mark Singleton pattern


+ (PNExtendedAppDelegate*)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init];
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;
		}
	}
	return nil;
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
	return UINT_MAX;
}

- (void)release
{
}

- (id)autorelease
{
	return self;
}


@end
