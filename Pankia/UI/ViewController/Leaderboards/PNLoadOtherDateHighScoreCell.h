//
//  PNLoadOtherDateHighScoreCell.h
//  PankakuNet
//
//  Created by Kazuto Maruoka on 3/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableCell.h"

/**
 @brief 前後の日付に移動するためのボタンを表示するCellクラスです。
 PNHighScoreViewControllerに所属。
 */
@interface PNLoadOtherDateHighScoreCell : PNTableCell {
	IBOutlet	UILabel*		dateLabel;
	int							scope;
	id							delegate;
	NSDate*						targetDate;
}

@property (retain) IBOutlet	UILabel*	dateLabel;
@property (assign) IBOutlet id			delegate;
@property (retain) IBOutlet	NSDate*		targetDate;
@property (assign) int					scope;

/**
 * @brief previousボタンが押された時の処理
 */
- (IBAction)previousDate;

/**
 * @brief nextボタンが押された時の処理
 */
- (IBAction)nextDate;

/**
 * @brief nextボタンを非表示しにします。
 */
- (void)disableNextBtn;

/**
 * @brief nextボタンを表示します。
 */
- (void)enableNextBtn;

@end
