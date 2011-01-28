#import "PNLeaderboardsViewController.h"
#import "PNLeaderboardsSelectViewController.h"
#import "PNHighScoreViewController.h"
#import "PNControllerLoader.h"
#import "PNLeaderboard.h"
#import "PankiaNetworkLibrary+Package.h"
 
#import "PNDashboard.h"
#import "PNTableViewHelper.h"

#import "PNGameManager.h"

@interface PNLeaderboardsViewController ()
@property (retain) NSArray*					leaderboards;
@end

@implementation PNLeaderboardsViewController
@synthesize leaderboards;

- (void)viewDidLoad {
	PNLogMethodName;
    [super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	self.leaderboards = [[PNGameManager sharedObject] leaderboards];
}

- (void)viewWillAppear:(BOOL)animated {
	PNLogMethodName;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	PNLogMethodName;
    [super viewDidAppear:animated];
	[PNDashboard hideIndicator];
}

- (void)didReceiveMemoryWarning {
	PNLogMethodName;
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	PNLogMethodName;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.leaderboards = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.leaderboards != nil) {
		return [self.leaderboards count];
	} else {
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PNLeaderboard* leaderboard = [self.leaderboards objectAtIndex:indexPath.row];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return [PNTableViewHelper leaderboardCellForTableView:tableView leaderboard:leaderboard delegate:self];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PNLeaderboard* lbData = [self.leaderboards objectAtIndex:indexPath.row];
	
	if ([lbData.type compare:kPNLeaderboardTypeGrade] == NSOrderedSame) {
		PNLeaderboardsSelectViewController* controller = (PNLeaderboardsSelectViewController*)[PNControllerLoader load:@"PNLeaderboardsSelectViewController" filesOwner:nil];
		PNLeaderboard* lbData = [self.leaderboards objectAtIndex:indexPath.row];
		[controller setViewTitle:lbData.name];
		controller.leaderboardId = lbData.leaderboardId;
		[PNDashboard pushViewController:controller];		
	}
	else {
		PNHighScoreViewController*	controller = (PNHighScoreViewController*)[PNControllerLoader load:@"PNHighScoreViewController" filesOwner:nil];
		controller.scope = kPNLeaderboardPeriodOverall;
		PNLeaderboard* lbData = [self.leaderboards objectAtIndex:indexPath.row];
		[controller setViewTitle:lbData.name];
		controller.leaderboardId = lbData.leaderboardId;
		controller.leaderboardType = kPNLeaderboardTypeCustom;
		[PNDashboard pushViewController:controller];
	}
}

- (void)dealloc {
	PNLogMethodName;
	self.leaderboards = nil;
    [super dealloc];
}

@end
