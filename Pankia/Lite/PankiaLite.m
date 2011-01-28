//
//  PankiaLite.m
//  PankiaLite
//
//  Created by sota2 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PankiaLite.h"

#import "PNGlobalManager.h"
#import "PNSimpleSessionManager.h"
#import "PNSessionModel.h"
#import "PNSplashManager.h"
#import "PNDeviceManager.h"

#import "PNSplash.h"
#import "PNSplashView.h"


@implementation PankiaLite
+ (void)initWithGameKey:(NSString*)gameKey secret:(NSString*)secret options:(NSDictionary*)options
{
	[PNGlobalManager sharedObject].startupDate = [NSDate date];
	[PNGlobalManager sharedObject].gameKey = gameKey;
	[PNGlobalManager sharedObject].gameSecret = secret;
	
	// Check if launched by local notification
	UILocalNotification *localNotif = [options
									   objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]; 
	if (localNotif) {
		[PNGlobalManager sharedObject].launchedFromLocalNotification = YES;
		[PNGlobalManager sharedObject].localNotificationUserInfo = localNotif.userInfo;
	}
	
	[[PNExtendedAppDelegate sharedObject] registerDelegate:[[[self alloc] init] autorelease]];
	
	[[PNSimpleSessionManager sharedObject] createSessionWithDelegate:self onSucceeded:@selector(sessionCreateSucceeded:) 
															onFailed:@selector(sessionCreateFailed:) withObject:nil];
}
+ (void)sessionCreateSucceeded:(PNSessionModel*)session
{
	NSLog(@"session :%@", session.id);
	[PNGlobalManager sharedObject].sessionId = session.id;
	
	// Register for Push
	[[UIApplication sharedApplication] 
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	// Register splashes
	[[PNSplashManager sharedObject] processSplashModels:session.splashes];	
	
	// Splash ad can be shown if elapsed time from start up was less than 10 secs.
	NSTimeInterval intervalFromStartup = -[[PNGlobalManager sharedObject].startupDate timeIntervalSinceNow];
	if (intervalFromStartup <= 10.0f) {
		// If there were splash to show, show first one.
		PNSplash* splashToShow = [[PNSplashManager sharedObject] splashToShow];
		if (splashToShow) {
			PNCLog(PNLOG_CAT_SPLASH, @"Splash to show: %d", splashToShow.id);
			
			NSArray* pingTargets = [PNGlobalManager sharedObject].launchedFromLocalNotification ?
			[NSArray arrayWithObjects:kPNSplashPingTargetDisplayed, kPNSplashPingTargetAlertAccepted, nil] :
			[NSArray arrayWithObject:kPNSplashPingTargetDisplayed];
			[[PNSplashManager sharedObject] sendPingToServer:splashToShow targets:pingTargets delegate:self 
												 onSucceeded:nil onFailed:nil];
			
			PNSplashView* splashView = [PNSplashView showSplash:splashToShow orientation:UIInterfaceOrientationPortrait];
			splashView.autoRotateEnabled = NO;
			
			[[PNSplashManager sharedObject] popSplash:splashToShow];
		}
	}
}

#pragma mark -
- (void)pnApplication:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	[[[[PNDeviceManager alloc] init] autorelease] registerDeviceToken:deviceToken];
}
@end
