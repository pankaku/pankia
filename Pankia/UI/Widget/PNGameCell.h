//
//  PNGameCell.h
//  PankakuNet
//
//  Created by 横江 宗太 on 10/09/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableCell.h"

@class PNGame;
@class PNGradeAndAchievementsLabel;
@interface PNGameCell : PNTableCell {
	PNGradeAndAchievementsLabel* statusLabel;
}
@property (nonatomic, retain) PNGame* game;
@end
