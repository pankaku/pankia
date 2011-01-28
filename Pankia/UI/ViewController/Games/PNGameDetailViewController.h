//
//  PNGameDetailViewController.h
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"

@class PNGame;
@interface PNGameDetailViewController : PNTableViewController {
	PNGame* game;
	BOOL loading;
	int rowCount;
	NSArray* followees;
	int screenshotsHeaderRowNumber;
	UILabel* priceLabel;
}
@property (nonatomic, retain) PNGame* game;
@property (nonatomic, retain) NSArray* followees;
@end
