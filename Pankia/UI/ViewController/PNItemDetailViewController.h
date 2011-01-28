//
//  PNItemDetailViewController.h
//  PankakuNet
//
//  Created by sota on 10/09/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"

@class PNItem;
@interface PNItemDetailViewController : PNTableViewController {
	PNItem* item;
	int merchandisesHeaderRowNumber;
	int descriptionHeaderRowNumber;
	int screenshotsHeaderRowNumber;
	int rowCount;
	BOOL isBuying;
}
@property (nonatomic, retain) PNItem* item;
@end
