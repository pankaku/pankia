//
//  PNNavigationController.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNNavigationController.h"
#import "PNViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNControllerLoader.h"
#import "PNFramedContentView.h"
#import "PNTableViewController.h"
#import "PNLobbyViewController.h"
#import "PNSecureAccountViewController.h"
#import "PNCreateLocalRoomViewController.h"
#import "PNCreateRoomViewController.h"
#import "PNLicenseViewController.h"
#import "PNErrorViewController.h"
#import "PNInformationViewController.h"
#import "PNSettingsViewController.h"
#import "PNMatchUpViewController.h"
#import "PNLocalMatchViewController.h"
#import "PNLocalRoomsViewController.h"
#import "PNAppMainViewController.h"
#import "PankiaNet+Package.h"
#import "PNDashboard.h"
#import "UIView+Slide.h"

 

@implementation PNNavigationController


- (NSInteger)viewId {
	return viewId;
}

- (void)setViewId:(NSInteger)value {
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.delegate = self;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Dashboard Header
	dashboardHeaderView_ = (PNDashboardHeaderView*)[PNControllerLoader loadUIViewFromNib:@"PNDashboardHeaderView" filesOwner:self];
	[self.view addSubview:dashboardHeaderView_];
	
	// Indicator
	indicator  = [[[PNIndicator alloc] init] autorelease];
	[self.view addSubview:indicator];
	[self.view bringSubviewToFront:self.navigationBar];
}

// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == [PNDashboard sharedObject].dashboardOrientation);
//}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)setViewControllers:(NSArray *)controllers {
	//タイトルのローカライズを行います
	for (UIViewController* controller in controllers) {
		[controller setTitle:getTextFromTable(controller.title)];
		if (![controller.view isKindOfClass:[PNFramedContentView class]] && [controller isKindOfClass:[PNTableViewController class]]) {		
			PNTableViewController* myTableViewController = (PNTableViewController*)controller;
			UITableView* contentView = myTableViewController.tableView;
			PNFramedContentView* wrapperView = [[[PNFramedContentView alloc] initWithView:contentView] autorelease];
			[wrapperView isTable:YES];
			[wrapperView setPNNavigationController:self];
			[controller setView:wrapperView];
			UIEdgeInsets contentInsets = UIEdgeInsetsMake(9.f, 70.f, 49.f, 6.f);
			[wrapperView setInsets:contentInsets];
		}
		else if (![controller.view isKindOfClass:[PNFramedContentView class]]) {
			if ([controller isKindOfClass:[PNViewController class]]) {
				PNViewController* vController = (PNViewController*)controller;
				if ([vController respondsToSelector:@selector(shouldShowWrapperFrame)]){
					BOOL shouldShowWrapperFrame = [vController shouldShowWrapperFrame];
					
					if (shouldShowWrapperFrame){
						PNFramedContentView* wrapperView = [[[PNFramedContentView alloc] initWithView:(UITableView*)(controller.view)] autorelease];
						[wrapperView isTable:NO];
						[wrapperView setPNNavigationController:self];
						[controller setView:wrapperView];
						UIEdgeInsets contentInsets = UIEdgeInsetsMake(9.f, 70.f, 49.f, 6.f);
						[wrapperView setInsets:contentInsets];
					}
				}
				else {			// iPadの時に表示位置を補正します
					if ([[PNDashboard sharedObject] isLandscapeMode] && [[PNDashboard sharedObject] isIPad]) {
						for (UIView* subview in controller.view.subviews){
							[subview slideX:0.0f y:-11.0f];
						}
					}
				}
			}
		}
	}
	[super setViewControllers:controllers];
}

- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated {
	
	[self showIndicator];
	[self.view bringSubviewToFront:self.navigationBar];
	
	//タイトルをローカライズします
	[controller setTitle:getTextFromTable(controller.title)];

	if (![controller.view isKindOfClass:[PNFramedContentView class]] && [controller isKindOfClass:[PNTableViewController class]]) {		
		PNTableViewController* myTableViewController = (PNTableViewController*)controller;
		UITableView* contentView = myTableViewController.tableView;
		PNFramedContentView* wrapperView = [[[PNFramedContentView alloc] initWithView:contentView] autorelease];
		[wrapperView isTable:YES];
		[wrapperView setPNNavigationController:self];

		UIEdgeInsets contentInsets;
		if ([[PNDashboard sharedObject] isLandscapeMode]) {
			if ([[PNDashboard sharedObject] isIPad]) {
				contentInsets = UIEdgeInsetsMake(-2.f, 70.f, 49.f, 6.f);
			}
			else {
				contentInsets = UIEdgeInsetsMake(9.f, 70.f, 49.f, 6.f);
			}
		}
		else {
			contentInsets = UIEdgeInsetsMake(9.f, 15.f, 109.f, 6.f);
		}
		[wrapperView setInsets:contentInsets];		
	}
	else if (![controller.view isKindOfClass:[PNFramedContentView class]]) {
		if ([controller isKindOfClass:[PNViewController class]]
			|| [controller isKindOfClass:[PNErrorViewController class]]
			|| [controller isKindOfClass:[PNInformationViewController class]]
			|| [controller isKindOfClass:[PNLicenseViewController class]]){
			PNViewController* vController = (PNViewController*)controller;
			if ([vController respondsToSelector:@selector(shouldShowWrapperFrame)]){
				BOOL isShowWrapperFrame = [vController shouldShowWrapperFrame];
				
				if (isShowWrapperFrame){
					PNFramedContentView* wrapperView = [[[PNFramedContentView alloc] initWithView:(UITableView*)(controller.view)] autorelease];
					[wrapperView isTable:NO];
					[wrapperView setPNNavigationController:self];
					
					UIEdgeInsets contentInsets;
					if ([[PNDashboard sharedObject] isLandscapeMode]) {
						if ([[PNDashboard sharedObject] isIPad]) {
							contentInsets = UIEdgeInsetsMake(-2.f, 70.f, 49.f, 6.f);
						}
						else {
							contentInsets = UIEdgeInsetsMake(9.f, 70.f, 49.f, 6.f);
						}
					}
					else {
						contentInsets = UIEdgeInsetsMake(9.f, 15.f, 109.f, 6.f);
					}
					[wrapperView setInsets:contentInsets];
					[controller setView:wrapperView];
				} 
			}
			else {
				// iPadの時に表示位置を補正します
				if ([[PNDashboard sharedObject] isLandscapeMode] && [[PNDashboard sharedObject] isIPad]) {
					for (UIView* subview in controller.view.subviews) {
						[subview slideX:0.0f y:-11.0f];
					}
				}
			}
		}
	}
	[super pushViewController:controller
					 animated:animated];
	[dashboardHeaderView_ setDelegate:self];
}

- (void)popToRootViewController:(BOOL)animated {
	[super popToRootViewControllerAnimated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated {
	[super popViewControllerAnimated:animated];
}

- (void)dealloc {
    [super dealloc];
}

- (void)hideFramedViewEnd {
	framedView.hidden = YES;
	CGRect rect = framedView.frame;
	rect.origin.x = 480;
	framedView.frame = rect;
}

- (void)hideFramedView:(BOOL)isHide :(float)x {
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	if (isHide) {
		[UIView setAnimationDidStopSelector:@selector(hideFramedViewEnd)];
	}
	CGRect rect = framedView.frame;
	rect.origin.x = x;
	[framedView setFrame:rect];
	[UIView commitAnimations];
}

- (void)showFramedView {
	framedView.hidden = NO;
	[self hideFramedView:NO :0.0f];
}

- (void)hideFramedViewLeft {
	[self hideFramedView:YES :-480.0f];
}

- (void)hideFramedViewRight {
	[self hideFramedView:YES :480.0f];
}

- (void)hideFooterAndLeftPane {
	dashboardHeaderView_.hidden = YES;
	profileAreaView_.hidden = YES;
}



#pragma mark NavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
	   didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

	if ([viewController isKindOfClass:[PNSettingsViewController class]]
		 || [viewController isKindOfClass:[PNLocalMatchViewController class]]
		 || [viewController isKindOfClass:[PNMatchUpViewController class]]
		 || [viewController isKindOfClass:[PNAppMainViewController class]]) {
		[self hideIndicator];
	}
}

- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated {	

	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"willShowViewController: %p", viewController);
	if ( [viewController nibName] ) {
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"nibName=%@", [viewController nibName]);
	}

	UIBarButtonItem * btn = viewController.navigationItem.backBarButtonItem;
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"willShowViewController backBarButtonItem: %p", btn);
	if (btn && btn.target && [btn.target respondsToSelector:btn.action]) {
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"perform backBarButtonItem action");
		[btn.target performSelector:btn.action];
	}
	
	PNLog(@"------------------------");
	PNLog(@"isLoggedIn : %d",[PankiaNet isLoggedIn]);
	PNLog(@"------------------------");
	
	[self update];
}

- (void)update {

	NSArray* viewControllerArray = self.viewControllers;	
	if ([viewControllerArray count] > 0) {
		PNAppMainViewController* appMainViewController = [viewControllerArray objectAtIndex:0];
		if([appMainViewController respondsToSelector:@selector(relocateMenuButtons)]){
			[appMainViewController relocateMenuButtons];
		}
	}
	[self updateDashboardHeader];
}

- (void)updateDashboardHeader {
	[dashboardHeaderView_ updateStats];
}

- (BOOL)showTwitterLink {
	return showTwitterLink;
}

- (void)returnRootView {
	PNLog(@"returnRootView");
	[self popToRootViewControllerAnimated:NO];
}

- (void)showIndicator {
	[indicator performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
}

- (void)showLargeIndicator {
	[indicator performSelectorOnMainThread:@selector(startInLargeMode) withObject:nil waitUntilDone:YES];
}

- (void)updateIndicatorDescription:(NSString*)text {
	[indicator performSelectorOnMainThread:@selector(updateDescription:) withObject:text waitUntilDone:YES];
}

- (void)hideIndicator {
	[indicator performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:YES];
}

- (BOOL)isIndicatorAnimating {
	return [indicator isIndicatorAnimating];
}

- (void)disableAllButtons {
	UINavigationItem* item = [self.navigationBar.items objectAtIndex:[self.navigationBar.items count] - 1];
	[item.rightBarButtonItem setEnabled:NO];
	[dashboardHeaderView_ disableAllButtons];
}

- (void)resetAllButtons {
	UINavigationItem* item = [self.navigationBar.items objectAtIndex:[self.navigationBar.items count] - 1];
	[item.rightBarButtonItem setEnabled:YES];
	[dashboardHeaderView_ resetAllButtons];
}

@end
