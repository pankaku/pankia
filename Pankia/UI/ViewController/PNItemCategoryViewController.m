//
//  PNItemCategoryViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemCategoryViewController.h"
#import "PNStoreManager.h"
#import "PNItemManager.h"
#import "PNDashboard.h"
#import "PNItem.h"
#import "PNItemCategory.h"
#import "PNMerchandiseDetailViewController.h"
#import "PNLocalizedString.h"
#import "PNTableCell.h"
#import "PNGlobal.h"
#import "PNFormatUtil.h"
#import "PNItemCategorySelectCell.h"
 
#import "PNGameManager.h"
#import "PNMerchandise.h"

@interface PNItemCategoryViewController ()
@property (nonatomic, retain) NSArray* merchandises;
@property (nonatomic, retain) NSMutableDictionary *merchandisesInCategories;
@property (nonatomic, retain) NSMutableDictionary *priceDictionary;
@property (nonatomic, retain) NSArray* categories;
@end

@implementation PNItemCategoryViewController
@synthesize merchandises, selectedCategory, merchandisesInCategories, priceDictionary, categories;

#pragma mark -
#pragma mark View lifecycle

- (void)resetData
{
	self.merchandisesInCategories = [NSMutableDictionary dictionary];
	self.priceDictionary = [NSMutableDictionary dictionaryWithDictionary:[PNStoreManager sharedObject].productDetails];
	for (PNItemCategory* category in [[PNGameManager sharedObject] categories]) {
		[self.merchandisesInCategories setObject:[NSMutableArray array] forKey:category.id];
	}
}
- (void)viewDidLoad {
    [super viewDidLoad];
	[self resetData];
	self.title = getTextFromTable(@"PNTEXT:ITEMS:Store");
	
	self.categories = [[PNGameManager sharedObject] categories];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[self resetData];
	self.merchandises = [[PNGameManager sharedObject] merchandises];
	
	NSMutableArray* productIdentifiers = [NSMutableArray array];
	for (PNMerchandise* merchandise in merchandises) {
		PNItemCategory* category = merchandise.item.category;
		if (category != nil && category.id != nil) {
			NSMutableArray* merchandisesInCategory = [merchandisesInCategories objectForKey:category.id];
			[merchandisesInCategory addObject:merchandise];
			
			[productIdentifiers addObject:merchandise.productIdentifier];
		}
	}
	[self reloadData];
	
	[PNDashboard hideIndicator];
	
	if ([priceDictionary count] > 0 || ![[PNStoreManager sharedObject] getDetailOfProducts:productIdentifiers delegate:self 
																			   onSucceeded:@selector(getProductDetailsSucceeded:)
																				  onFailed:@selector(getProductDetailsFailed:)]) {
		
	}
}
- (void)getProductDetailsSucceeded:(NSArray*)products
{
	for (SKProduct* product in products) {
		[priceDictionary setObject:product forKey:product.productIdentifier];
	}
	[PNDashboard hideIndicator];
	[self reloadData];
}

- (void)getProductDetailsFailed:(id)object {
	PNWarn(@"getDetailsError");
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
	
	
    return [[merchandisesInCategories objectForKey:selectedCategory.id] count] + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row > 0) {		
		static NSString *CellIdentifier = @"Cell";
		
		PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		PNMerchandise* merchandise = [[merchandisesInCategories objectForKey:selectedCategory.id] objectAtIndex:indexPath.row - 1];
		cell.textLabel.text = merchandise.name;
		cell.textLabel.font = [UIFont fontWithName:kPNDefaultFontName size:13.0f];
		PNItem* firstItem = [PNItem itemWithId:[merchandise.item_id intValue]];
		NSString* iconUrl = (firstItem != nil) ? firstItem.iconUrl : nil;
		[cell loadRoundRectImageFromURL:iconUrl defaultImageName:@"PNDefaultLobbyIcon.png" 
							paddingLeft:20.0f top:10.0f right:0.0f bottom:10.0f width:57.0f height:57.0f delegate:self];
		
		SKProduct* productInfo = [priceDictionary objectForKey:merchandise.productIdentifier];
		
		NSString* price = (productInfo != nil) ? 
			[PNFormatUtil priceFormat:[productInfo.price floatValue] locale:[productInfo.priceLocale objectForKey:NSLocaleCurrencyCode]]: @"";
		[cell setArrowAccessoryWithText:price];
		return cell;
	} else {
		static NSString *CellIdentifier = @"PNItemCategorySelectCell";
		
		PNItemCategorySelectCell *cell = (PNItemCategorySelectCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[PNItemCategorySelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.delegate = self;
		cell.selectedCategory = selectedCategory;

		return cell;
	}
}

- (void)moveCategory:(int)forward
{
	
	// カテゴリが一つしかなかったら、なにもしません
	if ([categories count] <= 1) return;
	
	int currentIndex = [categories indexOfObject:selectedCategory];
	int nextIndex = (currentIndex + forward) % [categories count];
	
	NSLog(@"[%d]categories. current:%d move: %d -- %d",[categories count], currentIndex, forward, nextIndex);
	self.selectedCategory = [categories objectAtIndex:nextIndex];
	[self reloadData];
}
- (void)selectNext:(id)sender
{
	[self moveCategory:1];
}
- (void)selectPrevious:(id)sender
{
	[self moveCategory:-1];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row > 0) {
		PNMerchandise* merchandise = [[merchandisesInCategories objectForKey:selectedCategory.id] objectAtIndex:indexPath.row - 1];
		
		// Navigation logic may go here. Create and push another view controller.
		PNMerchandiseDetailViewController* detailViewController = [[[PNMerchandiseDetailViewController alloc] init] autorelease];
		detailViewController.title = merchandise.name;
		detailViewController.merchandise = merchandise;
		[PNDashboard pushViewController:detailViewController];
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
	self.merchandises = nil;
	self.merchandisesInCategories = nil;
	self.priceDictionary = nil;
	self.categories = nil;
    [super dealloc];
}


@end

