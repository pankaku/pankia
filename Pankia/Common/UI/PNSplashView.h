//
//  PNSplashView.h
//  PankakuNet
//
//  Created by sota2 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAutoRotateViewController.h"

@class PNSplash;
@interface PNSplashView : NSObject<PNAutoRotateViewControllerDelegate> {
	UIWindow* splashWindow;
	UIWindow* mainWindow;
	UIButton* imageButton;
	UIButton* dismissButton;
	UIImageView* backgroundView;
	UIButton* adImageView;
	BOOL loading;
	UIActivityIndicatorView* indicator;
	PNSplash* splash;
	UIInterfaceOrientation currentOrientation;
	PNAutoRotateViewController* autoRotateViewController;
	BOOL autoRotateEnabled;
}
@property (nonatomic, assign) BOOL autoRotateEnabled;
+ (PNSplashView*)showSplash:(PNSplash*)splashToShow orientation:(UIInterfaceOrientation)orientation;
@end
