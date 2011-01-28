//
//  PNAchievementDescriptionCell.h
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewCell.h"

@class PNAchievement;

@interface PNAchievementDescriptionCell : PNTableViewCell {
	UILabel *descriptionLabel;
}

- (void)setDescriptionText:(NSString *)description;

@end
