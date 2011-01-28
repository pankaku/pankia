//
//  PNMatchUpViewController.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNMatchUpViewController.h"
#import "PNControllerLoader.h"
#import "PNImageUtil.h" 
#import "PNDashboard.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PankiaNet+Package.h"
#import "PNRoomsViewController.h"
#import "PNQuickMatchViewController.h"
#import "Reachability.h"
#import "PNGlobal.h"


typedef enum {
	HEADER_CELL,
	ALL_ROOMS,
	INVITED_ROOMS
} PNMatchUpCellCategories;


@implementation PNMatchUpViewController
@synthesize lobby;
@synthesize headerCell_;


// The designated initializer.
// Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void) awakeFromNib{
	[super awakeFromNib];
	UIBarButtonItem* rightItem =
	[[[UIBarButtonItem alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:MENU:Quick_Match")
									  style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(quickMatchButtonDidPush)] autorelease];
	self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	dataSource_	  = [[NSArray alloc] initWithObjects:@"Header", @"AllRooms", @"Invited Rooms", nil];
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

- (void)viewDidAppear:(BOOL)animated {
	
	PNUser* selfUser = [PNUser currentUser];
	PNNATType natType = selfUser.natType;
	if(natType == kPNSymmetricNAT || natType == kPNUnknownNAT) {
		NSString* message;
		if (natType == kPNSymmetricNAT) {
			if([Reachability isConnectedWifi]) {
				message = getTextFromTable(@"PNTEXT:NAT_CHECK:message_symmetric");
			}
			else {
				message = getTextFromTable(@"PNTEXT:NAT_CHECK:message_symmetric_on_3g");
			}
		} 
		else {
			message = getTextFromTable(@"PNTEXT:NAT_CHECK:message_unknown");
		}
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:NAT_CHECK:title") 
											   message:message 
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil
									  onCancelSelected:nil
											  delegate:self];
		[PNDashboard sharedObject].isAvailableNatType = NO;
		[PNDashboard popViewController];
	}
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if (dataSource_ == nil) {
		return 0;
	}
	else {
		return [dataSource_ count];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == 0) {
		return 40.0f;
	}
	else {
		return 80.0f;
	}
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString* identifier = @"Standard";
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
	
	if (indexPath.row == HEADER_CELL) {
		NSString* identifier =
		[NSString stringWithFormat:@"PNMatchUpHeaderCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNHeaderCell* cell = (PNHeaderCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = headerCell_;
			self.headerCell_ = nil;
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		[cell setMyCoin];
		return cell;
	}
	else if (indexPath.row == ALL_ROOMS) {
		cell.textLabel.font	= [UIFont fontWithName:kPNDefaultFontName
											  size:14.0f];
		cell.textLabel.text	= @"All Rooms";
		cell.imageView.image = [PNImageUtil imageWithPadding:[UIImage imageNamed:@"PNRoomsIcon.png"]
														left:10.0f top:0.0f right:0.0f bottom:0.0f width:80.0f height:80.0f];
		cell.accessoryView  = accessoryImageView;
	}
	else {
		cell.textLabel.font	= [UIFont fontWithName:kPNDefaultFontName
											  size:14.0f];
		cell.textLabel.text	= @"Invited Rooms";
		cell.imageView.image = [PNImageUtil imageWithPadding:[UIImage imageNamed:@"PNInvitedRoomsIcon.png"]
														left:10.0f top:0.0f right:0.0f bottom:0.0f width:80.0f height:80.0f];
		cell.accessoryView  = accessoryImageView;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == ALL_ROOMS) {
		PNRoomsViewController* controller =
		(PNRoomsViewController*)[PNControllerLoader load:@"PNRoomsViewController"
											  filesOwner:nil];
		controller.lobby = self.lobby;
		[PNDashboard pushViewController:controller];
	}
	else if (indexPath.row == INVITED_ROOMS) {
		PNLog(@"Start Invited Room !!!");
		[PNDashboard pushViewControllerNamed:@"PNInvitedRoomsViewController"];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	UIImage* backgroundImage;
	if (indexPath.row == HEADER_CELL) {
		backgroundImage = [UIImage imageNamed:kPNCellInfoBackgroundImage];
	}
	else {
		backgroundImage = [UIImage imageNamed:kPNCellBackgroundImage];
	}
	cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
}

- (void)onOKSelected {
}

- (void)dealloc {
	[dataSource_ release];
	self.lobby			= nil;
	self.headerCell_	= nil;
    [super dealloc];
}



#pragma mark button action

- (void)quickMatchButtonDidPush {
	PNQuickMatchViewController* controller =
	(PNQuickMatchViewController*)[PNControllerLoader load:@"PNQuickMatchViewController"
											   filesOwner:nil];
	controller.lobby = lobby;
	[PNDashboard pushViewController:controller];
}

@end
