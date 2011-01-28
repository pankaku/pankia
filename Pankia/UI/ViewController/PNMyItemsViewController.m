//
//  PNMyItemsViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMyItemsViewController.h"
#import "PNLocalizedString.h"
#import "PNItemManager.h"
#import "PNDashboard.h"
#import "PNItemCategory.h"
#import "PNItemOwnershipModel.h"
#import "PNItem.h"
#import "PNTableCell.h"
#import "PNLocalizableLabel.h"
#import "PNGlobal.h"
#import "PNFormatUtil.h"
#import "PNGameManager.h"

#import "PNItemDetailViewController.h"
#import "PNItemHistory.h"

#import "PNStoreManager.h"
 

@interface PNMyItemsViewController ()
@property (nonatomic, retain) NSArray* categories;
@property (nonatomic, retain) NSMutableDictionary* ownItemsInCategories;
- (void)getItemOwnershipsSucceeded:(NSDictionary*)ownerships;
@end

@implementation PNMyItemsViewController
@synthesize categories, ownItemsInCategories;

#pragma mark -
#pragma mark View lifecycle

- (void)resetData
{
	self.title = getTextFromTable(@"PNTEXT:ITEMS:Items");
	self.categories = [[PNGameManager sharedObject] categories];
	self.ownItemsInCategories = [NSMutableDictionary dictionary];
	
	for (PNItemCategory* category in categories) {
		[self.ownItemsInCategories setObject:[NSMutableArray array] forKey:category.id];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self resetData];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[PNDashboard hideIndicator];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[PNDashboard showIndicator];
	loading = YES;
	[[PNItemManager sharedObject] getItemOwnershipsFromServerWithOnSuccess:^(NSDictionary *ownerships) {
		[self getItemOwnershipsSucceeded:ownerships];
	} onFailure:^(PNError *error) {
		NSLog(@"error");
	}];
	[self reloadData];
}
- (void)viewDidDisappear:(BOOL)animated {
}

#pragma mark -

- (void)getItemOwnershipsSucceeded:(NSDictionary*)ownerships
{
	[self resetData];
	for (PNItemCategory* category in categories) {
		for (PNItem *item in [category items]) {
			PNItemOwnershipModel* ownership = [ownerships objectForKey:[item stringId]];
			if (ownership) {
				NSMutableArray* ownershipsInCategory = [ownItemsInCategories objectForKey:category.id];
				item.quantity = ownership.quantity;
                [[PNItemHistory sharedObject] updateOwnership:ownership];
				[ownershipsInCategory addObject:item];
			}
		}
	}
	loading = NO;
	[self reloadData];
	[PNDashboard hideIndicator];
}
- (void)getItemOwnershipsFailed:(PNError*)error
{
	loading = NO;
	[PNDashboard hideIndicator];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (categories != nil) {
		return [categories count];
	} else {
		return 0;
	}
}
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
	if (categories != nil && [categories count] > section) {
		PNItemCategory* category = [categories objectAtIndex:section];
		return category.name;
	} else {
		return @" ";
	}

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (categories != nil && [categories count] > section) {
		PNItemCategory* category = [categories objectAtIndex:section];
		NSArray* itemsInCategory = [ownItemsInCategories objectForKey:category.id];
		return [itemsInCategory count];
	} else {
		return 0;
	}

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (categories != nil && [categories count] > indexPath.section) {		
		PNItemCategory* category = [categories objectAtIndex:indexPath.section];
		NSArray* items = [ownItemsInCategories objectForKey:category.id];
		
		if (items != nil && [items count] > indexPath.row) {
			PNItem* item = [items objectAtIndex:indexPath.row];
			
			cell.textLabel.text = item.name;
			cell.detailTextLabel.text = item.excerpt;
			[cell setFontSize:13.0f];
			[cell loadRoundRectImageFromURL:item.iconUrl defaultImageName:@"PNDefaultGameIcon.png" 
								paddingLeft:20.0f top:10.0f right:0.0f bottom:10.0f width:57.0f height:57.0f delegate:self];
			[cell setArrowAccessoryWithText:[PNFormatUtil quantityFormat:item]];
		}
    } else {
		cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"";
		[cell loadRoundRectImageFromURL:nil defaultImageName:@"PNDefaultGameIcon.png" 
							paddingLeft:20.0f top:10.0f right:0.0f bottom:10.0f width:57.0f height:57.0f delegate:self];
		[cell setArrowAccessoryWithText:@""];
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 20.0f;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)] autorelease];
	UIImage* backgroundImage = [UIImage imageNamed:@"PNHeaderCellBackgroundImage.png"];
	UIImageView* headerBackground = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
	headerBackground.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
	[headerView addSubview:headerBackground];
	
	PNItemCategory* category = [categories objectAtIndex:section];
	PNLocalizableLabel* label = [[[PNLocalizableLabel alloc]  initWithFrame:CGRectMake(20, 0, tableView.bounds.size.width, 20)] autorelease];
	label.text = category.name;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont fontWithName:kPNDefaultFontName size:11.0f];
	
	[headerView addSubview:label];
	return headerView;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (loading) return;	//ロード中は無視します
	if (categories != nil && [categories count] > indexPath.section) {
		PNItemCategory* category = [categories objectAtIndex:indexPath.section];
		NSArray* items = [ownItemsInCategories objectForKey:category.id];
		
		if (items != nil && [items count] > indexPath.row) {
			PNItem* item = [items objectAtIndex:indexPath.row];
			
			PNItemDetailViewController* detailViewController = [[[PNItemDetailViewController alloc] init] autorelease];
			detailViewController.item = item;
			[PNDashboard pushViewController:detailViewController];
		}
	}
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
	self.categories = nil;
	self.ownItemsInCategories;
    [super dealloc];
}


@end

