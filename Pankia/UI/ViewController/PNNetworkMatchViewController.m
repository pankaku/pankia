//
//  PNNetworkMatchViewController.m
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PankiaNetworkLibrary+Package.h"
#import "PNNetworkMatchViewController.h"
#import "PNLocalRoomsViewController.h"
#import "PNMatchUpViewController.h"
#import "PNControllerLoader.h"
#import "PNDashboard.h"
#import "PNGlobal.h"
#import "PNGlobalManager.h"
#import "PNImageUtil.h"
 
#import "PNLogger.h"

#define DEFAULT_USER_NAME @"Player"

typedef enum {
	USER_STATUS, 
	INTERNET_MATCH, 
	NEARBY_MATCH
} PNetworkMatchCategories;

@implementation PNNetworkMatchViewController

@synthesize networkMatchCell_;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	self.title = getTextFromTable(@"PNTEXT:UI:Network_Match");
	dataSource_	  = [[NSArray alloc] initWithObjects:@"UserStatus", @"InternetMatch", @"NearbyMatch", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[PNDashboard hideIndicator];
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [dataSource_ count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	// 1番上のセルではProfileやGradeGaugeを挿入するようにします。
	if (indexPath.row == USER_STATUS) {
		NSString* identifier =
		[NSString stringWithFormat:@"PNNetworkMatchCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNNetworkMatchCell* cell = (PNNetworkMatchCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = networkMatchCell_;
			self.networkMatchCell_ = nil;
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		
		PNUser* user = [PNUser currentUser];
		
		[cell setUserName:user.username];
		[cell setFlagImageForCountryCode:user.countryCode];
		[cell setAchievementPoint:[NSString stringWithFormat:@"%d/%d", user.achievementPoint, user.achievementTotal]];
		[cell setIcon:[UIImage imageNamed:@"PNDefaultUserIcon.png"]];
		[cell.headIcon loadImageOfUser:user];
		
		NSString* gradeName = user.gradeName;
		[cell setGradeEnabled:user.gradeEnabled];
		[cell setGradeName:gradeName];
		[cell setGradePoint:[NSString stringWithFormat:@"%d", user.gradePoint]];
		[cell setMyCoin];
		
		return cell;
	}
	else {
		static NSString* identifier = @"default-cell";
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:identifier];
			[cell autorelease];
		}
		cell.textLabel.textColor	= [UIColor whiteColor];
		cell.textLabel.shadowColor  = [UIColor blackColor];
		cell.textLabel.shadowOffset = CGSizeMake(0, 1);
		cell.selectionStyle		 = UITableViewCellSelectionStyleNone;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		
		UIView *accessoryImageView = [[[UIView alloc] init] autorelease];
		UIImageView *arrowImage	   = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNCellArrowImage.png"]] autorelease];
		[accessoryImageView addSubview:arrowImage];
		[accessoryImageView setFrame:CGRectMake(0.0f, 0.0f, 20.0f, 15.0f)];
		
		if (indexPath.row == INTERNET_MATCH) {
			cell.textLabel.font	 = [UIFont fontWithName:kPNDefaultFontName
												   size:14.0f];
			cell.textLabel.text	 = getTextFromTable(@"PNTEXT:UI:Internet_Match");
			cell.imageView.image = [PNImageUtil imageWithPadding:[UIImage imageNamed:@"PNInternetMatchIcon.png"]
															left:10.0f top:0.0f right:0.0f bottom:0.0f width:80.0f height:80.0f];	
			cell.accessoryView   = accessoryImageView;
		}
		else if (indexPath.row == NEARBY_MATCH) {
			cell.textLabel.font	 = [UIFont fontWithName:kPNDefaultFontName
												   size:14.0f];
			cell.textLabel.text	 = getTextFromTable(@"PNTEXT:UI:Nearby_Match");
			cell.imageView.image = [PNImageUtil imageWithPadding:[UIImage imageNamed:@"PNNearbyMatchIcon.png"]
															left:10.0f top:0.0f right:0.0f bottom:0.0f width:80.0f height:80.0f];
			cell.accessoryView   = accessoryImageView;
		}
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	UIImage* backgroundImage;
	if (indexPath.row == USER_STATUS) {
		backgroundImage = [UIImage imageNamed:kPNCellInfoBackgroundImage];
	}
	else {
		backgroundImage = [UIImage imageNamed:kPNCellBackgroundImage];
	}
	cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == INTERNET_MATCH) {
//		[[PNDashboard sharedObject] showInternetMatchTopPage];
		PNMatchUpViewController* controller =
		(PNMatchUpViewController*)[PNControllerLoader load:@"PNMatchUpViewController" filesOwner:nil];
		[PNDashboard pushViewController:controller];
	}
	else if (indexPath.row == NEARBY_MATCH) {
//		[[PNDashboard sharedObject] showNearbyMatchTopPage];
		PNCLog(PNLOG_CAT_LOCALMATCH, @"Local Rooms View!!!");
		if (kPNSelectionOfTheLocalRoomUse) {
			PNLocalRoomsViewController* controller =
			(PNLocalRoomsViewController*)[PNControllerLoader load:@"PNLocalRoomsViewController" filesOwner:nil];
			[PNDashboard pushViewController:controller];
		}
		else {
			[PNDashboard pushViewControllerNamed:@"PNJoinedLocalRoomViewController"];
		} 
	}
}	



- (void)dealloc {
	networkMatchCell_ = nil;
	[dataSource_ release];
    [super dealloc];
}

@end
