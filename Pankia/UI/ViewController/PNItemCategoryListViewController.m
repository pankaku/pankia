//
//  PNItemCategoryListViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemCategoryListViewController.h"
#import "PNStoreManager.h"
#import "PNItemManager.h"
#import "PNItemCategory.h"
#import "PNGlobal.h"
#import "PNItem.h"
#import "PNImageUtil.h"
#import "PNItemCategoryViewController.h"
#import "PNDashboard.h"
#import "PNLocalizedString.h"
#import "PNTableCell.h"
 
#import "PNGameManager.h"

@implementation PNItemCategoryListViewController


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = getTextFromTable(@"PNTEXT:ITEMS:Store");

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[PNDashboard hideIndicator];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[PNGameManager sharedObject] categories] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
    static NSString *CellIdentifier = @"Cell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	PNItemCategory *category = [[[PNGameManager sharedObject] categories] objectAtIndex:indexPath.row];
	cell.textLabel.text = category.name;
	cell.textLabel.font = [UIFont fontWithName:kPNDefaultFontName size:13.0f];
	
	PNItem* firstItem = [category firstItem];
	NSString* iconUrl = (firstItem != nil) ? firstItem.iconUrl : nil;
	[cell loadRoundRectImageFromURL:iconUrl defaultImageName:@"PNDefaultLobbyIcon.png" 
						paddingLeft:20.0f top:10.0f right:0.0f bottom:10.0f width:57.0f height:57.0f delegate:self];
	[cell setArrowAccessoryWithText:[NSString stringWithFormat:@"%d", [category merchandiseCount]]];
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PNItemCategory* category = [[[PNGameManager sharedObject] categories] objectAtIndex:indexPath.row];
	PNItemCategoryViewController *detailViewController = [[[PNItemCategoryViewController alloc] init] autorelease];
	detailViewController.selectedCategory = category;
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
    [super dealloc];
}


@end

