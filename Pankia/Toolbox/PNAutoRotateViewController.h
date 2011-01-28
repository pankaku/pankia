//
//  PNAlertViewController.h
//  PankakuNet
//
//  Created by あんのたん on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PNAutoRotateViewControllerDelegate
@optional
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
@end
@interface PNAutoRotateViewController : UIViewController {
	id <PNAutoRotateViewControllerDelegate> rotationDelegate;
}
@property (nonatomic, assign) id <PNAutoRotateViewControllerDelegate> rotationDelegate;
@end
