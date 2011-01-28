//
//  PNLeaderboardsSelectViewController.m
//  PankiaNet
//
//  Created by nakashima on 10/02/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLeaderboardsSelectViewController.h"
#import "PNHighScoreViewController.h"
#import "PNControllerLoader.h"
#import "PNDashboard.h"
#import "PankiaNetworkLibrary.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNTableViewHelper.h"
#import "PNLeaderboard.h"

@implementation PNLeaderboardsSelectViewController

@synthesize rankings,leaderboardId, viewTitle;

- (void)awakeFromNib {
	PNLogMethodName;
	[super awakeFromNib];
}

- (void)viewDidLoad {
	PNLogMethodName;
    [super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	//leaderboardId = kPNDefaultLeaderboardID;
	// Load the data.
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"LeaderboardsData" ofType:@"plist"];	
    NSArray* tmparr = [NSArray arrayWithContentsOfFile:dataPath];
	self.rankings  = [tmparr objectAtIndex:0];
	
}

- (void)viewWillAppear:(BOOL)animated {
	PNLogMethodName;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	PNLogMethodName;
    [super viewDidAppear:animated];
	[self reloadData];
	[PNDashboard hideIndicator];
}

- (void)viewWillDisappear:(BOOL)animated {
	PNLogMethodName;
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	PNLogMethodName;
	[super viewDidDisappear:animated];
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
}

- (void)setViewTitle:(NSString *)title {
	PNLogMethodName;
	viewTitle = title;
	[self setTitle:viewTitle];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	PNLogMethodName;
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	PNLogMethodName;
    return [self.rankings count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
    PNLeaderboard* leaderboard = [[[PNLeaderboard alloc] init] autorelease];
    leaderboard.name = [self.rankings objectAtIndex:indexPath.row];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return [PNTableViewHelper leaderboardCellForTableView:tableView leaderboard:leaderboard delegate:self];			
	
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;

	PNHighScoreViewController*	controller = (PNHighScoreViewController*)[PNControllerLoader load:@"PNHighScoreViewController" filesOwner:nil];
	controller.scope = indexPath.row;
	controller.leaderboardId = leaderboardId;
	[controller setViewTitle:[self.rankings objectAtIndex:indexPath.row]];
	controller.leaderboardType = kPNLeaderboardTypeGrade;
	[PNDashboard pushViewController:controller];
	
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
	
}

- (void)dealloc {
	PNLogMethodName;
	self.rankings = nil;
	self.viewTitle = nil;

    [super dealloc];
}

@end
