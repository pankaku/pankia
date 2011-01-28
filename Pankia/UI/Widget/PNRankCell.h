//
//  PNRankCell.h
//  PankakuNet
//
//  Created by sota2 on 10/10/05.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewCell.h"

@class PNLeaderboardRankedUserLabel;
@class PNRank;
@interface PNRankCell : PNTableViewCell {
    UIImageView* flagView;
    NSString* countryCode;
    PNLeaderboardRankedUserLabel *usernameLabel;
    PNRank* rank;
}
@property (nonatomic, assign) NSString* countryCode;
@property (nonatomic, retain) PNRank* rank;
@end
