//
//  PNGradeAndAchievementsLabel.m
//  PankakuNet
//
//  Created by 横江 宗太 on 10/09/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGradeAndAchievementsLabel.h"
#import "UIView+Slide.h"
#import "PNGlobal.h"
#import "UILabel+textWidth.h"
 

#define kPNGradeIconFile		@"PNGradeIconSmall.png"
#define kPNAchievementsIconFile @"PNAchievementIconSmall.png"
static const int kPadding = 5.0f;

@implementation PNGradeAndAchievementsLabel
@synthesize gradeName, gradePoint, achievementPoint, achievementTotal;

- (void)setGradeName:(NSString *)value
{
	if (gradeName != nil) {
		[gradeName release];
		gradeName = nil;
	}
	gradeName = [value retain];
	showGradepoint = YES;
	[self update];
}
- (void)setGradePoint:(int)value
{
	gradePoint = value;
	showGradepoint = YES;
	[self update];
}
- (void)setAchievementPoint:(int)value
{
	achievementPoint = value;
	showAchievements = YES;
	[self update];
}
- (void)setAchievementTotal:(int)value
{
	achievementTotal = value;
	showAchievements = YES;
	[self update];
}

#pragma mark -

- (void)update
{
	gradeIcon.hidden = !showGradepoint;
	gradeLabel.hidden = !showGradepoint;
	achievementIcon.hidden = !showAchievements;
	achievementLabel.hidden = !showAchievements;
	
	[self layoutSubviews];
}
- (void)reset
{
	showGradepoint = NO;
	showAchievements = NO;
}
- (void)layoutSubviews
{
	float gradeIconX = 0.0f;
	float achievementIconX = 0.0f;
	
	// TODO: コンマをいれる
	gradeLabel.text = showGradepoint ? [NSString stringWithFormat:@"%@(%d)", gradeName, gradePoint] : @"";
	achievementLabel.text = showAchievements ? [NSString stringWithFormat:@"%d/%d", achievementPoint, achievementTotal] : @"";
	
	float gradeLabelWidth = [gradeLabel textWidth];
	float achievementLabelWidth = [achievementLabel textWidth];
	
	if (showGradepoint) {
		achievementIconX = gradeIconX + gradeIcon.frame.size.width
		+ kPadding + gradeLabelWidth + kPadding;
	}
	float gradeLabelX = gradeIconX + gradeIcon.frame.size.width + kPadding;
	float achievementLabelX = achievementIconX + achievementIcon.frame.size.width + kPadding;
	
	[gradeIcon moveToX:gradeIconX y:0.0f];
	[gradeLabel moveToX:gradeLabelX y:0.0f];
	[achievementIcon moveToX:achievementIconX y:0.0f];
	[achievementLabel moveToX:achievementLabelX y:0.0f];
	[gradeLabel setWidth:gradeLabelWidth height:self.frame.size.height];
	[achievementLabel setWidth:achievementLabelWidth height:self.frame.size.height];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		gradeIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNGradeIconFile]] autorelease];
		achievementIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNAchievementsIconFile]] autorelease];
		gradeIcon.hidden = YES;
		achievementIcon.hidden = YES;
		[self addSubview:gradeIcon];
		[self addSubview:achievementIcon];
		
		UIFont* font = [UIFont fontWithName:kPNDefaultFontName size:10.0f];
		UIColor* cyanColor = [UIColor colorWithRed:0.6 green:1.0 blue:1.0 alpha:1.0];
		
		gradeLabel = [[[UILabel alloc] init] autorelease];
		achievementLabel = [[[UILabel alloc] init] autorelease];
		gradeLabel.backgroundColor = [UIColor clearColor];
		achievementLabel.backgroundColor = [UIColor clearColor];
		gradeLabel.textColor = cyanColor;
		achievementLabel.textColor = cyanColor;
		gradeLabel.font = font;
		achievementLabel.font = font;
		
		[self addSubview:gradeLabel];
		[self addSubview:achievementLabel];
		
		[self reset];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
