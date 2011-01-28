@class PNRootViewController;
@class PNNavigationController;
@class PNError;
@class PNAchievement;
@class PNModalIndicatorWindow;
@class PNPreview;
@class PNModalAlertView;
@class PNNativeRequest;

#import "PankiaNetworkLibrary.h"
#import "PNAutoRotateViewController.h"

typedef enum {
	DS_NONE,				//まだ一度も開かれていない状態
	DS_OPEN_ANIMATION,		//開くアニメーション中
	DS_OPENED,				//開いている状態
	DS_CLOSE_ANIMATION,		//閉じるアニメーション中
	DS_CLOSED				//閉じている状態
}DashboardState;

@interface PNDashboard : NSObject <PNAutoRotateViewControllerDelegate> {
	id                      delegate;
	DashboardState state;
	PNRootViewController*	rootViewController;
	UIInterfaceOrientation	dashboardOrientation;
	BOOL					isAvailable;
	BOOL					isAvailableNatType;	//注意：この変数は「警告がでた後」に値がセットされます。メインメニューとレフトメニュー以外では使用してはいけません。
	NSString*				appTitle;
	UIWindow*				pankiaWindow;
	UIWindow*				mainWindow;
	PNModalIndicatorWindow *modalIndicator;
	PNPreview* preview;
	PNModalAlertView* alertView;
	
#ifdef DEBUG
	UILabel* lblIndicator;
	UILabel* lblRttIndicator;
#endif
}
@property (retain)	id                          delegate;
@property (readonly) DashboardState state;
@property (retain)	PNRootViewController*		rootViewController;
@property			UIInterfaceOrientation		dashboardOrientation;
@property			BOOL						isAvailableNatType;
@property (retain)	NSString*					appTitle;
@property (nonatomic, retain) UIWindow*				pankiaWindow;
@property (readonly) UIWindow*				mainWindow;
@property (nonatomic, retain) PNModalIndicatorWindow* modalIndicator;
@property (nonatomic, retain) PNPreview* preview;
@property (nonatomic, retain) PNModalAlertView* alertView;
@property (assign) BOOL isAvailable;
+ (PNDashboard *)sharedObject;

+ (UIWindow*)getTopApplicationWindow;
+ (UIView*)getTopApplicationView;
+ (PNNavigationController*)getWrappedNavigationController;
+ (UIViewController*)getRootController;
+ (void)setViewId:(NSInteger)viewId;
+ (void)showImage:(NSString*)imageUrl;

- (BOOL)isLandscapeMode;
- (BOOL)isIPad;

- (void)showRootControllerWithModal:(UIViewController*)modal;
- (void)showRootControllerWithDashboardPushControllers:(NSArray*)pushControllers;
- (void)launchWithPushControllerName:(const NSString*)pushControllerName;
- (void)launchWithPushControllers:(NSArray*)controllers;
- (void)launchWithController:(UIViewController*)controller;
- (void)dismiss;
- (BOOL)isDismissed;
- (void)updateUser:(PNUser *)user;

- (void)showInternetMatchTopPage;
- (void)showNearbyMatchTopPage;

/* rootViewController表示アニメーションのコールバック */
- (void)rootViewAppeared;
- (void)rootViewDisappeared;

// for user register
+ (void)showRegistrationViewPushControllers:(NSArray*)pushControllers isLaunchDashboard:(BOOL)isLaunchDashboard;
+ (void)showRegistrationViewWithLaunchDashboardPushControllers:(NSArray*)pushControllers;
+ (void)hideRegistrationView;
+ (void)hideRegistrationViewWithLaunchDashboardPushControllers:(NSArray*)pushControllers;

//update
+ (void)updateDashboard;

//show View
+ (void)pushViewControllerNamed:(NSString*)controllerName;
+ (void)pushViewController:(UIViewController*)controller;
+ (void)popViewController;
+ (void)showErrorView:(UIViewController*)controller withErrorMessage:(NSString*)errorMessage;
+ (void)showErrorView:(UIViewController*)controller withError:(PNError*)error;
+ (void)showInformationView:(UIViewController*)controller withInformationMessage:(NSString*)informationMessage;

//indicator
+ (void)showIndicator;
+ (void)showLargeIndicator;
+ (void)hideIndicator;
+ (void)updateIndicatorDescription:(NSString*)text;
+ (BOOL)isIndicatorAnimating;
+ (void)showModalIndicator;
+ (void)hideModalIndicator;

//button
+ (void)resetAllButtons;
+ (void)disableAllButtons;

//notify
- (void)flushNotifications;
- (void)showLoginedNotification;
- (void)showAchievementNotice:(PNAchievement*)achievement;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
			 urlToJump:(NSString*)urlToJump;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
		smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString;

//Autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// Alert
- (void)showAlertWithTitle:(NSString*)title description:(NSString*)description 
		okButtonTitle:(NSString*)okButtonTitle delegate:(id)delegate;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate timerCount:(int)timerCount;

#ifdef DEBUG
#ifdef NETWORK_DEBUG
- (void)updateDebugLabelText:(NSString*)text;
- (void)updateRttDebugLabelText:(NSString*)text;
#endif
#endif

- (void)onOKSelected;

- (NSString*)localFilePathForRequest:(PNNativeRequest*)request;
- (NSString*)localHTMLStringForRequest:(PNNativeRequest*)request;
- (NSString*)localPathForJavaScriptNamed:(NSString*)name;
- (NSString*)localPathForCSSNamed:(NSString*)name;
- (NSString*)localPathForImageNamed:(NSString*)name;
@end
