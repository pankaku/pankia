//
//  PNSplashManager.h
//  PankakuNet
//
//  Created by sota2 on 10/10/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPNSplashPingTargetChached			@"cached"
#define kPNSplashPingTargetAlertAccepted	@"alert_accepted"
#define kPNSplashPingTargetDisplayed		@"displayed"
#define kPNSplashPingTargetVisited			@"visited"

@class PNSplash;
@interface PNSplashManager : NSObject {
	NSMutableArray* receivedSplashes;
}
+ (PNSplashManager*)sharedObject;
- (void)processSplashModels:(NSArray*)models;
- (PNSplash*)splashToShow;
- (void)popSplash:(PNSplash*)splash;
- (void)sendAckToServer:(PNSplash*)splash delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
			   onFailed:(SEL)onFailedSelector;
- (void)sendPingToServer:(PNSplash*)splash target:(NSString*)target delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector;
- (void)sendPingToServer:(PNSplash*)splash targets:(NSArray*)targets delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
			   onFailed:(SEL)onFailedSelector;
@end
