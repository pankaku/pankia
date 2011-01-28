    //
//  PNLobbyViewController.m
//  PankakuNet
//
//  Created by pankaku on 10/08/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLobbyViewController.h"

#import "PNImageUtil.h"
#import "PNMatchUpViewController.h"
#import "PNLocalMatchViewController.h"
#import "PNDashboard.h"
#import "PNControllerLoader.h"
 
#import "PNLobbyViewCell.h"

#import "PNGameManager.h"
#import "PNLogger.h"


@interface PNLobbyViewController ()
- (UITableViewCell *)tableView:(UITableView *)tableView cellForLobby:(PNLobby *)lobby;
@end


@implementation PNLobbyViewController

@synthesize availableLobbies;
@synthesize matchType;
@synthesize headerCell_;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	self.availableLobbies = [[PNGameManager sharedObject] lobbies];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[PNDashboard hideIndicator];
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



#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if (self.availableLobbies == nil) {
		return 0;
	}
	else {
		if (matchType == kPNInternetMatch)
			return [self.availableLobbies count] + 1;	// ヘッダ部分をひとつ追加します。
		else
			return [self.availableLobbies count];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (matchType == kPNInternetMatch) {
		if (indexPath.row == 0)
			return 40.0f;
		else 
			return 80.0f;
	}
	else {
		return 80.0f;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == 0) {
		NSString* identifier =
		[NSString stringWithFormat:@"PNHeaderCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNHeaderCell* cell = (PNHeaderCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = headerCell_;
			self.headerCell_ = nil;
		}
		cell.backgroundView =
		[[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNCellInfoBackgroundImage]] autorelease];
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		[cell setMyCoin];
		return cell;
	}
	else {
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		return [self tableView:tableView cellForLobby:[self.availableLobbies objectAtIndex:indexPath.row - 1]];
	}
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return; 
	}

	PNLobby *lobbyToJoin = [availableLobbies objectAtIndex:indexPath.row - 1];
	switch (matchType) {
		case kPNInternetMatch: {
			PNMatchUpViewController *controller =
			(PNMatchUpViewController *)[PNControllerLoader load:@"PNMatchUpViewController" 
													 filesOwner:self];
			controller.lobby = lobbyToJoin;
			controller.title = controller.lobby.name;
			[PNDashboard pushViewController:controller];
			break;
		}
		case kPNNearbyMatch: {
			PNLocalMatchViewController *controller =
			(PNLocalMatchViewController *)[PNControllerLoader load:@"PNLocalMatchViewController" 
														filesOwner:self];
			controller.lobby_ = lobbyToJoin;
			controller.title = controller.lobby_.name;
			[PNDashboard pushViewController:controller];
			break;
		}
		default:
			break;
	}
}



#pragma mark -
#pragma mark Class extension

- (UITableViewCell *)tableView:(UITableView *)tableView cellForLobby:(PNLobby *)lobby {

	static NSString *identifier = @"PNLobbyCell";
	PNLobbyViewCell *cell = (PNLobbyViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[PNLobbyViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:identifier
											 withLobby:lobby] autorelease];
	}
	return cell;
}

- (void)dealloc {
	self.availableLobbies	= nil;
	self.headerCell_		= nil;
    [super dealloc];
}

@end
