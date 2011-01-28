#import <QuartzCore/QuartzCore.h>	// For CoreAnimation
#import "ZipArchive.h"

#import "PankiaNetworkLibrary+Package.h"
#import "PNDashboard.h"
#import "PNRootNavigationController.h"
#import "PNControllerLoader.h"
#import "PNJoinedRoomViewController.h"
#import "PNRegistrationViewController.h"
#import "PNErrorViewController.h"
 
#import "PNInformationViewController.h"
#import "PNNotificationService.h"
#import "PNRootViewController.h"
#import "PankiaNet+Package.h"
#import "PNGlobal.h"
#import "PNLobbyViewController.h"
#import "PNModalIndicatorWindow.h"
#import "PNPreview.h"
#import "PNModalAlertView.h"
#import "PNWebViewController.h"
#import "PNNotificationNames.h"
#import "PNNativeRequest.h"
#import "PNLocalResourceUtil.h"

#import "PNGlobal.h"

#define kPNDashboardDefaultUIResourcesBaseDirectoryPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/pankia/dashboard/default/resources"]
#define kPNDashboardDefaultUIResourceArchiveFileName @"pn_default_ui_theme"
#define kPNDashboardDefaultUIResourceArchiveFilePath [[NSBundle mainBundle] pathForResource:kPNDashboardDefaultUIResourceArchiveFileName ofType:@"zip"]
#define kPNDashboardDefaultUICopiedVersionDateTime @"PNDashboardDefaultUICopiedVersionDateTime"

static PNDashboard *_sharedInstance;
extern PNRoom* reMatchRoom;

@interface PNDashboard(Private)
- (void)setState:(DashboardState)_state;
#ifdef DEBUG
- (void)showNetworkDebugIndicator;
- (NSTimeInterval)currentDefaultUIResourceArchiveFileDateTime;
#endif
@end

@implementation PNDashboard
@synthesize delegate, isAvailable;
@synthesize state, rootViewController, dashboardOrientation;
@synthesize isAvailableNatType,appTitle;
@synthesize pankiaWindow, mainWindow;
@synthesize modalIndicator, preview, alertView;

- (BOOL)isLandscapeMode
{
	PNLogMethodName;
	return (dashboardOrientation == UIInterfaceOrientationLandscapeLeft || dashboardOrientation == UIInterfaceOrientationLandscapeRight);
}
- (BOOL)isIPad
{
	PNLogMethodName;
	if (![[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
		return NO;
	}
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		return YES;
	}
	
	return NO;
	
//	CGRect screenRect = [UIScreen mainScreen].bounds;
//	return screenRect.size.width != 320 || screenRect.size.height != 480;
}
- (void)showRootControllerWithModal:(UIViewController*)modal
{
	PNLogMethodName;
	self.state = DS_OPEN_ANIMATION;
	
	//現在のOrientationを使用して再生成
	self.rootViewController = [[[PNRootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	
	self.pankiaWindow = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
	pankiaWindow.backgroundColor = [UIColor clearColor];
	[pankiaWindow addSubview:self.rootViewController.view];
	
	rootViewController.showTransition = kCATransitionFromTop;
	rootViewController.hideTransition = kCATransitionFromBottom;
	
	//PankiaWindowを表示する
	mainWindow = [UIApplication sharedApplication].keyWindow;

	pankiaWindow.hidden = NO;
	[pankiaWindow makeKeyAndVisible];
	
	//rootViewControllerを開く
	[rootViewController showController:modal]; // callback rootViewAppeared
	[rootViewController viewWillAppear:YES];
	rootViewController.view.hidden = NO;
}

- (void)rootViewAppeared {
	PNLogMethodName;
	[self setState:DS_OPENED];
}

//push controllers into tabController. and show tabbed dashboard. 
//引数で渡されたpushControllerをすべてプッシュしてshowRootControllerWithModalを呼ぶ。
- (void)showRootControllerWithDashboardPushControllers:(NSArray*)pushControllers
{	
	PNLogMethodName;
	if (!rootViewController.contentController) {
		PNCLog(PNLOG_CAT_UI, @"contentController is nil");
		
		//ゲームウィンドウには絶対に追加しないようにする。 @ iPad対応
		
		//UIWindow *topView = [PNDashboard getTopApplicationWindow];
		
		//[pankiaWindow addSubview:rootViewController.view];
	}
	
	PNRootNavigationController* rootNavController =
	[[[PNRootNavigationController alloc] initWithNibName:nil
												  bundle:nil] autorelease];
	//pushController配列があった場合は、その中に格納されているコントローラごとに処理を行う。
	for (NSObject* obj in pushControllers) {
		UIViewController* controller = nil;
		
		if ([obj isKindOfClass:[NSString class]]) {
			//まだなにもコントローラがプッシュされていなければ、controllerに登録する。
			if (!controller) { 
				NSString* controllerName = (NSString*)obj;
				controller = (UIViewController*)[PNControllerLoader load:controllerName filesOwner:nil];
			}
		}
		 //UIViewControllerならばそのままいける。
		else if ([obj isKindOfClass:[UIViewController class]]) {
			controller = (UIViewController*)obj;
		}
		else {
			return;
		}
		
		//reMatch用のroomを登録する。
		if (reMatchRoom && [controller isKindOfClass:[PNJoinedRoomViewController class]]) {
			PNRoom* room = reMatchRoom;
			PNJoinedRoomViewController* joinedController = (PNJoinedRoomViewController*)controller;
			room.delegate = joinedController;
			joinedController.myRoom = room;
		}
		[rootNavController pushViewController:controller
									 animated:NO];
	}	
	[self showRootControllerWithModal:rootNavController];
}

//１つのUIViewControllerをプッシュしたいときに使う。
- (void)launchWithPushControllerName:(NSString*)pushControllerName
{
	PNLogMethodName;
	//文字列のcontrollerから、配列を生成。
	NSArray* pushControllers = [[[NSArray alloc] initWithObjects:pushControllerName,nil] autorelease];
	
	//生成した配列を渡す。
	[self launchWithPushControllers:pushControllers];
	
}
- (void)launchWithController:(UIViewController*)controller
{
	PNLogMethodName;
	NSArray* pushControllers = [[[NSArray alloc] initWithObjects:controller,nil] autorelease];
	
	//生成した配列を渡す。
	[self launchWithPushControllers:pushControllers];
}

//２つ以上のUIViewControllerをプッシュしたい時に使う。
//NSArrayを渡すことでその順番でプッシュされる。
//内部的には、showRootControllerWithTabbedDashboardでプッシュされる仕組み。
- (void)launchWithPushControllers:(NSArray*)controllers
{
	PNLogMethodName;
	//既にダッシュボードを開いているときは開きません
    if (self.state == DS_OPENED) return;
	
	[UIApplication sharedApplication].statusBarHidden = YES;
	
	BOOL shouldShowRegistrationView = YES;
	id<PankiaNetDelegate> pankiaNetDelegate = [PankiaNet sharedObject].pankiaNetDelegate;
	if (pankiaNetDelegate != nil && [pankiaNetDelegate respondsToSelector:@selector(shouldShowRegistrationView)]){
		shouldShowRegistrationView = [pankiaNetDelegate shouldShowRegistrationView];
	}
	
	if ([PNUser currentUser].isGuest == YES && shouldShowRegistrationView == YES && [PNManager sharedObject].isLoggedIn == YES)
		//ゲストアカウントで、かつ、まだ登録画面を表示しておらず、かつ、ログインしている状態なら、登録画面を出す。
	{
		[PNDashboard showRegistrationViewWithLaunchDashboardPushControllers:controllers];
	}
	else //if user have registerd.
	{
        
        
		if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(dashboardWillAppear)]) {
			[[PankiaNet sharedObject].pankiaNetDelegate dashboardWillAppear];
		}	
		
		[self showRootControllerWithDashboardPushControllers:controllers];
		
		if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(dashboardDidAppear)]) {
			[[PankiaNet sharedObject].pankiaNetDelegate dashboardDidAppear];
		}
	}
	
#ifdef DEBUG
#ifdef NETWORK_DEBUG
	//デバッグ中にネットワークの状態を表示させるためのラベルを追加します。
	[[PNDashboard sharedObject] showNetworkDebugIndicator];
#endif
#endif
	
}

- (void)updateUser:(PNUser*)user
{
	PNLogMethodName;
	if ([delegate respondsToSelector:@selector(didUpdateUser:)]) {
		[delegate didUpdateUser:user];
	}
}

- (void)showInternetMatchTopPage
{
	PNLogMethodName;
	if ([[PNSettingManager sharedObject] boolValueForKey:@"LobbyEnabled"] == YES) {
		NSLog(@"++++++++");
		
		PNLobbyViewController* controller = (PNLobbyViewController*)[PNControllerLoader load:@"PNLobbyViewController" filesOwner:nil];
		controller.matchType = kPNInternetMatch;
		controller.title = getTextFromTable(@"PNTEXT:UI:Internet_Match");
		[PNDashboard pushViewController:controller];
	} else {
		NSLog(@"########");
		[PNDashboard pushViewControllerNamed:@"PNMatchUpViewController"];
	}

}
- (void)showNearbyMatchTopPage
{
	PNLogMethodName;
	if ([[PNSettingManager sharedObject] boolValueForKey:@"LobbyEnabled"] == YES) {
		PNLobbyViewController* controller = (PNLobbyViewController*)[PNControllerLoader load:@"PNLobbyViewController" filesOwner:nil];
		controller.matchType = kPNNearbyMatch;
		controller.title = getTextFromTable(@"PNTEXT:UI:Nearby_Match");
		[PNDashboard pushViewController:controller];
	} else {
		[PNDashboard pushViewControllerNamed:@"PNLocalMatchViewController"];
	}

}

+ (void)showRegistrationViewPushControllers:(NSArray*)pushControllers isLaunchDashboard:(BOOL)isLaunchDashboard
{	
	
#ifdef PNUsingExternalID
	return;
#endif
	
	PNLogMethodName;
	PNDashboard* dashboard = [PNDashboard sharedObject];
	if(dashboard.isDismissed){	
		UIWindow *topView = [PNDashboard sharedObject].pankiaWindow;						
		PNRegistrationViewController* targetController = (PNRegistrationViewController*)[PNControllerLoader load:@"PNRegistrationViewController" filesOwner:nil];		
		targetController.pushControllers = pushControllers;
		targetController.isLaunchDashboard = isLaunchDashboard;
		PNNavigationController* nav = [[[PNNavigationController alloc] initWithRootViewController:targetController] autorelease];
		[nav setNavigationBarHidden:YES animated:NO];
		[nav hideFooterAndLeftPane];
//		[nav loadIconWithUrl:[PNUser currentUser].iconURL];
		
		[topView addSubview:dashboard.rootViewController.view];
		
		[[PNDashboard sharedObject] showRootControllerWithModal:nav];	
	}
}

+ (void)showRegistrationViewWithLaunchDashboardPushControllers:(NSArray*)pushControllers
{
	PNLogMethodName;
	//for delegate
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(dashboardWillAppear)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate dashboardWillAppear];
	}	
	
	[PNDashboard showRegistrationViewPushControllers:pushControllers isLaunchDashboard:YES];
	
	//for delegate
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(dashboardDidAppear)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate dashboardDidAppear];
	}
}

+ (void)hideRegistrationView
{
	PNLogMethodName;
	[[PNDashboard sharedObject] dismiss];
}

+ (void)hideRegistrationViewWithLaunchDashboardPushControllers:(NSArray*)pushControllers
{
	PNLogMethodName;
	[[PNDashboard sharedObject] dismiss];
    
    [[PNDashboard sharedObject] performSelector:@selector(launchWithPushControllers:) withObject:pushControllers afterDelay:1.0f];
}

+ (void)updateDashboard
{
	PNLogMethodName;
	[(PNNavigationController*)[PNDashboard sharedObject].rootViewController.contentController update];
}

+ (void)showErrorView:(UIViewController*)controller withErrorMessage:(NSString*)errorMessage
{
	PNLogMethodName;
	if (controller) {
		PNErrorViewController* errorViewController = (PNErrorViewController*)[PNControllerLoader load:@"PNErrorViewController" filesOwner:nil];
		[errorViewController setErrorMessage:errorMessage];
		[PNDashboard pushViewController:errorViewController];
	}
}

+ (void)showErrorView:(UIViewController*)controller withError:(PNError*)error
{
	PNLogMethodName;
	
	if ([error.errorCode isEqualToString:@"unknown"]) {
		if (controller) {
			PNErrorViewController* errorViewController = (PNErrorViewController*)[PNControllerLoader load:@"PNErrorViewController" filesOwner:nil];
			[errorViewController setErrorMessage:getTextFromTable(@"PNTEXT:UI:SERVERERROR:unknown_message")];
			[PNDashboard pushViewController:errorViewController];
		}
	} else {
		NSString* title = [error errorTitle];
		NSString* message = [error errorMessage];
		
		if ([title isEqualToString:@""] == NSOrderedSame || [message isEqualToString:@""] == NSOrderedSame) {
			
			if (controller) {
				PNErrorViewController* errorViewController = (PNErrorViewController*)[PNControllerLoader load:@"PNErrorViewController" filesOwner:nil];
				[errorViewController setErrorMessage:getTextFromTable(@"PNTEXT:UI:SERVERERROR:unknown_message")];
				[PNDashboard pushViewController:errorViewController];
				return;
			}
		}	
		[[PNDashboard sharedObject] showAlertWithTitle:title
								message:message
						  okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
					  cancelButtonTitle:nil onCancelSelected:nil
							   delegate:self];
		
		[PNDashboard hideIndicator];
	}
}

- (void)onOKSelected{
	PNLogMethodName;
	
}


+ (void)showInformationView:(UIViewController*)controller withInformationMessage:(NSString*)informationMessage
{
	PNLogMethodName;
	if (controller) {
		PNInformationViewController* informationViewController = (PNInformationViewController*)[PNControllerLoader load:@"PNInformationViewController" filesOwner:nil];
		[informationViewController setInformationMessage:informationMessage];
		[PNDashboard pushViewController:informationViewController];
	}
}

+ (void)showIndicator{
	PNLogMethodName;
	[[PNDashboard getWrappedNavigationController] showIndicator];
}

+ (void)showLargeIndicator{
	PNLogMethodName;
	[[PNDashboard getWrappedNavigationController] showLargeIndicator];
}

+ (void)hideIndicator{
	PNLogMethodName;
	[[PNDashboard getWrappedNavigationController] hideIndicator];
}

+ (void)updateIndicatorDescription:(NSString*)text{
	PNLogMethodName;
	[[PNDashboard getWrappedNavigationController] updateIndicatorDescription:text];
}
+ (void)showModalIndicator {
	PNLogMethodName;
	if ([PNDashboard sharedObject].alertView.isActive) return;	// Don't show when alert view is active.
	[[PNDashboard sharedObject].modalIndicator show];
}
+ (void)hideModalIndicator {
	PNLogMethodName;
	[[PNDashboard sharedObject].modalIndicator hide];
}

- (void)flushNotifications{
	PNLogMethodName;
	[[PNNotificationService sharedObject] flushNotices];
}

- (void)showLoginedNotification {
	PNLogMethodName;
	
	//ゲストアカウントでなければログインした旨を通知します
#ifndef PNUsingExternalID
	[PNNotificationService showTextNotice:getTextFromTable(@"PNTEXT:LOGIN:Succeed.") 
							  description:[NSString stringWithFormat:getTextFromTable(@"PNTEXT:LOGIN:Welcome_user."),[PNUser currentUser].username]
								iconImage:[UIImage imageNamed:@"PNNotificationPankiaIcon.png"]];
#else
	PNCLog(PNLOG_CAT_UI, @"Show External Login Alert");
	[PNNotificationService showTextNotice:getTextFromTable(@"PNTEXT:LOGIN:Succeed.") 
							  description:[NSString stringWithFormat:getTextFromTable(@"PNTEXT:LOGIN:Welcome_user."),[PNUser currentUser].externalId]
								iconImage:[UIImage imageNamed:@"PNNotificationPankiaIcon.png"]];
#endif
}

- (void)showAchievementNotice:(PNAchievement*)achievement {
	PNLogMethodName;
	[[PNNotificationService sharedObject] showAchievementNotice:achievement];
}

+ (void)showTextNotice:(NSString*)title
		   description:(NSString*)description
			 iconImage:(UIImage*)iconImage
			 urlToJump:(NSString*)urlToJump
{
	PNLogMethodName;
	[PNNotificationService showTextNotice:title
							  description:description
								iconImage:iconImage
								urlToJump:urlToJump];
}

+ (void)showTextNotice:(NSString*)title
		   description:(NSString*)description
			 iconImage:(UIImage*)iconImage 
		smallIconImage:(UIImage*)smallIconImage
		   pointString:(NSString*)pointString
{
	PNLogMethodName;
	[PNNotificationService showTextNotice:title
							  description:description
								iconImage:iconImage
						   smallIconImage:smallIconImage
							  pointString:pointString];
}

// get top window
+ (UIWindow*)getTopApplicationWindow
{
	PNLogMethodName;
	
	//  変更：あくまでkeyWindowを取得するメソッドとして使用する。
	//	//mainWindowインスタンスが存在する場合、keyWindowがPankiaに切り替わっている可能性がある。
	//	if ([[PNDashboard sharedObject] mainWindow]) {
	//		return [[PNDashboard sharedObject] mainWindow];
	//	}
	
	UIApplication* app = [UIApplication sharedApplication];
	
	UIWindow* topView = [app keyWindow];
	if (!topView)
	{
		topView = [[app windows] objectAtIndex:0];
	}
	
	//TDDO:for unity
	//	topView.frame = CGRectMake(-80,80,480,320);
	//	topView.transform = CGAffineTransformMakeRotation(M_PI/2);
	
	return topView;
}

// get top UIView
+ (UIView*)getTopApplicationView
{
	PNLogMethodName;
	UIWindow *topWindow = [PNDashboard getTopApplicationWindow];
	
	if([topWindow.subviews count] > 0){
		return [topWindow.subviews objectAtIndex:0];
	}
	return (UIView*)topWindow;
}

+ (PNNavigationController*)getWrappedNavigationController
{
	PNLogMethodName;
	PNDashboard* dashboard = [PNDashboard sharedObject];
	UIViewController* viewController = dashboard.rootViewController.contentController;
	
	if([viewController isKindOfClass:[PNNavigationController class]])
	{
		return (PNNavigationController*)viewController;
	}
	else {
		return nil;
	}	
}

+ (UIViewController*)getRootController
{
	PNLogMethodName;
	PNDashboard* dashboard = [PNDashboard sharedObject];
	return dashboard ? dashboard.rootViewController : nil;
}

+ (void)disableAllButtons
{
	PNLogMethodName;
	[[PNDashboard getWrappedNavigationController] disableAllButtons];
}

// 指定した名前のビューコントローラのインスタンスを作ってプッシュします
+ (void)pushViewControllerNamed:(NSString*)controllerName
{
	PNLogMethodName;
	PNAssert([NSThread isMainThread], @"This method should be called from main thread.");
	[[PNDashboard getWrappedNavigationController] pushViewController:[PNControllerLoader load:controllerName filesOwner:nil] animated:YES];
}
+ (void)pushViewController:(UIViewController*)controller
{
	PNLogMethodName;
	PNAssert([NSThread isMainThread], @"This method should be called from main thread.");
	[[PNDashboard getWrappedNavigationController] pushViewController:controller animated:YES];
}

+ (void)popViewController
{
	PNLogMethodName;
	PNAssert([NSThread isMainThread], @"This method should be called from main thread.");
	[[PNDashboard getWrappedNavigationController] popViewControllerAnimated:YES];
}

+ (void)resetAllButtons
{
	PNLogMethodName;
	[[PNDashboard getWrappedNavigationController] resetAllButtons];
}

+ (BOOL)isIndicatorAnimating
{
	PNLogMethodName;
	return [[PNDashboard getWrappedNavigationController] isIndicatorAnimating];
}

- (void)dismiss {
	PNLogMethodName;
	PNCLog(PNLOG_CAT_UI, @"%s", __FUNCTION__);
	PNAssert([NSThread isMainThread], @"This method should be called from main thread.");
	[self setState:DS_CLOSE_ANIMATION];
	[self.rootViewController hideController]; // callback rootViewDisappeared
}

- (void)rootViewDisappeared {
	PNLogMethodName;
	[self setState:DS_CLOSED];
	//mainWindow.hidden = NO;
	
	PNCLog(PNLOG_CAT_UI, @"Return To Main Window.");
	
	PNCLog(PNLOG_CAT_UI, @"%s", __FUNCTION__);
	pankiaWindow.hidden = YES;
	[mainWindow makeKeyAndVisible];
//	PNSafeDelete(mainWindow);
}

- (void)setState:(DashboardState)_state {
	PNLogMethodName;
	@synchronized(self) {
		state = _state;
	}
}

- (BOOL)isDismissed {
	PNLogMethodName;
	BOOL ret;
	@synchronized(self) {
		ret = state == DS_CLOSE_ANIMATION || state == DS_CLOSED;
	}
	return ret;
}

/*!
 * ダッシュボードを回転させるかどうかを返します
 * ダッシュボードの回転にあわせてノーティフィケートも回転します。
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	PNLogMethodName;
	BOOL autorotateEnabled = [[PNSettingManager sharedObject] boolValueForKey:@"AutorotateEnabled"];
	BOOL disableRotationInIPhone = [[PNSettingManager sharedObject] boolValueForKey:@"DisableRotationInIPhone"];
	
	if (disableRotationInIPhone && ![[PNDashboard sharedObject] isIPad]){
		return (interfaceOrientation == self.dashboardOrientation);
	}
	
	if (![[PNDashboard sharedObject] isLandscapeMode]) {
		PNCLog(PNLOG_CAT_UI, @"Portrait Mode.");
		if (interfaceOrientation == UIInterfaceOrientationPortrait) {
			return YES;
		}
		
		if (autorotateEnabled && interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			return YES;
		}
		
	} else {
		if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			[PNDashboard sharedObject].dashboardOrientation = UIInterfaceOrientationLandscapeRight;
			return YES;
		}
		
		if (autorotateEnabled && interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
			[PNDashboard sharedObject].dashboardOrientation = UIInterfaceOrientationLandscapeLeft;
			return YES;
		}
	}
	
	return NO;
}

+ (void)showImage:(NSString*)imageUrl
{
	PNLogMethodName;
	[[PNDashboard sharedObject].preview showWithImage:nil];
	[[PNDashboard sharedObject].preview loadImageFromUrl:imageUrl];
}

- (void)showAlertWithTitle:(NSString*)title description:(NSString*)description 
		okButtonTitle:(NSString*)okButtonTitle delegate:(id)aDelegate
{
	PNLogMethodName;
	if (modalIndicator.isActive) [modalIndicator hide];	// Avoid collision between modal indicator and alert view
	[alertView showWithTitle:title message:description okButtonTitle:okButtonTitle delegate:aDelegate];
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate
{
	PNLogMethodName;
	if (modalIndicator.isActive) [modalIndicator hide];	// Avoid collision between modal indicator and alert view
	[alertView showWithTitle:title message:message okButtonTitle:okButtonTitle onOKSelected:onOKSelector
		   cancelButtonTitle:cancelButtonTitle onCancelSelected:onCancelSelector delegate:aDelegate];
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message 
		okButtonTitle:(NSString *)okButtonTitle onOKSelected:(SEL)onOKSelector
	cancelButtonTitle:(NSString *)cancelButtonTitle onCancelSelected:(SEL)onCancelSelector
			 delegate:(id)aDelegate timerCount:(int)timerCount
{
	PNLogMethodName;
	if (modalIndicator.isActive) [modalIndicator hide];	// Avoid collision between modal indicator and alert view
	[alertView showWithTitle:title message:message okButtonTitle:okButtonTitle onOKSelected:onOKSelector
		   cancelButtonTitle:cancelButtonTitle onCancelSelected:onCancelSelector delegate:aDelegate withTimerCount:timerCount];
}

#pragma mark -
#pragma mark Singleton pattern

- (void)connectionStateChanged:(NSNotification*)n
{
	[PNDashboard updateDashboard];
}

- (NSString*)htmlStringWithJavaScriptExpanded:(NSString*)original
{
	NSString* htmlString = [NSString stringWithString:original];
	NSString* jsImportPrefix = @"<script src=\"/javascripts/";
	
	NSMutableDictionary* availableScripts = [NSMutableDictionary dictionary];
	
	NSRange searchRange;
	searchRange.location = 1;
	searchRange.length = [htmlString length]-1;
	while (1) {
		NSRange foundRange = [htmlString rangeOfString:jsImportPrefix options:NSCaseInsensitiveSearch range:searchRange];
		
		if (foundRange.length == 0) {
			break;
		} else {
			
			// Find next double quot.
			NSRange range2;
			range2.location = foundRange.location + [jsImportPrefix length];
			range2.length = [htmlString length] - range2.location;
			
			NSRange rangeForEndOfScriptTag = [htmlString rangeOfString:@"</script>" options:NSCaseInsensitiveSearch range:range2];
			NSRange rangeForThisScriptTag;
			rangeForThisScriptTag.location = foundRange.location;
			rangeForThisScriptTag.length = (rangeForEndOfScriptTag.location - foundRange.location) + rangeForEndOfScriptTag.length;
			
			NSString* scriptTagForThisTag = [htmlString substringWithRange:rangeForThisScriptTag];
			
			NSRange nextQuotRange = [htmlString rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:range2];
			nextQuotRange.length = nextQuotRange.location - range2.location;
			nextQuotRange.location = range2.location;
			
			NSString* jsFileNameWithParams = [htmlString substringWithRange:nextQuotRange];
			NSString* jsFileName = [NSString stringWithString:jsFileNameWithParams];
			if ([[jsFileName componentsSeparatedByString:@"?"] count] >= 2) {
				jsFileName = [[jsFileName componentsSeparatedByString:@"?"] objectAtIndex:0];
			}
			
			NSString* localFileName = [[PNDashboard sharedObject] localPathForJavaScriptNamed:jsFileName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:localFileName]) {
				[availableScripts setObject:localFileName forKey:scriptTagForThisTag];
			}
			searchRange.location = foundRange.location + foundRange.length;
			searchRange.length = [htmlString length] - searchRange.location;
		}
	}
	for (NSString* originalFileName in [availableScripts allKeys]) {
		NSString* stringToFind = originalFileName;
		NSString* scriptData = [[[NSString alloc] initWithContentsOfFile:[availableScripts objectForKey:originalFileName]
																encoding:NSUTF8StringEncoding error:nil] autorelease];
		
		htmlString = [htmlString stringByReplacingOccurrencesOfString:stringToFind 
														   withString:[NSString stringWithFormat:@"<script src=\"%@\"></script>", [availableScripts objectForKey:originalFileName]]];
	}
	return htmlString;
}
- (NSString*)cssStringWithImageURLReplaced:(NSString*)original
{
	NSString* htmlString = [NSString stringWithString:original];
	NSString* cssImportPrefix = @"url(";
	
	NSMutableDictionary* availableScripts = [NSMutableDictionary dictionary];
	
	NSRange searchRange;
	searchRange.location = 1;
	searchRange.length = [htmlString length]-1;
	while (1) {
		NSRange foundRange = [htmlString rangeOfString:cssImportPrefix options:NSCaseInsensitiveSearch range:searchRange];
		
		if (foundRange.length == 0) {
			break;
		} else {
			
			// Find next double quot.
			NSRange range2;
			range2.location = foundRange.location + [cssImportPrefix length];
			range2.length = [htmlString length] - range2.location;
			
			NSRange rangeForEndOfScriptTag = [htmlString rangeOfString:@")" options:NSCaseInsensitiveSearch range:range2];
			NSRange rangeForThisScriptTag;
			rangeForThisScriptTag.location = foundRange.location;
			rangeForThisScriptTag.length = (rangeForEndOfScriptTag.location - foundRange.location) + rangeForEndOfScriptTag.length;
			
			NSString* scriptTagForThisTag = [htmlString substringWithRange:rangeForThisScriptTag];
			
			NSRange nextQuotRange = [htmlString rangeOfString:@")" options:NSCaseInsensitiveSearch range:range2];
			nextQuotRange.length = nextQuotRange.location - range2.location;
			nextQuotRange.location = range2.location;
			
			NSString* jsFileNameWithParams = [htmlString substringWithRange:nextQuotRange];
			NSString* jsFileName = [NSString stringWithString:jsFileNameWithParams];
			if ([[jsFileName componentsSeparatedByString:@"?"] count] >= 2) {
				jsFileName = [[jsFileName componentsSeparatedByString:@"?"] objectAtIndex:0];
			}
			
			NSString* localFileName = [[PNDashboard sharedObject] localPathForImageNamed:jsFileName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:localFileName]) {
				NSLog(@"fd: %@", localFileName);
				[availableScripts setObject:localFileName forKey:scriptTagForThisTag];
			}
			searchRange.location = foundRange.location + foundRange.length;
			searchRange.length = [htmlString length] - searchRange.location;
		}
	}
	for (NSString* originalFileName in [availableScripts allKeys]) {
		NSString* stringToFind = originalFileName;
		htmlString = [htmlString stringByReplacingOccurrencesOfString:stringToFind 
														   withString:[NSString stringWithFormat:@"url('%@')", [availableScripts objectForKey:originalFileName]]];
	}
	return htmlString;
}
- (NSString*)htmlStringWithCSSExpanded:(NSString*)original
{
	NSString* htmlString = [NSString stringWithString:original];
	NSString* cssImportPrefix = @"<link href=\"/stylesheets/";
	
	NSMutableDictionary* availableScripts = [NSMutableDictionary dictionary];
	
	NSRange searchRange;
	searchRange.location = 1;
	searchRange.length = [htmlString length]-1;
	while (1) {
		NSRange foundRange = [htmlString rangeOfString:cssImportPrefix options:NSCaseInsensitiveSearch range:searchRange];
		
		if (foundRange.length == 0) {
			break;
		} else {
			
			// Find next double quot.
			NSRange range2;
			range2.location = foundRange.location + [cssImportPrefix length];
			range2.length = [htmlString length] - range2.location;
			
			NSRange rangeForEndOfScriptTag = [htmlString rangeOfString:@"/>" options:NSCaseInsensitiveSearch range:range2];
			NSRange rangeForThisScriptTag;
			rangeForThisScriptTag.location = foundRange.location;
			rangeForThisScriptTag.length = (rangeForEndOfScriptTag.location - foundRange.location) + rangeForEndOfScriptTag.length;
			
			NSString* scriptTagForThisTag = [htmlString substringWithRange:rangeForThisScriptTag];
			
			NSRange nextQuotRange = [htmlString rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:range2];
			nextQuotRange.length = nextQuotRange.location - range2.location;
			nextQuotRange.location = range2.location;
			
			NSString* jsFileNameWithParams = [htmlString substringWithRange:nextQuotRange];
			NSString* jsFileName = [NSString stringWithString:jsFileNameWithParams];
			if ([[jsFileName componentsSeparatedByString:@"?"] count] >= 2) {
				jsFileName = [[jsFileName componentsSeparatedByString:@"?"] objectAtIndex:0];
			}
			
			NSString* localFileName = [[PNDashboard sharedObject] localPathForCSSNamed:jsFileName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:localFileName]) {
				[availableScripts setObject:localFileName forKey:scriptTagForThisTag];
			}
			searchRange.location = foundRange.location + foundRange.length;
			searchRange.length = [htmlString length] - searchRange.location;
		}
	}
	for (NSString* originalFileName in [availableScripts allKeys]) {
		NSString* stringToFind = originalFileName;
		NSString* scriptData = [[[NSString alloc] initWithContentsOfFile:[availableScripts objectForKey:originalFileName]
																encoding:NSUTF8StringEncoding error:nil] autorelease];
		
		htmlString = [htmlString stringByReplacingOccurrencesOfString:stringToFind 
														   withString:[NSString stringWithFormat:@"<link rel=\"stylesheet\" href=\"%@\" />", [availableScripts objectForKey:originalFileName]]];
	}
	return htmlString;
}
- (NSString*)localHTMLStringForRequest:(PNNativeRequest*)request
{
	NSString* localFilePath = [[PNDashboard sharedObject] localFilePathForRequest:request];
	NSString* htmlString = [[[NSString alloc] initWithContentsOfFile:localFilePath encoding:NSUTF8StringEncoding error:nil] autorelease];
	NSString* htmlStringWithJSExpanded = [self htmlStringWithJavaScriptExpanded:htmlString];
	NSString* htmlStringWithCSSExpanded = [self htmlStringWithCSSExpanded:htmlStringWithJSExpanded];
	
	NSLog(@"a:%@", htmlStringWithCSSExpanded);
	
	return htmlStringWithCSSExpanded;
}
- (NSString*)localFilePathForRequest:(PNNativeRequest*)request
{
	// TODO: If custom ui theme is available, use it instead.
	
	NSString* htmlDirectoryPath = [kPNDashboardDefaultUIResourcesBaseDirectoryPath stringByAppendingPathComponent:@"html"];
	return [htmlDirectoryPath stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.html", request.selectorName]];
}
- (NSString*)localPathForJavaScriptNamed:(NSString*)name
{
	// TODO: If custom ui theme is available, use it instead.
	
	NSString *jsDirectoryPath = [kPNDashboardDefaultUIResourcesBaseDirectoryPath stringByAppendingPathComponent:@"javascripts"];
	return [jsDirectoryPath stringByAppendingPathComponent:name];
}
- (NSString*)localPathForCSSNamed:(NSString*)name
{
	NSString* fileName = [name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	
	// TODO: If custom ui theme is available, use it instead.
	
	
	
	NSString *cssDirectoryPath = [kPNDashboardDefaultUIResourcesBaseDirectoryPath stringByAppendingPathComponent:@"stylesheets"];
	return [cssDirectoryPath stringByAppendingPathComponent:fileName];
}
- (NSString*)localPathForImageNamed:(NSString*)name
{
	NSString* fileName = [name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	fileName = [fileName stringByReplacingOccurrencesOfString:@"../../../images" withString:@""];
	
	// TODO: If custom ui theme is available, use it instead.
	
	
	
	NSString *cssDirectoryPath = [kPNDashboardDefaultUIResourcesBaseDirectoryPath stringByAppendingPathComponent:@"images"];
	return [cssDirectoryPath stringByAppendingPathComponent:fileName];
}
- (NSTimeInterval)currentDefaultUIResourceArchiveFileDateTime
{
	NSError* error = nil;
	NSDictionary* fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:kPNDashboardDefaultUIResourceArchiveFilePath error:&error];
	if (error == nil && fileInfo != nil) {
		return [[fileInfo objectForKey:NSFileCreationDate] timeIntervalSince1970];
	} else {
		return 0.0;
	}
}

- (void)importDefaultUIResourceFilesFromArchive
{
	ZipArchive* archive = [[[ZipArchive alloc] init] autorelease];
	[archive UnzipOpenFile:kPNDashboardDefaultUIResourceArchiveFilePath];
	[archive UnzipFileTo:kPNDashboardDefaultUIResourcesBaseDirectoryPath overWrite:YES];
	[archive UnzipCloseFile];
	
	NSTimeInterval defaultUICreationDateTime = [self currentDefaultUIResourceArchiveFileDateTime];
	
	if (defaultUICreationDateTime > 0.0) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:defaultUICreationDateTime] forKey:kPNDashboardDefaultUICopiedVersionDateTime];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

/**
 Check whether resource files (html, css and js) are available.
 If not, prepare them from the bundle.
 */
- (void)prepareResources
{
	NSError* error = nil;
	BOOL isDirectory = NO;
	
	// Check if default ui theme archive file exists or not
	if (![[NSFileManager defaultManager] fileExistsAtPath:kPNDashboardDefaultUIResourceArchiveFilePath isDirectory:&isDirectory] || isDirectory) {
		PNWarn(@"Dashboard error! Default UI theme archive file not exist! Check %@.zip is included in your project.", kPNDashboardDefaultUIResourceArchiveFileName);
		self.isAvailable = NO;
		return;
	}
	
	// Check if the directory for resource files exists or not.
	// If not, create directory and import files from the zipped file.
	if (![[NSFileManager defaultManager] fileExistsAtPath:kPNDashboardDefaultUIResourcesBaseDirectoryPath isDirectory:&isDirectory] || !isDirectory) {
		PNWarn(@"Dashboard resource directory doesn't exist. Creating...");
		// Create the directory for resource files.
		[[NSFileManager defaultManager] createDirectoryAtPath:kPNDashboardDefaultUIResourcesBaseDirectoryPath
								  withIntermediateDirectories:YES attributes:nil error:&error];
		if (error) {
			PNWarn(@"Dashboard error! Can't create resource directory in %@", kPNDashboardDefaultUIResourcesBaseDirectoryPath);
			self.isAvailable = NO;
			return;
		}
		
		// Import default ui theme files into the directory.
		[self importDefaultUIResourceFilesFromArchive];
	}
	
	// Check zipped file is newer than copied version.
	// If zipped file is newer, import files from it.
	NSTimeInterval copiedVersionDateTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kPNDashboardDefaultUICopiedVersionDateTime] doubleValue];
	if ([self currentDefaultUIResourceArchiveFileDateTime] > copiedVersionDateTime) {
		PNWarn(@"Updating default UI theme resource files from the zip file...");
		[self importDefaultUIResourceFilesFromArchive];
	}
	
	self.isAvailable = YES;
}

- (id)init {
	PNLogMethodName;
	if (self = [super init]){	
		PNCLog(PNLOG_CAT_DASHBOARD, @"Dashboard init.");
		[self prepareResources];
		
		[self setState:DS_CLOSED];	//最初の状態では閉じた状態に設定します
		
		self.isAvailableNatType = YES;
		
		//ビューコントローラを上にのせていくための透明なビューコントローラを生成します		
		self.dashboardOrientation = UIInterfaceOrientationLandscapeRight;
		self.rootViewController = [[[PNRootViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		
		pankiaWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		pankiaWindow.backgroundColor = [UIColor clearColor];
		[pankiaWindow addSubview:self.rootViewController.view];
		pankiaWindow.hidden = YES;
		
		self.modalIndicator = [[[PNModalIndicatorWindow alloc] init] autorelease];
		self.preview = [[[PNPreview alloc] init] autorelease];
		self.alertView = [[[PNModalAlertView alloc] init] autorelease];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStateChanged:) name:kPNNotificationConnectionEstablished object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStateChanged:) name:kPNNotificationConnectionDisconnected object:nil];
	}
	return self;
}

- (void) dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.rootViewController = nil;
	self.pankiaWindow		= nil;
	self.appTitle			= nil;
	self.modalIndicator		= nil;
	self.preview			= nil;
	self.alertView			= nil;
	[super dealloc];
}

+ (PNDashboard *)sharedObject
{
	PNLogMethodName;
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	PNLogMethodName;
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	PNLogMethodName;
	return self;
}

- (id)retain
{
	PNLogMethodName;
	return self;
}

- (unsigned)retainCount
{
	PNLogMethodName;
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	PNLogMethodName;
	// 何もしない
}

- (id)autorelease
{
	PNLogMethodName;
	return self;
}

#ifdef DEBUG
#ifdef NETWORK_DEBUG
// ネットワークのデバッグ用の機能です。後ほど適切な場所に移動します。
- (void)showNetworkDebugIndicator {
	PNLogMethodName;
	if (lblIndicator != nil) return;
	
	lblIndicator = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f,40.0f, 140.0f, 20.0f)] retain];
	
	
	//現在のデバイスの向きにあわせて回転させます。
	UIInterfaceOrientation orientation = [PNDashboard sharedObject].dashboardOrientation;
	if (orientation == UIInterfaceOrientationLandscapeRight) {
		lblIndicator.transform = CGAffineTransformMakeRotation(M_PI/2);	
		lblIndicator.layer.position = CGPointMake(60.0f - lblIndicator.bounds.size.height/2 , 
												  480.0f - lblIndicator.bounds.size.width/2);
		lblRttIndicator.transform = CGAffineTransformMakeRotation(M_PI/2);	
		lblRttIndicator.layer.position = CGPointMake(220.0f - lblRttIndicator.bounds.size.height/2 , 
													 480.0f - lblRttIndicator.bounds.size.width/2);
	}
	else if (orientation == UIInterfaceOrientationLandscapeLeft){
		lblIndicator.transform = CGAffineTransformMakeRotation(-M_PI/2);	
		lblIndicator.layer.position = CGPointMake(260 + lblIndicator.bounds.size.height/2 , lblIndicator.bounds.size.width/2);					
	}
	lblIndicator.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:0.5f];
	lblIndicator.text = @"TCP:0\tUDP:0";
	lblIndicator.font = [UIFont systemFontOfSize:11.0];
	lblIndicator.textColor = [UIColor whiteColor];
	[[PNDashboard sharedObject].pankiaWindow addSubview:lblIndicator];
	
#ifdef PNDEBUG_SHOW_RTT
	lblRttIndicator = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f,0.0f,160.0f, 120.0f)] retain];
	if (orientation == UIInterfaceOrientationLandscapeRight) {
		lblRttIndicator.transform = CGAffineTransformMakeRotation(M_PI/2);	
		lblRttIndicator.layer.position = CGPointMake(220.0f - lblRttIndicator.bounds.size.height/2 , 
													 480.0f - lblRttIndicator.bounds.size.width/2);
	}
	else if (orientation == UIInterfaceOrientationLandscapeLeft){
	}
	lblRttIndicator.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:0.5f];
	lblRttIndicator.text = [[NSArray arrayWithObjects:@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",nil] componentsJoinedByString:@"\n"];
	lblRttIndicator.numberOfLines = 9;
	lblRttIndicator.font = [UIFont systemFontOfSize:10.0];
	lblRttIndicator.textColor = [UIColor whiteColor];
	lblRttIndicator.textAlignment = UITextAlignmentRight;
	[[PNDashboard sharedObject].pankiaWindow addSubview:lblRttIndicator];
	
#endif
	
	
}
- (void)updateDebugLabelText:(NSString*)text{
	PNLogMethodName;
	[lblIndicator performSelectorOnMainThread:@selector(setText:) withObject:text waitUntilDone:NO];
}
- (void)updateRttDebugLabelText:(NSString*)text{
	PNLogMethodName;
#ifdef PNDEBUG_SHOW_RTT
	[lblRttIndicator performSelectorOnMainThread:@selector(setText:) withObject:text waitUntilDone:NO];
#endif
}
#endif
#endif

#ifdef DEBUG	//デバッグ用のメソッドです。Debugビルドのときだけ使用できます。情報をNotificationViewで表示します。
- (void)manager:(PNManager*)manager didReceiveDebugInfo:(NSString*)title description:(NSString*)description{
	PNLogMethodName;
	[PNNotificationService showTextNotice:title description:description appearTime:kPNNotificationViewDebugAppearTime];
}
#endif

+ (void)setViewId:(NSInteger)viewId
{
	PNLogMethodName;
	[[self getWrappedNavigationController] setViewId:viewId];
}

@end
