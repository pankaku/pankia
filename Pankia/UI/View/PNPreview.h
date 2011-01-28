//
//  PNPreview.h
//  PankakuNet
//
//  Created by あんのたん on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAutoRotateViewController.h"

@interface PNPreview : NSObject {
	UIWindow* previewWindow;
	UIWindow* mainWindow;
	UIButton* imageButton;
	PNAutoRotateViewController* autoRotateViewController;
	BOOL loading;
	UIActivityIndicatorView* indicator;
}
- (void)showWithImage:(UIImage *)aImage;
- (void)loadImageFromUrl:(NSString*)url;
- (void)hide;

@end
