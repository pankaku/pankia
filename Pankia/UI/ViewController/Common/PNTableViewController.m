//
//  PNTableViewController.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNTableViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNControllerLoader.h"
#import "PNTableCell.h"
#import "PNMyLocalRoomActionCell.h"
#import "PNHighScoreCell.h"
#import "PankiaNet+Package.h"
#import "PNDashboard.h"


@implementation PNTableViewController


- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight		= 50.0f;
	self.view.backgroundColor		= [UIColor clearColor];
	self.tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)setBackgroundImage:(UITableViewCell *)cell {
	UIImage* backgroundImage	= [UIImage imageNamed:kPNCellBackgroundImage];
	UIView*  cellBackgroundView = [[[UIView alloc] init] autorelease];
	cellBackgroundView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
	cell.backgroundView = cellBackgroundView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	
}



#pragma mark Table view methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)dismissDashboard:(UIButton *)button {
	[PankiaNet dismissDashboard];
}

- (void)reloadData {
	if ([self.view respondsToSelector:@selector(reloadData)]) {
		[self.view performSelector:@selector(reloadData)];
	}
	[self.tableView reloadData];
}

- (NSString*)cellIdentifierName:(NSString*)prefix {
	return [prefix stringByAppendingString:([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
}

- (UITableViewCell*)cellWithIdentifier:(NSString *)identifier {
	UITableViewCell* cell =
	[[[NSBundle mainBundle] loadNibNamed:[self cellIdentifierName:identifier] owner:self options:nil] objectAtIndex:0];
	return cell;
}

- (void)dealloc {
    [super dealloc];
}

@end

