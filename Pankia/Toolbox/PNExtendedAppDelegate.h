//
//  PNExtendedAppDelegate.h
//  PankiaLite
//
//  Created by sota2 on 10/10/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PNAppDelegateProtocol
@optional
- (void)pnApplication:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)pnApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)pnApplication:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)pnApplicationWillEnterForeground:(UIApplication *)application;
- (void)pnApplicationDidEnterBackground:(UIApplication *)application;
- (void)pnApplicationDidBecomeActive:(UIApplication *)application;
- (void)pnApplicationWillResignActive:(UIApplication *)application;
@end


@interface PNExtendedAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
	NSMutableArray*		delegates;
	BOOL				idleTimerDisabled;	
}
+ (PNExtendedAppDelegate *)sharedObject;
- (void)registerDelegate:(id<PNAppDelegateProtocol>)aDelegate;
@end
