//
//  PankiaNet+Dashboard.m
//  PankakuNet
//
//  Created by sota2 on 10/10/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "PankiaNet.h"
#import "PankiaNet+Package.h"

#import "PNDashboard.h"

#import "PNManager.h"
#import "PNStoreManager.h"
#import "PNSettingManager.h"

#import "PNLocalizedString.h"
#import "PNControllerLoader.h"

#import "PNItem.h"
#import "PNItemHistory.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNMerchandise.h"

#import "PNRootViewController.h"
#import "PNItemCategoryViewController.h"
#import "PNItemDetailViewController.h"
#import "PNMerchandiseDetailViewController.h"
#import "PNJoinedRoomViewController.h"
#import "PNRootNavigationController.h"
#import "PNWebViewController.h"

static const NSString* PNControllerMatchUp			= @"PNMatchUpViewController";
static const NSString* PNControllerRooms			= @"PNRoomsViewController";
static const NSString* PNControllerJoinedRoom		= @"PNJoinedRoomViewController";
static const NSString* PNControllerLocalMatch		= @"PNLocalMatchViewController";
static const NSString* PNControllerAchievements		= @"PNAchievementsViewController";
static const NSString* PNControllerFriends			= @"PNFriendsViewController";
static const NSString* PNControllerSettings			= @"PNSettingsViewController";
static const NSString* PNControllerInvitedRooms		= @"PNInvitedRoomsViewController";
static const NSString* PNControllerEditProfile		= @"PNEditProfileViewController";
static const NSString* PNControllerSecureAccount	= @"PNSecureAccountViewController";
static const NSString* PNControllerSwitchAccount	= @"PNSwitchAccountViewController";
static const NSString* PNControllerProfile			= @"PNProfileViewController";

PNRoom*							reMatchRoom;

@interface PankiaNet(DashboardPrivate)
+ (void)jumpToInternetMatchRoom:(PNRoom*)room;
@end

@implementation PankiaNet(Dashboard)
/*!
 * ダッシュボードを表示します。
 */
+ (void)launchDashboard
{	
	[[PNDashboard sharedObject] launchWithPushControllers:nil ];
}

/*!
 * リーダーボードを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithLeaderboardsView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		//リーダーボードを表示した状態でダッシュボードを起動します
		[[PNDashboard sharedObject] launchWithPushControllerName:@"PNLeaderboardsViewController"];
		//[PNDashboard pushViewControllerNamed:@"PNLeaderboardsViewController"];
	}
	
}

/*!
 * アチーブメントを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithAchievementsView
{	
	[[PNDashboard sharedObject] launchWithPushControllerName:PNControllerAchievements];
}

/*!
 * フレンド一覧を表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithFindFriendsView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		[[PNDashboard sharedObject] launchWithPushControllerName:PNControllerFriends];
	}
}

/*!
 * ローカルマッチを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithNearbyMatchView
{
	[[PNDashboard sharedObject] launchWithPushControllerName: PNControllerLocalMatch];
	//[[PNDashboard sharedObject] showNearbyMatchTopPage];
}

/*!
 * インターネットマッチを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithInternetMatchView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		[[PNDashboard sharedObject] launchWithPushControllerName:PNControllerMatchUp ];
		//[[PNDashboard sharedObject] showInternetMatchTopPage];
	} else {
		PNError * e = [[[PNError alloc] init] autorelease];
		[e setErrorCode:@"not_signed_in"];
		[PNDashboard showErrorView:nil withError:e];
	}
}

/*!
 * Settingsを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithSettingsView
{	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		[[PNDashboard sharedObject] launchWithPushControllerName:PNControllerSettings];
	}
}

/*!
 * Settings/EditProfileを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithEditProfileView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerSettings,PNControllerEditProfile, nil] autorelease];
		[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	}
}

/*!
 * Settings/SecureAccountを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithSecureAccountView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerSettings,PNControllerSecureAccount, nil] autorelease];
		[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	}
}

/*!
 * Settings/SwitchAccountを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithSwitchAccountView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerSettings,PNControllerSwitchAccount, nil] autorelease];
		[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	}
}

/*!
 * 自分自身のUserProfileを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithMyProfileView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerFriends,PNControllerProfile, nil] autorelease];
		[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	}
}

/*!
 * 指定されたusernameに基づいたUserProfileを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithUsersProfileView:(NSString*)username
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerFriends,PNControllerProfile, nil] autorelease];
		[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	}
}

/*!
 * Invited Roomsを表示した状態でダッシュボードを起動します
 */
+ (void)launchDashboardWithInvitedRoomsView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerMatchUp,PNControllerInvitedRooms, nil] autorelease];
		[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	}
}

/*!
 * Roomの中を表示した状態でダッシュボードを起動します。
 */
+ (void)launchDashboardWithInternetMatchRoom:(PNRoom*)room
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		if ([[PNDashboard sharedObject] isDismissed]) {		
			NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerMatchUp,PNControllerRooms,PNControllerJoinedRoom, nil] autorelease];
			if(reMatchRoom) [reMatchRoom release];
			reMatchRoom = [room retain];
			[[PNDashboard sharedObject] launchWithPushControllers:controllers];
			
		}
		else {
			[PankiaNet jumpToInternetMatchRoom:room];							
		}
	}
}

+ (void)launchDashboardWithLinkWithTwitterView
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {	
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerSettings, @"PNLinkTwitterViewController", nil] autorelease];
		[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	}
}

+ (void)launchDashboardWithItemDetailView:(int)itemId
{
	PNItem* item = [PNItem itemWithId:itemId];
	if (item == nil) {
		PNWarn(@"Item(%d) not found.", itemId);
		return;
	}
	PNItemDetailViewController* detailViewController = [[[PNItemDetailViewController alloc] init] autorelease];
	detailViewController.item = item;
	if (item != nil) {	//所有情報を最新にします
		item.quantity = [[PNItemHistory sharedObject] currentQuantityForItemId:[item stringId]];
	}
	
	[[PNDashboard sharedObject] launchWithPushControllers:[NSArray arrayWithObjects:@"PNItemsViewController",@"PNMyItemsViewController", detailViewController, nil]];
}
+ (void)launchDashboardWithMerchandiseDetailView:(NSString*)identifier
{
	PNMerchandise* merchandise = [[PNStoreManager sharedObject] merchandiseWithProductIdentifier:identifier];
	if (merchandise == nil) {
		PNWarn(@"Merchandise(%@) not found.", identifier);
		return;
	}
	
	PNMerchandiseDetailViewController* detailViewController = [[[PNMerchandiseDetailViewController alloc] init] autorelease];
	detailViewController.merchandise = merchandise;
	
	PNItemCategoryViewController* categoryViewController = [[[PNItemCategoryViewController alloc] init] autorelease];
	categoryViewController.selectedCategory = merchandise.item.category;
	
	UIBarButtonItem* closeButton = [[[UIBarButtonItem alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Back_to_game") style:UIBarButtonItemStyleDone target:self action:@selector(dismissDashboard)] autorelease];
	detailViewController.navigationItem.leftBarButtonItem = closeButton;
	
	[[PNDashboard sharedObject] launchWithPushControllers:[NSArray arrayWithObjects:@"PNItemsViewController", @"PNItemCategoryListViewController", categoryViewController, detailViewController, nil]];
}

+ (void)launchDashboardWithURL:(NSString*)url
{
	PNWebViewController* controller = (PNWebViewController*)[PNControllerLoader load:@"PNWebViewController" filesOwner:self];
	
	NSArray* controllers = [[[NSArray alloc] initWithObjects:controller, nil] autorelease];
	[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	
	[controller loadURL:url];
}

/*!
 * Roomの中を表示した状態でダッシュボードを起動します。
 */
+ (void)jumpToInternetMatchRoom:(PNRoom*)room
{
	//ログインしている時にのみDashboardを起動する。
	if ([PNManager sharedObject].isLoggedIn) {
		
		PNRootNavigationController* rootNav = (PNRootNavigationController*)[PNDashboard sharedObject].rootViewController.contentController;		 
		
		[rootNav popToRootViewControllerAnimated:NO];
		
		NSArray* controllers = [[[NSArray alloc] initWithObjects:PNControllerMatchUp,PNControllerRooms,PNControllerJoinedRoom, nil] autorelease];
		if(reMatchRoom) [reMatchRoom release];
		reMatchRoom = [room retain];
		
		//pushController配列があった場合は、その中に格納されているコントローラごとに処理を行う。
		for (NSObject* obj in controllers)
		{
			UIViewController* controller = nil;
			
			if ([obj isKindOfClass:[NSString class]])
			{
				//まだなにもコントローラがプッシュされていなければ、controllerに登録する。
				if( !controller ) { 
					NSString* controllerName = (NSString*)obj;
					controller = (UIViewController*)[PNControllerLoader load:controllerName filesOwner:nil];
				}
			}
			else if ([obj isKindOfClass:[UIViewController class]]) //UIViewControllerならばそのままいける。
			{
				controller = (UIViewController*)obj;
			}
			else {
				return;
			}
			
			//reMatch用のroomを登録する。
			if(reMatchRoom && [controller isKindOfClass:[PNJoinedRoomViewController class]]){			
				PNRoom* room = reMatchRoom;
				PNJoinedRoomViewController* joinedController = (PNJoinedRoomViewController*)controller;
				room.delegate = joinedController;
				joinedController.myRoom = room;
				
				[rootNav pushViewController:joinedController animated:NO];
			}
			else {
				//rootNavControllerにcontrollerToPushに登録してある処理をプッシュする。
				[rootNav pushViewController:controller animated:NO];			
			}
		}
		
	}
}
+ (void)dismissDashboard
{
	PankiaNet* pInstance = [PankiaNet sharedObject];
	
	if (pInstance.pankiaNetDelegate != nil && [pInstance.pankiaNetDelegate respondsToSelector:@selector(dashboardWillDisappear)]){
		[pInstance.pankiaNetDelegate dashboardWillDisappear];
	}	
	
	PNDashboard *dashboard = [PNDashboard sharedObject];
	[dashboard dismiss];
	
	if (pInstance.pankiaNetDelegate != nil && [pInstance.pankiaNetDelegate respondsToSelector:@selector(dashboardDidDisappear)]) {
		[pInstance.pankiaNetDelegate dashboardDidDisappear];
	}		
}

+ (void)animationDidStop:_animation finished:(BOOL)_finished
{
	PNDashboard* dashboard = [PNDashboard sharedObject];
	if (dashboard.isDismissed) {
		[PNDashboard getRootController].view.hidden = YES;		
	}
}
+ (UIInterfaceOrientation)dashboardOrientation 
{
	return [PNDashboard sharedObject].dashboardOrientation;
}
+ (void)setDashboardOrientation:(UIInterfaceOrientation)orientation
{
	[PNDashboard sharedObject].dashboardOrientation = orientation;
	[[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
}
+ (void)setSideMenuEnabled:(BOOL)enabled
{
	[[PNSettingManager sharedObject] setSideMenuEnabled:enabled];
	[PNDashboard resetAllButtons];
}

-(void)didFailLaunchDashboardWithError:(PNError*)error
{
	if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(dashboardDidFailToLaunchWithError:) ]) {
		[[PankiaNet sharedObject].pankiaNetDelegate dashboardDidFailToLaunchWithError:error];
	}
}

@end
