//
//  PankiaDevAppDelegate.h
//  PankiaDev
//
//  Created by sota on 11/01/28.
//  Copyright 2011 Pankaku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PankiaNet.h"


@class PankiaDevViewController;

@interface PankiaDevAppDelegate : NSObject <UIApplicationDelegate, PankiaNetDelegate> {
    UIWindow *window;
    PankiaDevViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PankiaDevViewController *viewController;

@end

