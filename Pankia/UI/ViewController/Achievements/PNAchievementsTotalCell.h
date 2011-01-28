//
//  PNAchievementsTotalCell.h
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewCell.h"

@class PNUser;

@interface PNAchievementsTotalCell : PNTableViewCell {

}

// Designated initializer
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forUser:(PNUser *)user;

@end
