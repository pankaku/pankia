//
//  PNItemDetailViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemDetailViewController.h"
#import "PNItemCategoryViewController.h"
#import "PNMerchandiseDetailViewController.h"

#import "PNStoreManager.h"
#import "PNManager.h"

#import "PNItemOwnershipModel.h"

#import "PNItem.h"
#import "PNItemHistory.h"
#import "PNLocalizableLabel.h"
#import "PNGlobal.h"
#import "PNDashboard.h"
#import "PNTableCell.h"
#import "PNFormatUtil.h"
#import "PNMerchandise.h"
#import "PNItemCategory.h"
#import "UIView+Slide.h"
#import "PNThumbnailsCell.h"

#import "PNItemViewHelper.h"
#import "PNTableViewHelper.h"

#import "PNUser.h"
#import "PNUser+Package.h"

#import "PNSKProduct.h"
#import "PNAlertHelper.h"

static int kCategoryHeaderRowNumber = 1;

@implementation PNItemDetailViewController
@synthesize item;

- (void)setItem:(PNItem *)newItem
{
	if (item != nil) {
		[item release];
		item = nil;
	}
	item = [newItem retain];
	
	if ([item.merchandises count] > 0){
		merchandisesHeaderRowNumber = 3;
		descriptionHeaderRowNumber = 4 + [item.merchandises count];
		rowCount = 8 + [item.merchandises count];
	} else {
		merchandisesHeaderRowNumber = 8;
		descriptionHeaderRowNumber = 3;
		rowCount = 7;
	}
    
    
    
	
	screenshotsHeaderRowNumber = descriptionHeaderRowNumber + 2;
	if (![PNManager sharedObject].isLoggedIn || [item.screenshotUrls count] == 0) {
		rowCount -= 2;
	}
	
	self.title = item.name;
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
	[PNDashboard hideIndicator];
}

#pragma mark -
#pragma mark Table view data source

- (BOOL)isHeaderCell:(NSInteger)row
{
	return row == kCategoryHeaderRowNumber || row == merchandisesHeaderRowNumber || 
	row == descriptionHeaderRowNumber || row == screenshotsHeaderRowNumber;
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int index = indexPath.row;
	
	if (index == 0) return 60.0f;					//Top
	if ([self isHeaderCell:index]) return 25.0f;	//Headers
	if (index == descriptionHeaderRowNumber + 1) return [PNTableViewHelper heightSizeForString:item.description];
	if (index == screenshotsHeaderRowNumber + 1) return [PNTableViewHelper heightSizeForScreenshotsCell:item.screenshotUrls];

	
	return 40.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return rowCount;
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
	cell.textLabel.text = item.name;
	cell.highlightable = NO;	
	
	[cell loadRoundRectImageFromURL:item.iconUrl defaultImageName:@"PNDefaultGameIcon.png" 
						paddingLeft:20.0f top:10.0f right:0.0f bottom:10.0f width:36.0f height:36.0f delegate:self];
	
	
    if ([item isCoin]) {
        item.quantity = [PNUser currentUser].coins;
    } else {
        item.quantity = [[PNItemHistory sharedObject] currentQuantityForItemId:[item stringId]];
    }
	
    [cell setAccessoryText:[PNFormatUtil quantityFormat:item]];
    return cell;
}
- (UITableViewCell *)categoryCellForTableView:(UITableView *)tableView 
{
	static NSString *CellIdentifier = @"CategoryCell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	[cell setBackgroundImage:@"PNInformationBackgroundImage.png"];
	if (item.category != nil) {
		cell.textLabel.text = item.category.name;
		[cell setLeftPadding:10.0f];
		[cell setDetailDisclosureButtonWithDelegate:self selector:@selector(goToCategoryView) tag:0];
	}
	cell.highlightable = NO;
    return cell;
}
- (void)goToCategoryView
{
	PNItemCategoryViewController* detailView = [[[PNItemCategoryViewController alloc] init] autorelease];
	detailView.selectedCategory = item.category;
	[PNDashboard pushViewController:detailView];

}
- (void)showMerchandiseDetail:(UIButton*)sender
{
	PNMerchandise* merchandise = [item.merchandises objectAtIndex:sender.tag];
	PNMerchandiseDetailViewController* detailView = [[[PNMerchandiseDetailViewController alloc] init] autorelease];
	detailView.merchandise = merchandise;
	[PNDashboard pushViewController:detailView];
}
- (void)buyMerchandise:(UIButton*)sender
{
	isBuying = YES;
//	PNMerchandise* merchandise = [item.merchandises objectAtIndex:sender.tag];
	[PNDashboard showModalIndicator];
//	[[PNStoreManager sharedObject] purchaseWithProductIdentifier:merchandise.productIdentifier delegate:self 
//													 onSucceeded:@selector(buyThisItemSucceeded:)
//														onFailed:@selector(buyThisItemFailed:)];
	[self reloadData];
}
- (void)buyThisItemSucceeded:(PNItemOwnershipModel*)ownership
{
	isBuying = NO;
	[PNDashboard hideModalIndicator];
	[PNDashboard updateDashboard];
	[self reloadData];
}
- (void)buyThisItemFailed:(PNError*)error
{
	[PNAlertHelper showAlertForPurchaseFail:error];
	isBuying = NO;
	[PNDashboard hideModalIndicator];
	[PNDashboard updateDashboard];
	[self reloadData];
}
- (UITableViewCell *)merchandiseCellForTableView:(UITableView*)tableView index:(NSInteger)index
{
	PNMerchandise* merchandise = [item.merchandises objectAtIndex:index];
	static NSString *CellIdentifier = @"MerchandiseCell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNInformationBackgroundImage.png"]] autorelease];
	cell.textLabel.text = merchandise.name;
	
	PNSKProduct* productInfo = [[PNStoreManager sharedObject] productWithProductIdentifier:merchandise.productIdentifier];
	if (productInfo) {
		cell.detailTextLabel.text = [PNFormatUtil priceOfProduct:productInfo];
		cell.detailTextLabel.textColor = [UIColor cyanColor];
	}
	
	[cell setLeftPadding:10.0f];
	cell.highlightable = NO;	
	[cell setDetailDisclosureButtonWithDelegate:self 
					   disclosureButtonSelector:@selector(showMerchandiseDetail:) 
						  additionalButtonTitle:@"PNTEXT:ITEMS:Buy" 
					   additionalButtonDelegate:self
					   additionalButtonSelector:@selector(buyMerchandise:)
						additionalButtonEnabled:[PNManager sharedObject].isLoggedIn && [merchandise isBuyable] && !isBuying
											tag:index];
    return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int index = indexPath.row;
	
	if (index == 0) return [self titleCellForTableView:tableView];
	if (index == 2) return [self categoryCellForTableView:tableView];
	if (index == kCategoryHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Category"];
	if (index == merchandisesHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Merchandises"];
	if (index == descriptionHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Description"];
	if (index == screenshotsHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Screenshots"];
	if (index > merchandisesHeaderRowNumber && index < descriptionHeaderRowNumber)
		return [self merchandiseCellForTableView:tableView index:index - merchandisesHeaderRowNumber - 1];
	if (index == descriptionHeaderRowNumber + 1) return [PNItemViewHelper descriptionCellForTableView:tableView item:item];
	if (index == screenshotsHeaderRowNumber + 1) return [PNItemViewHelper screenshotsCellForTableView:tableView item:item];
	
	return nil;	//Should not reach here.
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

