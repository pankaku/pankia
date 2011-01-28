//
//  PNModalAlertView.m
//  PankakuNet
//
//  Created by sota2 on 10/09/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNModalAlertView.h"
#import "PNAutoRotateViewController.h"
#import "UIView+Slide.h"
#import "PNLocalizableLabel.h"
#import "PNDefaultButton.h"
#import "PNDeprecatedButton.h"
#import "PNDashboard.h"

#define kPNBackgroundImage     @"PNAlartBackgroundImage.png"
#define kPNNegativeButtonImage @"PNNegativeButton.png"

@interface PNModalAlertView ()
@property (nonatomic, retain) PNAutoRotateViewController* autoRotateViewController;
@property (nonatomic, retain) UIWindow* alertWindow;
@property (nonatomic, retain) UIWindow* mainWindow;
@property (nonatomic, retain) NSArray* animationElements;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSString* onOKSelectorName;
@property (nonatomic, retain) NSString* onCancelSelectorName;
@end

@interface PNModalAlertView (Private)
- (void)onCancelButtonSelected;
@end

@implementation PNModalAlertView
@synthesize autoRotateViewController;
@synthesize alertWindow, mainWindow;
@synthesize animationElements;
@synthesize onOKSelectorName, onCancelSelectorName;
@synthesize delegate;
@synthesize isActive;

- (void)setupBackgroundAndLabels
{
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	// -----
	BOOL isLandscape = [[PNDashboard sharedObject] isLandscapeMode];
	float windowWidth = isLandscape ? screenBounds.size.height : screenBounds.size.width;
	float windowHeight = isLandscape ? screenBounds.size.width : screenBounds.size.height;
	self.autoRotateViewController = [[[PNAutoRotateViewController alloc] init] autorelease];
	autoRotateViewController.rotationDelegate = [PNDashboard sharedObject];
	autoRotateViewController.view.frame = screenBounds;
	[autoRotateViewController.view setWidth:windowWidth height:windowHeight];
	autoRotateViewController.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
	
	self.alertWindow = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
	alertWindow.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
	[alertWindow addSubview:autoRotateViewController.view];
	
	
	
	background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNBackgroundImage]] autorelease];
	[autoRotateViewController.view addSubview:background];
	[background moveToX:(windowWidth - background.bounds.size.width) / 2.0f 
					  y:(windowHeight - background.bounds.size.height) / 2.0f];
	
	titleLabel = [[[PNLocalizableLabel alloc] init] autorelease];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.fontSize = 18.0f;
	titleLabel.textColor = [UIColor colorWithRed:0.6f green:1.0f blue:1.0f alpha:1.0f];
	[autoRotateViewController.view addSubview:titleLabel];
	[titleLabel moveToX:background.frame.origin.x + 20.0f y:background.frame.origin.y + 20.0f];
	[titleLabel setWidth:background.frame.size.width - 40.0f height:20.0f];
	
	messageLabel = [[[PNLocalizableLabel alloc] init] autorelease];
	messageLabel.numberOfLines = 4;
	messageLabel.fontSize = 12.0f;
	messageLabel.textAlignment = UITextAlignmentCenter;
	[messageLabel moveToX:titleLabel.frame.origin.x - 10.0f y:titleLabel.frame.origin.y + 20.0f];
	[messageLabel setWidth:titleLabel.frame.size.width + 20.0f height:60.0f];
	[autoRotateViewController.view addSubview:messageLabel];
}

- (void)setupTimerImages
{
	timerInnerImage = [[[UIImageView	alloc]
				  initWithFrame:CGRectMake(background.frame.origin.x + background.frame.size.width -40.0f, background.frame.origin.y - 20.0f,
										   60.0f, 60.0f)] autorelease];
	
	NSArray *imgArray = [[[NSArray alloc] initWithObjects:
						  [UIImage imageNamed:@"PNTimerInnerCircle1.png"],
						  [UIImage imageNamed:@"PNTimerInnerCircle2.png"],
						  [UIImage imageNamed:@"PNTimerInnerCircle3.png"],
						  [UIImage imageNamed:@"PNTimerInnerCircle4.png"],
						  nil] autorelease];
    timerInnerImage.animationImages = imgArray;
    timerInnerImage.animationDuration = 1.0f;
	[autoRotateViewController.view addSubview:timerInnerImage];
	
	timerOuterImage = [[[UIImageView	alloc]
						initWithFrame:CGRectMake(background.frame.origin.x + background.frame.size.width -40.0f, background.frame.origin.y - 20.0f,
												 60.0f, 60.0f)] autorelease];
	[autoRotateViewController.view addSubview:timerOuterImage];
	
	timerLabel = [[[PNLocalizableLabel alloc] init] autorelease];
	timerLabel.frame = timerOuterImage.frame;
	timerLabel.textAlignment = UITextAlignmentCenter;
	[autoRotateViewController.view addSubview:timerLabel];
}
- (id)init 
{
	if (self = [super init]) {
		[self setupBackgroundAndLabels];
		[self setupTimerImages];
		
		defaultButton = [PNDefaultButton button];
		[defaultButton addTarget:self action:@selector(onDefaultButtonSelected) forControlEvents:UIControlEventTouchUpInside];
		[autoRotateViewController.view addSubview:defaultButton];
		
		cancelButton = [PNDefaultButton button];
		[cancelButton addTarget:self action:@selector(onCancelButtonSelected) forControlEvents:UIControlEventTouchUpInside];
		[cancelButton setBackgroundImage:[[UIImage imageNamed:kPNNegativeButtonImage] stretchableImageWithLeftCapWidth:18 topCapHeight:18] forState:UIControlStateNormal];
		[autoRotateViewController.view addSubview:cancelButton];
		
		self.animationElements = [NSArray arrayWithObjects:alertWindow, background, titleLabel, messageLabel, 
								  defaultButton, cancelButton, timerInnerImage, timerOuterImage, timerLabel, nil];
	}
	return self;
}

- (void)setTimerImage:(int)count
{
	[timerOuterImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PNTimerOuterCircle%d.png", count]]];
	timerLabel.text = [NSString stringWithFormat:@"%d", count];
}

#pragma mark -
- (void)showWithTitle:(NSString*)title message:(NSString*)message 
		okButtonTitle:(NSString*)okButtonTitle delegate:(id)aDelegate
{
	[self showWithTitle:title message:message okButtonTitle:okButtonTitle onOKSelected:nil 
	  cancelButtonTitle:nil onCancelSelected:nil delegate:aDelegate];
}
- (void)appear
{
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		autoRotateViewController.view.transform = CGAffineTransformMakeRotation(90.0f / 180.0f * M_PI);
	} else {
		autoRotateViewController.view.transform = CGAffineTransformMakeRotation(0.0f / 180.0f * M_PI);
	}
	
	[UIView beginAnimations:@"PNShowAlertViewAnimation" context:nil];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDelegate:self];
	for (UIView* element in animationElements) {
		element.alpha = 1.0f;
	}
	
	float timerElementsAlpha = timerEnabled ? 1.0f : 0.0f;
	timerInnerImage.alpha = timerElementsAlpha;
	timerOuterImage.alpha = timerElementsAlpha;
	timerLabel.alpha = timerElementsAlpha;
	
	[UIView setAnimationDidStopSelector:@selector(showAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
	
	isActive = YES;
}
- (void)showAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (timerEnabled) {
		[timerInnerImage startAnimating];
		countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self 
														selector:@selector(updateCounter:) userInfo:nil repeats:YES];
	}
}

- (void)updateCounter:(NSTimer *)theTimer
{
	timeRemaining--;
	[self setTimerImage:timeRemaining];
	
	if (timeRemaining <= 0) {
		[self onCancelButtonSelected];
		return;
	}
}

- (void)showWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate
{
	[self showWithTitle:title message:message okButtonTitle:okButtonTitle onOKSelected:onOKSelector 
	  cancelButtonTitle:cancelButtonTitle onCancelSelected:onCancelSelector delegate:aDelegate withTimerCount:0];
}
- (void)showWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate withTimerCount:(int)timerCount
{
	// 現在のウィンドウを保持しておきます
	self.mainWindow = [[UIApplication sharedApplication] keyWindow];
	
	self.delegate = aDelegate;
	if (onOKSelector != nil) self.onOKSelectorName = NSStringFromSelector(onOKSelector);
	if (onCancelSelector != nil) self.onCancelSelectorName = NSStringFromSelector(onCancelSelector);
	
	// アラートウィンドウをキーウィンドウにします
	[alertWindow makeKeyAndVisible];
	for (UIView* element in animationElements) {
		element.alpha = 0.0f;
	}
	
	titleLabel.text = title;
	messageLabel.text = message;
	[defaultButton setTitle:okButtonTitle];
	[cancelButton setTitle:cancelButtonTitle];
	[self setTimerImage:timerCount];
	
	float buttonY = messageLabel.frame.origin.y + 70.0f;
	float buttonWidth = background.frame.size.width * 0.5f - 20.0f;
	[defaultButton moveToX:background.frame.origin.x + background.frame.size.width * 0.5f + 0.0f y:buttonY];
	[defaultButton setWidth:buttonWidth height:30.0f];
	[cancelButton moveToX:background.frame.origin.x + 20.0f y:buttonY];
	[cancelButton setWidth:buttonWidth height:30.0f];
    
    if (cancelButtonTitle == nil || [cancelButtonTitle length] == 0) {
        cancelButton.hidden = YES;
        [defaultButton moveToX:cancelButton.frame.origin.x y:cancelButton.frame.origin.y];
        [defaultButton setWidth:buttonWidth * 2.0f height:30.0f];
    } else {
        cancelButton.hidden = NO;
    }
	
	if (timerCount > 0) {
		timerEnabled = YES;
		timeRemaining = timerCount;
	} else {
        timerEnabled = NO;
        timeRemaining = UINT_MAX;
    }
	
	[self appear];
}
- (void)hide
{
	if (timerEnabled) {
		[countDownTimer invalidate];
		[timerInnerImage stopAnimating];
	}

	[UIView beginAnimations:@"PNHideAlertViewAnimation" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	for (UIView* element in animationElements) {
		element.alpha = 0.0f;
	}
	[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[mainWindow makeKeyWindow];
	self.mainWindow = nil;
	
	if (self.delegate != nil) {
		NSString* selectorNameToCall = selectedIndex == 0 ? onCancelSelectorName : onOKSelectorName;
		if (selectorNameToCall != nil) {
			SEL selectorToCall = NSSelectorFromString(selectorNameToCall);
			if ([self.delegate respondsToSelector:selectorToCall]) {
				[self.delegate performSelector:selectorToCall withObject:nil afterDelay:0.1f];
			}
		}
	}
	
	self.delegate = nil;
	self.onOKSelectorName = nil;
	self.onCancelSelectorName = nil;
	isActive = NO;
}
- (void)onDefaultButtonSelected
{
	selectedIndex = 1;
	[self hide];
}
- (void)onCancelButtonSelected
{
	selectedIndex = 0;
	[self hide];
}



- (void)dealloc {
	self.autoRotateViewController = nil;
	self.alertWindow              = nil;
	self.mainWindow               = nil;
	self.animationElements        = nil;
    [super dealloc];
}


@end
