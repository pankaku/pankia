//
//  PNWDashboardController.m
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWDashboardController.h"
#import "PNNativeRequest.h"
#import "NSURL+NativeConnection.h"

@implementation PNWDashboardController

- (void)showIndicator {
	[[NSNotificationCenter defaultCenter] postNotificationName:kPankiaNativeConnectionShowIndicatorNotification object:self];
}

- (void)hideIndicator {
	[[NSNotificationCenter defaultCenter] postNotificationName:kPankiaNativeConnectionHideIndicatorNotification object:self];
}

@end
