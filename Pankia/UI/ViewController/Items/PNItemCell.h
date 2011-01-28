//
//  PNItemCell.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 12/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableCell.h"
#import "PNPurchaseModel.h"

/**
 @brief アイテム情報の表示するCellクラスです。
 PNItemsViewControllerに所属。
 */

@interface PNItemCell : PNTableCell {
	IBOutlet PNImageView*	iconImage;
	IBOutlet UILabel*		merchandiseNameLabel;
	IBOutlet UILabel*		priceLabel;
	IBOutlet UILabel*		datetimeLabel;
	PNPurchaseModel*		purchase;
}

@property (retain) IBOutlet PNImageView*	iconImage;
@property (retain) IBOutlet UILabel*		merchandiseNameLabel;
@property (retain) IBOutlet UILabel*		priceLabel;
@property (retain) IBOutlet UILabel*		datetimeLabel;
@property (nonatomic, retain) PNPurchaseModel* purchase;

-(void)setPurchase:(PNPurchaseModel *)p;

@end
