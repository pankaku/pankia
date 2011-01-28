//
//  PNLeaderboardRankedUserLabel.m
//  PankakuNet
//
//  Created by sota2 on 10/10/07.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLeaderboardRankedUserLabel.h"
#import "PNLocalizableLabel.h"
#import "UIView+Slide.h"
#import "UILabel+textWidth.h"

@implementation PNLeaderboardRankedUserLabel
@synthesize ranking, username;

- (void)setRanking:(int)aRanking
{
    ranking = aRanking;
    rankingLabel.text = [NSString stringWithFormat:@"%d.", ranking];
}
- (void)setUsername:(NSString *)anUsername
{
    if (username != nil) {
        [username release];
        username = nil;
    }
    username = [anUsername retain];
    
    usernameLabel.text = username;
}

- (id)init {
    if (self = [super init]) {
        rankingLabel = [PNLocalizableLabel label];
        [self addSubview:rankingLabel];
        
        usernameLabel = [PNLocalizableLabel label];
        [self addSubview:usernameLabel];
        
        rankingLabel.text = @"0.";
        usernameLabel.text = @"---";
        
        rankingLabel.fontSize = 13.0f;
        usernameLabel.fontSize = 13.0f;
        
        rankingLabel.textColor = [UIColor colorWithRed:0.6f green:1.0f blue:1.0f alpha:1.0f];
    }
    return self;
}

+ (PNLeaderboardRankedUserLabel*)labelWithFrame:(CGRect)rect
{
    PNLeaderboardRankedUserLabel* instance = [[[PNLeaderboardRankedUserLabel alloc] init] autorelease];
    instance.frame = rect;
    instance.backgroundColor = [UIColor clearColor];
    
    return instance;
}

- (void)layoutSubviews
{
    [rankingLabel moveToX:0.0f y:0.0f];
    [rankingLabel setWidth:[rankingLabel textWidth] height:30.0f];
    [usernameLabel moveToX:[rankingLabel textWidth] + 5.0f y:0.0f];
    [usernameLabel setWidth:[usernameLabel textWidth] height:30.0f];
}
@end
