//
//  PNProfileContentView.m
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNProfileContentView.h"
#import "PNLocalizableLabel.h"
#import "PNCountryCodeUtil.h"

#import "PNLogger.h"

@implementation PNProfileContentView


- (id)initWithFrame:(CGRect)frame {
	PNLogMethodName;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		CGRect backgroundImageRect = CGRectMake(0, 0, 480, 90);
		UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:backgroundImageRect];
		backgroundImageView.image = [UIImage imageNamed:@"PNInformationTableCellBackgroundImage.png"];
		[self addSubview:backgroundImageView];
		[backgroundImageView release];
		
		CGRect achievementsIconRect = CGRectMake(80, 60, 18, 18);
		UIImageView *achivementIcon = [[UIImageView alloc] initWithFrame:achievementsIconRect];
		achivementIcon.image = [UIImage imageNamed:@"PNAchievementsSmallIcon.png"];
		[self addSubview:achivementIcon];
		[achivementIcon release];
		
		CGRect gradeIconRect = CGRectMake(140, 60, 18, 18);
		UIImageView *gradeIcon = [[UIImageView alloc] initWithFrame:gradeIconRect];
		gradeIcon.image = [UIImage imageNamed:@"PNGradeSmallIcon.png"];
		[self addSubview:gradeIcon];
		[gradeIcon release];
		
		CGRect coinIconRect = CGRectMake(240, 60, 18, 18);
		UIImageView *coinIcon = [[UIImageView alloc] initWithFrame:coinIconRect];
		coinIcon.image = [UIImage imageNamed:@"PNCoinSmallIcon.png"];
		[self addSubview:coinIcon];
		[coinIcon release];

		CGRect userIconFrame = CGRectMake(0, 0, 72, 72);
		userIcon = [[[UIImageView alloc] initWithFrame:userIconFrame] autorelease];
		userIcon.image = [UIImage imageNamed:@"PNDefaultUserIcon.png"];
		[self addSubview:userIcon];

		CGRect countryIconFrame = CGRectMake(0, 0, 17, 12);
		countryIcon = [[[UIImageView alloc] initWithFrame:countryIconFrame] autorelease];
		countryIcon.image = [PNCountryCodeUtil getFlagImageForAlpha2Code:@"JP"];
		[self addSubview:countryIcon];

		CGRect userNameLabelFrame = CGRectMake(80, 0, 380, 30);
		userNameLabel = [[[PNLocalizableLabel alloc] initWithFrame:userNameLabelFrame style:PNUserNameLabelStyle] autorelease];
		userNameLabel.text = @"Shunter1112";
		[self addSubview:userNameLabel];
		
		CGRect achivementPointLabelFrame = CGRectMake(20, 60, 100, 20);
		achivementPointLabel = [[[PNLocalizableLabel alloc] initWithFrame:achivementPointLabelFrame style:PNStatusLabelStyle] autorelease];
		achivementPointLabel.text = @"50/250";
		[self addSubview:achivementPointLabel];

		CGRect gradePointLabelFrame = CGRectMake(160, 60, 100, 20);
		gradePointLabel = [[[PNLocalizableLabel alloc] initWithFrame:gradePointLabelFrame style:PNStatusLabelStyle] autorelease];
		gradePointLabel.text = @"Amature(250)";
		[self addSubview:gradePointLabel];

		CGRect coinLabelFrame = CGRectMake(260, 60, 100, 20);
		coinLabel = [[[PNLocalizableLabel alloc] initWithFrame:coinLabelFrame style:PNStatusLabelStyle] autorelease];
		coinLabel.text = @"200";
		[self addSubview:coinLabel];
	}
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	PNLogMethodName;
    [super dealloc];
}


@end
