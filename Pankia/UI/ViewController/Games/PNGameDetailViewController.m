//
//  PNGameDetailViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGameDetailViewController.h"
#import "PNDashboard.h"
#import "PNTableCell.h"
#import "PNGame.h"

#import "PNTableViewHelper.h"

#import "PNGameManager.h"

#import "PNGameModel.h"
#import "PNUserModel.h"

#import "PNLocalizedString.h"

#import "PNManager.h"

static const int kDescriptionHeaderRowNumber = 1;
static const int kWhosPlayingHeaderRowNumber = 3;

@implementation PNGameDetailViewController
@synthesize game, followees;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.followees = [NSArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[PNDashboard hideIndicator];
	
	loading = YES;
	[[PNGameManager sharedObject] getDetailsOfGame:game.gameId delegate:self onSucceeded:@selector(gameDetailUpdated:)
										  onFailed:nil];
}

- (void)gameDetailUpdated:(PNGameModel*)gameModel
{
	game.description = gameModel.description;
	game.screenshotUrls = gameModel.screenshot_urls;
	game.thumbnailUrls = gameModel.thumbnail_urls;
	game.iTunesUrl = gameModel.iTunesURL;
	game.developerName = gameModel.developer_name;
	game.price = gameModel.price;

#ifdef DEBUG
//	game.developerName	= @"Test Developer";
//	game.price = @"0";
#endif
	self.followees = gameModel.followees;
	loading = NO;
	rowCount = 6;
	
	if ([followees count] >= 1) {
		rowCount += [followees count];
		screenshotsHeaderRowNumber = kWhosPlayingHeaderRowNumber + [followees count] + 1;
	} else {
		screenshotsHeaderRowNumber = kWhosPlayingHeaderRowNumber+ 2;
		rowCount += 1;
	}	
	
	if (![PNManager sharedObject].isLoggedIn || [game.screenshotUrls count] == 0){
		rowCount -= 2;
	}
	
	[self reloadData];
}

- (NSString*)gameDescription
{
	return loading ? @" " : game.description;
}

#pragma mark -
#pragma mark Table view data source

- (BOOL)isHeaderCell:(NSInteger)row
{
	return row == kDescriptionHeaderRowNumber || row == kWhosPlayingHeaderRowNumber || row == screenshotsHeaderRowNumber;
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int index = indexPath.row;
	
	if (index == 0) return 80.0f;					//Top
	if ([self isHeaderCell:index]) return 25.0f;	//Headers
	if (index == kDescriptionHeaderRowNumber + 1) return [PNTableViewHelper heightSizeForString:[self gameDescription]];
	if (index == screenshotsHeaderRowNumber + 1) return [PNTableViewHelper heightSizeForScreenshotsCell:game.screenshotUrls];
	
	return 40.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return rowCount;
}

#pragma mark -

- (void)buyThisSoft
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:game.iTunesUrl]];
}

- (UITableViewCell *)titleCellForTableView:(UITableView *)tableView 
{
	static NSString *CellIdentifier = @"TitleCell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNCellBackgroundImage80.png"]] autorelease];
    // Configure the cell...
	cell.textLabel.text = game.gameTitle;
	cell.highlightable = NO;	
	
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.textColor = [UIColor whiteColor];
	
	BOOL isFree = (game.price == nil || [game.price isEqualToString:@"0"]);
	
	if (game.iTunesUrl != nil) {
		[cell setAccessoryButtonWithDelegate:self selector:@selector(buyThisSoft) title:isFree ? @"PNTEXT:COMMON:Install" : @"PNTEXT:ITEMS:Buy" enabled:YES tag:0];
	}
	
	NSMutableString* detailText = [NSMutableString string];
	
	if (game.developerName != nil) {
		[detailText appendString:game.developerName];
	}
	
//	if (game.price != nil && ![game.price isEqualToString:@"0"]) {
//		NSLog(@"price: %@", game.price);
//	} else {
//		NSLog(@"free ");
//	}
	NSString* priceString = game.price != nil ? (isFree ? getTextFromTable(@"PNTEXT:COMMON:FREE") : game.price) : @" ";
	if ([detailText length] > 0) {
		[detailText appendFormat:@"\n%@", priceString];
	} else {
		[detailText appendString:priceString];
	}

	cell.detailTextLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.numberOfLines = 2;
	cell.detailTextLabel.text = detailText;

	[cell loadRoundRectImageFromURL:game.iconUrl defaultImageName:@"PNDefaultGameIcon.png" 
						paddingLeft:20.0f top:10.0f right:0.0f bottom:10.0f width:36.0f height:36.0f delegate:self];

    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForWhosPlayingAtIndex:(NSInteger)index
{
	// dummy
	NSString* CellIdentifier = @"whosplayingcell";
	PNTableCell* cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNInformationBackgroundImage.png"]] autorelease];
	
	if ([followees count] > 0){
		PNUserModel* user = [followees objectAtIndex:index];
		cell.textLabel.text = user.username;
	} else {
		cell.textLabel.text = getTextFromTable(@"PNTEXT:APP_DETAIL:No_one_is_playing_this_game.");
	}
	[cell setLeftPadding:10.0f];
	return cell;	
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int index = indexPath.row;
	
	if (index == 0) return [self titleCellForTableView:tableView];
	if (index == kDescriptionHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Description"];
	if (index == kWhosPlayingHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:WhosPlaying"];
	if (index == screenshotsHeaderRowNumber) return [PNTableViewHelper headerCellForTableView:tableView title:@"PNTEXT:COMMON:Screenshots"];
	if (index == kDescriptionHeaderRowNumber+1) return [PNTableViewHelper descriptionCellForTableView:tableView description:[self gameDescription]];
	if (index == screenshotsHeaderRowNumber+1) return [PNTableViewHelper screenshotsCellForTableView:tableView urls:game.screenshotUrls thumbnailUrls:game.thumbnailUrls];
	if (index > kWhosPlayingHeaderRowNumber && index < screenshotsHeaderRowNumber) return [self tableView:tableView cellForWhosPlayingAtIndex:index - kWhosPlayingHeaderRowNumber - 1];
	
	return nil;
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
	self.game = nil;
	self.followees = nil;
}

- (void)dealloc {
	[priceLabel release];
    [super dealloc];
}

@end
