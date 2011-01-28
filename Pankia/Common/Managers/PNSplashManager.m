//
//  PNSplashManager.m
//  PankakuNet
//
//  Created by sota2 on 10/10/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSplashManager.h"
#import "PNArchiveManager.h"
#import "PNSplashModel.h"
#import "PNSplash.h"
#import "PNParseUtil.h"
#import "PNLogger+Common.h"
#import "PNSplashRequestHelper.h"
#import "PNRequestKeyManager.h"
#import "PNGlobalManager.h"

#define kPNReceivedSplashes @"received_splashes"

static PNSplashManager* _sharedInstance;

@interface PNSplashManager ()
@property (nonatomic, retain) NSMutableArray *receivedSplashes;
- (BOOL)isSplashReceived:(PNSplash*)splash;
- (void)scheduleNotificationForSplash:(PNSplash*)splash;
- (void)saveReceivedSplashes;
@end

@implementation PNSplashManager
@synthesize receivedSplashes;

#pragma mark -

- (BOOL)isSplashReceived:(PNSplash*)splash
{
	return [receivedSplashes containsObject:splash];
}

- (void)scheduleNotificationForSplash:(PNSplash*)splash
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) return;
	
	UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;

	localNotif.fireDate = splash.startAt;	
    localNotif.timeZone = [NSTimeZone defaultTimeZone];

    localNotif.alertBody = splash.text;
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.soundName = nil;
	localNotif.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:splash.id], @"splash_id",
						   @"splash", @"type", nil];
	
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
	PNCLog(PNLOG_CAT_SPLASH, @"splash (%d) scheduled %@ - %@", splash.id, localNotif.fireDate, localNotif.alertBody);
    
	[localNotif release];
}

- (void)processSplashModels:(NSArray*)models
{
	for (PNSplashModel* model in models) {	
		PNSplash* splash = [PNSplash splashFromModel:model];
		
		// ignore debug item
		if (splash.isDebug) continue;
		
		if (![self isSplashReceived:splash]){
			[receivedSplashes addObject:splash];
			
			// schedule a local notification on start_at date.
			// (only if start_at is in the future)
			BOOL isInTheFuture = [splash.startAt timeIntervalSinceNow] > 0;
			if (isInTheFuture) {			
				[self scheduleNotificationForSplash:splash];
			}
			
			// Send ping to server.
			[self sendPingToServer:splash
							target:kPNSplashPingTargetChached
						  delegate:self
					   onSucceeded:nil
						  onFailed:nil];
		}
		// Send ack to server
		[self sendAckToServer:splash delegate:self onSucceeded:nil onFailed:nil];
	}
	
	[self saveReceivedSplashes];
}

- (void)saveReceivedSplashes
{
	[PNArchiveManager archiveObject:receivedSplashes toFile:kPNReceivedSplashes];
}

- (PNSplash*)splashToShow
{
	if ([PNGlobalManager sharedObject].launchedFromLocalNotification) {
		NSNumber* splashId = [[PNGlobalManager sharedObject].localNotificationUserInfo objectForKey:@"splash_id"];
		if (splashId){
			int splashIdToShow = [splashId intValue];
			for (PNSplash* splash in receivedSplashes) {
				if (splash.id == splashIdToShow) return splash;
			}
		}
	}
	
	// if all received splashes are already shown or scheduled in the future, return nil;
	for (PNSplash* splash in receivedSplashes) {
		if ([splash.startAt timeIntervalSinceNow] <= 0 && splash.hasAppeared == NO && [splash isValid]) {
			return splash;
		}
	}
	
	return nil;
}

- (void)popSplash:(PNSplash*)splash
{
	if (![receivedSplashes containsObject:splash]) {
		PNWarn(@"Error. Received splashes doesn't contain splash (%d)", splash.id);
		return;
	}
	
	splash.hasAppeared = YES;
	[self saveReceivedSplashes];
}

#pragma mark -

- (void)sendAckToServer:(PNSplash*)splash delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
			   onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector
												onFailedSelector:onFailedSelector];
	[PNSplashRequestHelper sendAckToServerForSplashId:splash.id delegate:self selector:@selector(sendAckToServerResponse:) 
												  key:requestKey];
}
- (void)sendAckToServerResponse:(NSNotification*)n
{
	NSString* requestKey = [n name];
	NSLog(@"%@", n.object);
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
- (void)sendPingToServer:(PNSplash*)splash target:(NSString*)target delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector
{
	[self sendPingToServer:splash targets:[NSArray arrayWithObject:target] delegate:delegate onSucceeded:onSucceededSelector onFailed:onFailedSelector];
}
- (void)sendPingToServer:(PNSplash*)splash targets:(NSArray*)targets delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
			   onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector
												onFailedSelector:onFailedSelector];
	[PNSplashRequestHelper sendPingToServerForSplashId:splash.id targets:targets delegate:self selector:@selector(sendPingToServerResponse:) 
												  key:requestKey];
}
- (void)sendPingToServerResponse:(NSNotification*)n
{
	NSString* requestKey = [n name];
	[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:nil];
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		self.receivedSplashes = [PNArchiveManager unarchiveObjectWithFile:kPNReceivedSplashes];
		if (self.receivedSplashes == nil) {
			self.receivedSplashes = [NSMutableArray array];
		}
	}	
	return self;
}

- (void) dealloc
{
	self.receivedSplashes = nil;
	[super dealloc];
}

+ (PNSplashManager *)sharedObject
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
@end
