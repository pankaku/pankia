//
//  PNNetworkMatchViewController.h
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNImageView.h"
#import "PNUserStatsLabel.h"
#import "PNNetworkMatchCell.h"
#import "PNTableViewController.h"

// ローカル対戦で部屋の選択のUIを使うかどうかの設定です。
#define kPNSelectionOfTheLocalRoomUse YES

@interface PNNetworkMatchViewController : PNTableViewController {
@private
	NSArray*			dataSource_;	
	PNNetworkMatchCell* networkMatchCell_;
}

@property (assign) IBOutlet PNNetworkMatchCell* networkMatchCell_;


@end
