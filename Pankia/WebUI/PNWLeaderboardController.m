//
//  PNWLeaderboardController.m
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWLeaderboardController.h"
#import "PNNativeRequest.h"
#import "PNRequestKeyManager.h"
#import "PNLeaderboardRequestHelper.h"
#import "NSDictionary+GetterExt.h"

@implementation PNWLeaderboardController

- (void)scores
{
	[self asyncRequest:kPNHTTPRequestCommandLeaderboardScores];
}

- (void)rank
{
	[self asyncRequest:kPNHTTPRequestCommandLeaderboardRank];
}

@end
