//
//  PNModalIndicatorWindow.h
//  PankakuNet
//
//  Created by あんのたん on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNIndicator.h"

@interface PNModalIndicatorWindow : UIWindow {
	UIWindow* mainWindow;
	UIActivityIndicatorView* indicator;
	BOOL isActive;
}
@property (assign) BOOL isActive;
- (void)show;
- (void)hide;

@end
