//
//  PNMerchandiseDetailViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMerchandiseDetailViewController.h"
#import "PNMerchandise.h"
#import "PNDashboard.h"
#import "PNStoreManager.h"
#import "PNManager.h"
#import "PNFormatUtil.h"
#import "PNLocalizedString.h"

#import "PNItemOwnershipModel.h"
 
#import "PNItem.h"
#import "PNGlobal.h"
#import "PNTableCell.h"
#import "PNItemHistory.h"
#import "PNSKProduct.h"
#import "PNFormatUtil.h"

#import "PNItemViewHelper.h"
#import "PNTableViewHelper.h"

#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNAlertHelper.h"

@implementation PNMerchandiseDetailViewController
@synthesize merchandise;

- (void)setMerchandise:(PNMerchandise *)object
{
	if (merchandise != nil) {
		[merchandise release];
		merchandise = nil;
	}
	merchandise = [object retain];
	
	contentsHeaderRowNumber = 1;
	descriptionHeaderRowNumber = 3;
	rowCount = 7;
	
	screenshotsHeaderRowNumber = descriptionHeaderRowNumber + 2;
	if (![PNManager sharedObject].isLoggedIn || [merchandise.item.screenshotUrls count] == 0) {
		rowCount -= 2;
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[PNDashboard hideIndicator];
}

- (void)viewDidAppear:(BOOL)animated {
	
    [super viewDidAppear:animated];
	
	if (self.merchandise != nil) {
		self.title = self.merchandise.name;
	}

	[PNDashboard hideIndicator];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return rowCount;
}

#pragma mark -

- (BOOL)isHeaderCell:(NSInteger)row
{
	return row == contentsHeaderRowNumber || 
	row == descriptionHeaderRowNumber || row == screenshotsHeaderRowNumber;
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int index = indexPath.row;
	
	if (index == 0) return 60.0f;					//Top
	if ([self isHeaderCell:index]) return 25.0f;	//Headers
	if (index == descriptionHeaderRowNumber + 1) return [PNTableViewHelper heightSizeForString:merchandise.item.description];
	if (index == screenshotsHeaderRowNumber + 1) return [PNTableViewHelper heightSizeForScreenshotsCell:merchandise.item.screenshotUrls];
	return 40.0f;
}

#pragma mark -

- (UITableViewCell *)titleCellForTableView:(UITableView *)tableView 
{
	static NSString *CellIdentifier = @"TitleCell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNCellBackgroundImage60.png"]] autorelease];
    // Configure the cell...
	cell.textLabel.text = merchandise.name;
	cell.highlightable = NO;	
	
	PNSKProduct* productInfo = [[PNStoreManager sharedObject] productWithProductIdentifier:merchandise.productIdentifier];
	if (productInfo) {
		cell.detailTextLabel.text = [PNFormatUtil priceOfProduct:productInfo];
		cell.detailTextLabel.textColor = [UIColor cyanColor];
	}
	
	
	[cell loadRoundRectImageFromURL:merchandise.item.iconUrl defaultImageName:@"PNDefaultGameIcon.png" 
						paddingLeft:20.0f top:10.0f right:0.0f bottom:10.0f width:36.0f height:36.0f delegate:self];
	
    [cell setAccessoryButtonWithDelegate:self selector:@selector(buyThisItem) 
								   title:getTextFromTable(@"PNTEXT:ITEMS:Buy") enabled:[PNManager sharedObject].isLoggedIn && [merchandise isBuyable] && !isBuying tag:0];
    return cell;
}

- (UITableViewCell *)contentsCellForTableView:(UITableView *)tableView 
{
	static NSString *CellIdentifier = @"ContentsCell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNInformationBackgroundImage.png"]] autorelease];
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@ x %lld",merchandise.item.name, merchandise.multiple];
	cell.highlightable = NO;	
	[cell setLeftPadding:10.0f];
	
    if ([merchandise.item isCoin]) {
        merchandise.item.quantity = [PNUser currentUser].coins;
    } else {
		NSString* itemId = [merchandise.item stringId];
        merchandise.item.quantity = [[PNItemHistory sharedObject] currentQuantityForItemId:itemId];
    }
    
//	merchandise.item.quantity = [[PNItemHistory sharedObject] currentQuantityForItemId:[merchandise.item stringId]];
    [cell setAccessoryText:[NSString stringWithFormat:@"%lld", merchandise.item.quantity]];
    return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int index = indexPath.row;
    
	if (index == 0) return [self titleCellForTableView:tableView];
	if (index == 2) return [self contentsCellForTableView:tableView];
	if (index == contentsHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Contents"];
	if (index == descriptionHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Description"];
	if (index == screenshotsHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Screenshots"];
	if (index == descriptionHeaderRowNumber + 1) return [PNItemViewHelper descriptionCellForTableView:tableView item:merchandise.item];
	if (index == screenshotsHeaderRowNumber + 1) return [PNItemViewHelper screenshotsCellForTableView:tableView item:merchandise.item];
	
	return nil;	//Should not reach here.
}

- (void)buyThisItem
{
	[PNDashboard showModalIndicator];
	isBuying = YES;
//	[[PNStoreManager sharedObject] purchaseWithProductIdentifier:merchandise.productIdentifier delegate:self 
//													 onSucceeded:@selector(buyThisItemSucceeded:)
//														onFailed:@selector(buyThisItemFailed:)];
	[self reloadData];
}

- (void)buyThisItemSucceeded:(PNItemOwnershipModel*)ownership
{
	[PNDashboard hideModalIndicator];
	[PNDashboard updateDashboard];
	isBuying = NO;
	[self reloadData];
}
- (void)buyThisItemFailed:(PNError*)error
{
	[PNAlertHelper showAlertForPurchaseFail:error];
	isBuying = NO;
	PNWarn(@"Error. Buy item failed ->%@", error.errorCode);
	[PNDashboard hideModalIndicator];
	[PNDashboard updateDashboard];
	[self reloadData];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    [super dealloc];
}


@end

