//
//  PNGlobalManager.h
//  PankakuNet
//
//  Created by sota2 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PNGlobalManager : NSObject {
	NSMutableDictionary *globalDictionary;
}
@property (nonatomic, retain) NSString* gameKey;
@property (nonatomic, retain) NSString* gameSecret;
@property (nonatomic, retain) NSString* sessionId;
@property (nonatomic, retain) NSDate* startupDate;
@property (nonatomic, retain) NSString* gameTitle;
@property (nonatomic, assign) BOOL launchedFromLocalNotification;
@property (nonatomic, retain) NSDictionary* localNotificationUserInfo;
@property (nonatomic, assign) BOOL originalIdleTimerDisabled;

+ (PNGlobalManager*)sharedObject;
- (void)setObject:(id)obj forKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;
- (NSString*)preferedLanguage;
- (BOOL)matchEnabled;
- (BOOL)coinsEnabled;
- (BOOL)itemEnabled;
@end
