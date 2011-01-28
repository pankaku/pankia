//
//  PNModalAlertView.h
//  PankakuNet
//
//  Created by sota2 on 10/09/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNDefaultButton;
@class PNDeprecatedButton;
@class PNLocalizableLabel;
@class PNAutoRotateViewController;
@interface PNModalAlertView : UIView {
	UIWindow* alertWindow;
	UIWindow* mainWindow;
	PNAutoRotateViewController* autoRotateViewController;
	UIImageView* background;
	PNLocalizableLabel *titleLabel;
	PNLocalizableLabel *messageLabel;
	PNLocalizableLabel *timerLabel;
	PNDefaultButton* defaultButton;
	PNDeprecatedButton* cancelButton;
	int selectedIndex;
	NSArray* animationElements;
	id delegate;
	NSString *onOKSelectorName;
	NSString *onCancelSelectorName;
	
	UIImageView* timerInnerImage;
	UIImageView* timerOuterImage;
	
	BOOL timerEnabled;
	BOOL isActive;
	
	NSTimer* countDownTimer;
	int timeRemaining;
}
@property (assign) BOOL isActive;
- (void)showWithTitle:(NSString*)title message:(NSString*)message 
		okButtonTitle:(NSString*)okButtonTitle delegate:(id)aDelegate;
- (void)showWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate;
- (void)showWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate withTimerCount:(int)timerCount;
@end
