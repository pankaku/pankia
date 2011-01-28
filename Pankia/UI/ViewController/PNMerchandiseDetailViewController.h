//
//  PNMerchandiseDetailViewController.h
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"

@class PNMerchandise;
@interface PNMerchandiseDetailViewController : PNTableViewController {
	PNMerchandise *merchandise;
	int contentsHeaderRowNumber;
	int descriptionHeaderRowNumber;
	int screenshotsHeaderRowNumber;
	int rowCount;
	BOOL isBuying;
}
@property (nonatomic, retain) PNMerchandise *merchandise;
@end
