//
//  NSObject+AppDelegateExtensions.m
//  PankiaLite
//
//  Created by sota2 on 10/10/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSObject+AppDelegateExtensions.h"
#import "PNExtendedAppDelegate.h"

@implementation NSObject(AppDelegateExtensions)
/*
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[PNExtendedAppDelegate sharedObject] applicationDidBecomeActive:application];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[PNExtendedAppDelegate sharedObject] applicationWillResignActive:application];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url  // no equiv. notification. return NO if the application can't open for some reason
{
	return [[PNExtendedAppDelegate sharedObject] application:application handleOpenURL:url];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;      // try to clean up as much memory as possible. next step is to terminate app
{
	[[PNExtendedAppDelegate sharedObject] applicationDidReceiveMemoryWarning:application];
}

- (void)applicationWillTerminate:(UIApplication *)application;
{
	[[PNExtendedAppDelegate sharedObject] applicationWillTerminate:application];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application;        // midnight, carrier time update, daylight savings time change
{
	[[PNExtendedAppDelegate sharedObject] applicationSignificantTimeChange:application];
}



- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration;
{
//	[[PNExtendedAppDelegate sharedObject] application:application willChangeStatusBarOrientation:newStatusBarOrientation];
}
- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation;
{
	[[PNExtendedAppDelegate sharedObject] application:application didChangeStatusBarOrientation:oldStatusBarOrientation];
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame;   // in screen coordinates
{
	[[PNExtendedAppDelegate sharedObject] application:application willChangeStatusBarFrame:newStatusBarFrame];
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame;
{
	[[PNExtendedAppDelegate sharedObject] application:application didChangeStatusBarFrame:oldStatusBarFrame];
}
*/

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[PNExtendedAppDelegate sharedObject] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[[PNExtendedAppDelegate sharedObject] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	[[PNExtendedAppDelegate sharedObject] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}
- (void) applicationWillEnterForeground:(UIApplication *)application
{
	[[PNExtendedAppDelegate sharedObject] applicationWillEnterForeground:application];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	[[PNExtendedAppDelegate sharedObject] applicationDidEnterBackground:application];
}
@end
