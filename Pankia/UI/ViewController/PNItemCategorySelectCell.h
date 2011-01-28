//
//  PNItemCategorySelectCell.h
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PNItemCategorySelectCellDelegate
- (void)selectPrevious:(id)sender;
- (void)selectNext:(id)sender;
@end


@class PNItemCategory;
@class PNLocalizableLabel;
@interface PNItemCategorySelectCell : UITableViewCell {
	PNItemCategory* selectedCategory;
	PNLocalizableLabel* categoryNameLabel;
	UIButton* previousButton;
	UIButton* nextButton;
	id<PNItemCategorySelectCellDelegate> delegate;
}
@property (nonatomic, retain) PNItemCategory* selectedCategory;
@property (nonatomic, assign) id<PNItemCategorySelectCellDelegate> delegate;
@end
