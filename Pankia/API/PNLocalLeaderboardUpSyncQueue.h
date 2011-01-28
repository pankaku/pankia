//
//  PNLocalLeaderboardUpSyncQueue.h
//  PankakuNet
//
//  Created by pankaku on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNLocalLeaderboardScore;
@interface PNLocalLeaderboardUpSyncQueue : NSObject {
	BOOL isRunning;
	PNLocalLeaderboardScore* currentScoreToSync;
	NSString* currentRequestKey;
	id delegate;
}
@property (nonatomic, assign) id delegate;
+ (PNLocalLeaderboardUpSyncQueue*)sharedObject;
- (void)start;
@end
