//
//  PNAchievementsTotalCell.m
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNAchievementsTotalCell.h"
#import "PNLocalizableLabel.h"
#import "PNUser.h"

#define kPNTableCellBackgroundImage		@"PNTableCellBackgroundImage.png"
#define kPNAchievementsSmallIconFile	@"PNAchievementsSmallIcon.png"

@implementation PNAchievementsTotalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forUser:(PNUser *)user {    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		UIImage *backgroundImage = [UIImage imageNamed:kPNTableCellBackgroundImage];
		self.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
		
		//CGRect pointLabel =  CGRectMake(400, 20, 100, 18);
		CGRect pointLabel =  CGRectMake(0, 0, 70, 18);
		UIView *pointView = [[UIView alloc] initWithFrame:pointLabel];
		
		CGRect pointDigitLabelFrame =  CGRectMake(20, 0, 50, 18);
		PNLocalizableLabel *pointDigitLabel = [[PNLocalizableLabel alloc] initWithFrame:pointDigitLabelFrame style:PNStatusLabelStyle];
		pointDigitLabel.text = [NSString stringWithFormat:@"%d/%d", user.achievementPoint, user.achievementTotal];
		[pointView addSubview:pointDigitLabel];
		[pointDigitLabel release];
		
		CGRect achievementIconFrame = CGRectMake(0, 0, 18, 18);
		UIImageView *achievementIcon = [[UIImageView alloc] initWithFrame:achievementIconFrame];
		achievementIcon.image = [UIImage imageNamed:kPNAchievementsSmallIconFile];
		[pointView addSubview:achievementIcon];
		[achievementIcon release];

		self.accessoryView = pointView;
		[pointView release];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
