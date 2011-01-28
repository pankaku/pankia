//
//  PNWSessionController.m
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWSessionController.h"
#import "PNNativeRequest.h"
#import "PNSessionManager.h"

@implementation PNWSessionController

- (void)session
{
	request.response = [PNSessionManager sharedObject].latestSessionId;
}
@end
