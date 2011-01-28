//
//  PNAchievementRequestQueue.h
//  PankakuNet
//
//  Created by pankaku on 10/06/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PNAchievementRequestQueue : NSObject {
	NSMutableArray* unlockRequests;
	BOOL isRequestRunning;
}
- (void)addUnlockRequest:(NSArray*)achievements;
- (void)clearAllRequests;
+ (PNAchievementRequestQueue *)sharedObject;
@end
