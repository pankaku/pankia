//
//  PNItemCategoryViewController.h
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNItemCategorySelectCell.h"

@class PNItemCategory;
@interface PNItemCategoryViewController : PNTableViewController<PNItemCategorySelectCellDelegate> {
	NSArray* merchandises;
	NSMutableDictionary* merchandisesInCategories;
	PNItemCategory *selectedCategory;
	NSMutableDictionary* priceDictionary;
	NSArray* categories;
}
@property (nonatomic, retain) PNItemCategory* selectedCategory;
@end
