//
//  PNNetworkMatchTableViewController.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNNetworkMatchTableViewController.h"


@implementation PNNetworkMatchTableViewController

- (void)awakeFromNib {
	[super awakeFromNib];
}

// PNTableViewControllerクラスのviewDidLoadをオーバーライドします。
- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 80.0;
}

- (void)dealloc {
	[super dealloc];
}

@end
