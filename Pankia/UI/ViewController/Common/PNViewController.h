//
//  PNViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PNViewControllerOptions
@optional
- (BOOL)shouldShowWrapperFrame;
@end

@interface PNViewController : UIViewController<PNViewControllerOptions> {
}

- (UINavigationController*)getNavigationController;

@end
