//
//  PNWDashboard.h
//  PankakuNet
//
//  Created by あんのたん on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNWDashboardViewController.h"

@interface PNWDashboard : NSObject {
}
@property (retain, nonatomic) UIWindow* gameWindow;
@property (retain, nonatomic) UIWindow* pankiaWindow;
@property (retain, nonatomic) PNWDashboardViewController* dashboardViewController;

+ (PNWDashboard *)sharedObject;

- (void)launch;
- (void)close;

@end
