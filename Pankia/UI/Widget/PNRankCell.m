//
//  PNRankCell.m
//  PankakuNet
//
//  Created by sota2 on 10/10/05.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PNRankCell.h"
#import "PNRank.h"
#import "PNCountryCodeUtil.h"
#import "UIView+Slide.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNFormatUtil.h"
#import "PNLeaderboardRankedUserLabel.h"

@implementation PNRankCell
@synthesize countryCode, rank;

- (void)setRank:(PNRank *)aRank
{
    if (rank != nil) {
        [rank release];
        rank = nil;
    }
    rank = [aRank retain];
    
    self.countryCode = rank.user.countryCode;
    [self setAccessoryText:[PNFormatUtil stringWithComma:rank.score]];
    
    if (usernameLabel == nil) {
        usernameLabel = [PNLeaderboardRankedUserLabel labelWithFrame:self.textLabel.frame];
        
        [self addSubview:usernameLabel];
        [usernameLabel moveToX:60.0f y:0.0f];
        [usernameLabel setWidth:280.0f height:40.0f];
        
        
    }
    usernameLabel.ranking = rank.rank;
    usernameLabel.username = rank.user.username;
}

- (void)setCountryCode:(NSString *)code
{
    countryCode = code;
    
    if (flagView == nil) {
        flagView = [[[UIImageView alloc] initWithImage:[PNCountryCodeUtil getFlagImageForAlpha2Code:countryCode]] autorelease];
        [self addSubview:flagView];
        [flagView moveToX:50.0f - flagView.frame.size.width 
                        y:40.0f - flagView.frame.size.height];
    }
    
    [flagView setImage:[PNCountryCodeUtil getFlagImageForAlpha2Code:countryCode]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (usernameLabel != nil) {
        [usernameLabel moveToX:60.0f y:0.0f];
        [usernameLabel setWidth:280.0f height:40.0f];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

}




- (void)dealloc {
    [super dealloc];
}


@end
