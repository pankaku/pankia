//
//  PNMyItemsViewController.h
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"

@interface PNMyItemsViewController : PNTableViewController {
	NSArray* categories;
	NSMutableDictionary* ownItemsInCategories;
	BOOL loading;
}

@end
