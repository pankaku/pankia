//
//  PNAchievementsCell.m
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNAchievementsCell.h"
#import "PNAchievement+Package.h"
#import "PNTableCell.h"
#import "PNLocalizableLabel.h"

@implementation PNAchievementsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		//self.textLabel.text = achievement.title;
		
		CGRect titleLabelFrame = CGRectMake(71, 5, 250, 22);
		titleLabel = [[PNLocalizableLabel alloc] initWithFrame:titleLabelFrame style:PNLargeLabelStyle];
		[self addSubview:titleLabel];

		CGRect descriptionLabelFrame = CGRectMake(71, 25, 250, 18);
		descriptionLabel = [[PNLocalizableLabel alloc] initWithFrame:descriptionLabelFrame style:PNSubLabelStyle];
		[self addSubview:descriptionLabel];
		
		CGRect pointLabelFrame = CGRectMake(420, 0, 30, 50);
		pointLabel = [[PNLocalizableLabel alloc] initWithFrame:pointLabelFrame style:PNSubLargeLabelStyle];
		[self addSubview:pointLabel];
		
		CGRect lockIconFrame = CGRectMake(20, 7, 36, 36);
		lockIcon = [[UIImageView alloc] initWithFrame:lockIconFrame];
		[self addSubview:lockIcon];	
	}
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[titleLabel release];
	[descriptionLabel release];
	[pointLabel release];
	[lockIcon release];
    [super dealloc];
}

#pragma mark -

- (void)setAchivementText:(PNAchievement *)achievement {
	titleLabel.text = [NSString stringWithFormat:@"%@", achievement.title];
	descriptionLabel.text = [NSString stringWithFormat:@"%@", achievement.description];
	pointLabel.text = [NSString stringWithFormat:@"%d", achievement.value];

	if (achievement.isUnlocked) {
		lockIcon.image = [UIImage imageNamed:@"PNUnlockedAchievementIcon.png"];
	} else {
		lockIcon.image = [UIImage imageNamed:@"PNLockedAchievementIcon.png"];
	}
	/*
	if (achievement.isUnlocked) {
		[self loadRoundRectImageFromURL:achievement.iconUrl defaultImageName:@"PNUnlockedAchievementIcon.png" 
							paddingLeft:10.0f top:0.0f right:0.0f bottom:0.0f width:36.0f height:36.0f delegate:self];
	} else {
		[self loadRoundRectImageFromURL:nil defaultImageName:@"PNLockedAchievementIcon.png" 
							paddingLeft:10.0f top:0.0f right:0.0f bottom:0.0f width:36.0f height:36.0f delegate:self];
	}
	 */
	/*
	 if (achievement.isShowDescription) {
	 [self setHighlightedBackground:YES];
	 }
	 else {
	 [self setHighlightedBackground:NO];
	 }
	 */
}

@end
