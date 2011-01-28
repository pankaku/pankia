    //
//  PNItemsViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemsViewController.h"
#import "PNDashboard.h"
#import "PNManager.h"

@interface PNItemsViewController (Private)
- (void)disableMenuItemsIfOffline;
@end

@implementation PNItemsViewController
- (void)disableMenuItemsIfOffline
{
	if (![PNManager sharedObject].isLoggedIn) {
		storeButton.enabled = NO;
		purchaseHistoryButton.enabled = NO;
	}
}
- (IBAction)onMyItemsPressed
{
	[PNDashboard pushViewControllerNamed:@"PNMyItemsViewController"];
}
- (IBAction)onStorePressed
{
	[PNDashboard pushViewControllerNamed:@"PNItemCategoryListViewController"];
}
- (IBAction)onPurchaseHistoryPressed
{
	[PNDashboard pushViewControllerNamed:@"PNPurchaseHistoryViewController"];
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self disableMenuItemsIfOffline];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[PNDashboard hideIndicator];
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self disableMenuItemsIfOffline];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
