//
//  PNLeaderboardRankedUserLabel.h
//  PankakuNet
//
//  Created by sota2 on 10/10/07.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNLocalizableLabel;
@interface PNLeaderboardRankedUserLabel : UILabel {
    PNLocalizableLabel *rankingLabel;
    PNLocalizableLabel *usernameLabel;
    int ranking;
    NSString* username;
}
@property (nonatomic, assign) int ranking;
@property (nonatomic, retain) NSString* username;
+ (PNLeaderboardRankedUserLabel*)labelWithFrame:(CGRect)rect;
@end
