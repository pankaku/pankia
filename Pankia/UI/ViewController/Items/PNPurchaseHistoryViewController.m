//
//  PNPurchaseHistoryViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNPurchaseHistoryViewController.h"
#import "PNDashboard.h"
#import "PNStoreManager.h"
#import "PNPurchaseModel.h"
#import "PNItemCell.h"
#import "PNMerchandise.h"
#import "PNMerchandiseDetailViewController.h"
#import "PNLocalizedString.h"

#define kPNAccessoryImage @"PNCellArrowImage.png"

@interface PNPurchaseHistoryViewController ()
@property(nonatomic, retain) NSArray* purchases;
@end

@implementation PNPurchaseHistoryViewController
@synthesize purchases;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = getTextFromTable(@"PNTEXT:ITEMS:Purchase_history");
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[PNDashboard hideIndicator];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[PNDashboard showIndicator];
	//履歴を取得しにいきます
	[[PNStoreManager sharedObject] getPurchaseHistoryWithDelegate:self 
													  onSucceeded:@selector(getHistorySucceeded:) 
														 onFailed:@selector(getHistoryFailed:)];
}

#pragma mark -
- (void)getHistorySucceeded:(NSArray*)_purchases
{
	self.purchases = _purchases;
	[PNDashboard hideIndicator];
	[self reloadData];
}
- (void)getHistoryFailed:(PNError*)error
{
	[PNDashboard hideIndicator];
	// TODO: エラー処理
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.purchases count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = indexPath.row;
	
    NSString *cellIdentifier = [self cellIdentifierName:@"PNItemCell"];
    PNItemCell *cell = (PNItemCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = (PNItemCell*)[self cellWithIdentifier:@"PNItemCell"];
	}
	
	cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNAccessoryImage]] autorelease];
    
	cell.purchase = [self.purchases objectAtIndex:row];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PNPurchaseModel* purchase = [self.purchases objectAtIndex:indexPath.row];
	PNMerchandise* merchandise = [[PNStoreManager sharedObject] merchandiseWithProductIdentifier:purchase.merchandise_id];
	
	PNMerchandiseDetailViewController* detailViewController = [[[PNMerchandiseDetailViewController alloc] init] autorelease];
	detailViewController.merchandise = merchandise;
	[PNDashboard pushViewController:detailViewController];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	self.purchases = nil;
    [super dealloc];
}


@end

