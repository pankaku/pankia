//
//  PNAchievementsCell.h
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewCell.h"

@class PNAchievement;

@interface PNAchievementsCell : PNTableViewCell {
	UILabel *titleLabel;
	UILabel *descriptionLabel;
	UILabel *pointLabel;
	UIImageView *lockIcon;
}

- (void)setAchivementText:(PNAchievement *)achievement;

@end
