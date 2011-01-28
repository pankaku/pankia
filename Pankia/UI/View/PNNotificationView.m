#import "PNNotificationView.h"
#import "PNDashboard.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNNotificationService.h"
#import <QuartzCore/QuartzCore.h>
#import "PNGlobal.h"
#import "PNAutoRotateViewController.h"

#define kPNNotificationViewPortraitWidth  320.0f
#define kPNNotificationViewLandscapeWidth 480.0f

@implementation PNNotificationView
@synthesize appearTime;
- (void)awakeFromNib
{
	[super awakeFromNib];
	self.appearTime = kPNNotificationViewDefaultAppearTime;
	
	//現在のデバイスの向きにあわせて回転させます。
	//AutoRotateを使用するように変更。
//	UIInterfaceOrientation orientation = [PNDashboard sharedObject].dashboardOrientation;
//	if (orientation == UIInterfaceOrientationLandscapeRight) {
//		self.frame = CGRectMake(0,0,PNNotificationViewWidth,60);
//		self.transform = CGAffineTransformMakeRotation(M_PI/2);	
//		self.layer.position = CGPointMake(screenRect.size.width - self.bounds.size.height/2 , self.bounds.size.width/2 + (screenRect.size.height - PNNotificationViewWidth) / 2);			
//	}
//	else if (orientation == UIInterfaceOrientationLandscapeLeft){
//		self.frame = CGRectMake(screenRect.size.width - (PNNotificationViewWidth / 2),0,PNNotificationViewWidth,60);
//		self.transform = CGAffineTransformMakeRotation(-M_PI/2);	
//		self.layer.position = CGPointMake(self.bounds.size.height/2 , self.bounds.size.width/2);					
//	}
	
}

- (CGPoint)offScreenPosition:(CGPoint)onScreenPosition
{
//	CGSize notificationSize = self.bounds.size;
//	UIInterfaceOrientation orientation = [PNDashboard sharedObject].dashboardOrientation;
//	float offScreenOffsetX = 0.f;
//	float offScreenOffsetY = 0.f;
//	switch (orientation)
//	{
//		case UIInterfaceOrientationLandscapeRight:		offScreenOffsetX = notificationSize.height;	break;
//		case UIInterfaceOrientationLandscapeLeft:		offScreenOffsetX = -notificationSize.height;		break;
//		case UIInterfaceOrientationPortraitUpsideDown:	offScreenOffsetY = notificationSize.height;	break;
//		case UIInterfaceOrientationPortrait:			offScreenOffsetY = -notificationSize.height;		break;
//	}
	
	CGRect screenRect = [UIScreen mainScreen].bounds;

	if (![[PNDashboard sharedObject] isLandscapeMode]) {
		return CGPointMake((screenRect.size.width - kPNNotificationViewPortraitWidth) / 2, -1 * 60);
	}
	
	return CGPointMake((screenRect.size.height - kPNNotificationViewLandscapeWidth) / 2, -1 * 60);
}
//TODO　余分な実装を消す。関数名、引数名がわかりにくいので調整。機能的にはOK。

- (void)animateKeypath:(NSString*)keyPath 
			 fromValue:(float)startValue 
			   toValue:(float)endValue 
			  overTime:(float)duration 
	 animationDelegate:(UIView*)animDelegate 
	removeOnCompletion:(BOOL)removeOnCompletion 
			  fillMode:(NSString*)fillMode
{
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:keyPath];
	animation.fromValue = [NSNumber numberWithFloat:startValue];
	animation.toValue = [NSNumber numberWithFloat:endValue];
	animation.duration = duration;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.delegate = animDelegate;
	animation.removedOnCompletion = removeOnCompletion;
	animation.fillMode = fillMode;
	[[self layer] addAnimation:animation forKey:keyPath];
}
- (void)animateFromPosition:(CGPoint)startPos 
				 toPosition:(CGPoint)endPos 
				   overTime:(float)duration 
		  animationDelegate:(UIView*)animDelegate 
		 removeOnCompletion:(BOOL)removeOnCompletion 
				   fillMode:(NSString*)fillMode
{
	if (startPos.x != endPos.x)
	{
		[self animateKeypath:@"position.x" 
				   fromValue:startPos.x 
					 toValue:endPos.x
					overTime:duration 
		   animationDelegate:animDelegate 
		  removeOnCompletion:removeOnCompletion 
					fillMode:fillMode];
	}
	if (startPos.y != endPos.y)
	{
		[self animateKeypath:@"position.y" 
				   fromValue:startPos.y
					 toValue:endPos.y 
					overTime:duration 
		   animationDelegate:animDelegate 
		  removeOnCompletion:removeOnCompletion 
					fillMode:fillMode];
	}
}
- (void)animationDidStop:(CABasicAnimation *)theAnimation finished:(BOOL)flag
{
	[[self layer] removeAnimationForKey:[theAnimation keyPath]];
	[self removeFromSuperview];
}
- (void)dismiss
{
	CGPoint onScreenPosition = self.frame.origin;//CGPointMake(60.0f, 0.0f);//self.layer.position;
	
	[self animateFromPosition:onScreenPosition
				   toPosition:[self offScreenPosition:onScreenPosition]
					 overTime:0.35f
			animationDelegate:self
		   removeOnCompletion:NO
					 fillMode:kCAFillModeForwards];
	
	[self performSelector:@selector(hideWindow:) withObject:notificationWindow afterDelay:0.35f];	
}

- (void)hideWindow:(UIWindow *)aWindow {
	aWindow.hidden = YES;
	if (aWindow == notificationWindow) {
		notificationWindow = nil;
	}
	[aWindow release];
	
	//待機中のNortificationがあれば表示させます。
	[[PNNotificationService sharedObject] showNextNotice];
}

- (void)show{
	//UIView *topView = [PNDashboard getTopApplicationWindow];
	
	CGRect screenRect = [UIScreen mainScreen].bounds;
	notificationWindow = [[UIWindow alloc] init];
	notificationWindow.backgroundColor = [UIColor redColor];
	notificationWindow.userInteractionEnabled = NO;
	notificationWindow.windowLevel = UIWindowLevelAlert;
	PNAutoRotateViewController *alertViewController = [[PNAutoRotateViewController alloc] init];
	alertViewController.rotationDelegate = [PNDashboard sharedObject];
	int screenHeight = screenRect.size.height;
	if (![[PNDashboard sharedObject] isLandscapeMode]) {
		screenHeight = screenRect.size.width;
	}
	
	
	if (![[PNDashboard sharedObject] isLandscapeMode]) {
		self.frame = CGRectMake((screenHeight - kPNNotificationViewPortraitWidth) / 2, 0, kPNNotificationViewPortraitWidth, 60);
	}
	else {
		self.frame = CGRectMake((screenHeight - kPNNotificationViewLandscapeWidth) / 2, 0, kPNNotificationViewLandscapeWidth, 60);
	}
	
	UIView *topView = alertViewController.view;
	[notificationWindow addSubview:topView];
	UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
	[notificationWindow makeKeyAndVisible];
	[keyWindow makeKeyWindow];
	if (topView){
		CGPoint onScreenPosition = self.frame.origin;
		[self animateFromPosition:[self offScreenPosition:onScreenPosition]
					   toPosition:onScreenPosition
						 overTime:0.25f
				animationDelegate:nil
			   removeOnCompletion:YES
						 fillMode:kCAFillModeRemoved];
		[topView addSubview:self];
		
		//指定時間(appearTime)後に消します
		[self performSelector:@selector(dismiss) withObject:nil afterDelay:appearTime];
	}
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
	[notificationWindow release];
    [super dealloc];
}


@end
