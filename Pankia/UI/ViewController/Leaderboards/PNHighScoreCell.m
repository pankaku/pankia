//
//  PNHighScoreCell.mm
//  PankiaNet
//
//  Created by Hiroki Tsuchimoto on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNHighScoreCell.h"
//#import "PNUserStatsLabel.h"
//#import "PNControllerLoader.h"
#import "PNImageView.h"
#import "PNUser+Package.h"
#import "PNCountryCodeUtil.h"
#import "PNLocalizableLabel.h"

#define kPNCellBackgroundImage          @"PNTableCellBackgroundImage.png"


@interface PNHighScoreCell ()

@property (nonatomic, retain) PNImageView *userImageView;
@property (nonatomic, retain) UIImageView *countryImageView;
@property (nonatomic, retain) UIImageView *accessoryImageView;
@property (nonatomic, retain) PNLocalizableLabel *rankLabel;
@property (nonatomic, retain) PNLocalizableLabel *userNameLabel;
@property (nonatomic, retain) PNLocalizableLabel *statusLabel;
@property (nonatomic, retain) PNLocalizableLabel *scoreLabel;
@property (nonatomic, retain) PNLocalizableLabel *achievementPointLabel;
@property (nonatomic, retain) PNLocalizableLabel *gradeNameLabel;
@property (nonatomic, retain) PNLocalizableLabel *gradePointLabel;

@end


@implementation PNHighScoreCell

@synthesize userImageView;
@synthesize countryImageView;
@synthesize accessoryImageView;
@synthesize rankLabel;
@synthesize userNameLabel;
@synthesize statusLabel;
@synthesize scoreLabel;
@synthesize achievementPointLabel;
@synthesize gradeNameLabel;
@synthesize gradePointLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		//UIImage *backgroundImage = [UIImage imageNamed:kPNCellBackgroundImage];
		//self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
		
		accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNCellArrowImage.png"]];
		self.accessoryView = accessoryImageView;
		[accessoryImageView release];
		
		CGRect userIconFrame = CGRectMake(20, 7, 36, 36);
		self.userImageView = [[[PNImageView alloc] initWithFrame:userIconFrame] autorelease];
		[self addSubview:userImageView];
		
		CGRect countryImageFrame = CGRectMake(40, 32, 17, 12);
		self.countryImageView = [[UIImageView alloc] initWithFrame:countryImageFrame];
		[self addSubview:countryImageView];
		
		CGRect rankingLabelFrame = CGRectMake(71, 7, 70, 22);
		self.rankLabel = [[[PNLocalizableLabel alloc] initWithFrame:rankingLabelFrame style:PNRankLabelStyle] autorelease];
		[self addSubview:rankLabel];

		CGRect userNameLabelFrame = CGRectMake(148, 7, 130, 22);
		self.userNameLabel = [[[PNLocalizableLabel alloc] initWithFrame:userNameLabelFrame style:PNLargeLabelStyle] autorelease];
		[self addSubview:userNameLabel];
		
		CGRect statusLabelFrame = CGRectMake(208, 7, 100, 22);
		self.statusLabel = [[[PNLocalizableLabel alloc] initWithFrame:statusLabelFrame style:PNSubLabelStyle] autorelease];
		[self addSubview:statusLabel];
		
		CGRect scoreLabelFrame = CGRectMake(308, 0, 100, 50);
		self.scoreLabel = [[[PNLocalizableLabel alloc] initWithFrame:scoreLabelFrame style:PNSpecialLargeLabelStyle] autorelease];
		self.scoreLabel.textAlignment = UITextAlignmentRight;
		[self addSubview:scoreLabel];
		
		CGRect achievementIconFrame = CGRectMake(71, 27, 18, 18);
		UIImageView *achievementIcon = [[UIImageView alloc] initWithFrame:achievementIconFrame];
		achievementIcon.image = [UIImage imageNamed:@"PNAchievementsSmallIcon.png"];
		[self addSubview:achievementIcon];
		[achievementIcon release];

		CGRect gradeIconFrame = CGRectMake(136, 27, 18, 18);
		UIImageView *gradeIcon = [[UIImageView alloc] initWithFrame:gradeIconFrame];
		gradeIcon.image = [UIImage imageNamed:@"PNGradeSmallIcon.png"];
		[self addSubview:gradeIcon];
		[gradeIcon release];
		
		CGRect achievementPointLabelFrame = CGRectMake(91, 29, 50, 14);
		self.achievementPointLabel = [[[PNLocalizableLabel alloc] initWithFrame:achievementPointLabelFrame style:PNStatusLabelStyle] autorelease];
		[self addSubview:achievementPointLabel];

		CGRect gradePointLabelFrame = CGRectMake(156, 29, 130, 14);
		self.gradePointLabel = [[[PNLocalizableLabel alloc] initWithFrame:gradePointLabelFrame style:PNStatusLabelStyle] autorelease];
		[self addSubview:gradePointLabel];
	}
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	userImageView = nil;
	countryImageView = nil;
	accessoryImageView = nil;
	rankLabel = nil;
	userNameLabel = nil;
	statusLabel = nil;
	scoreLabel = nil;
	gradeNameLabel = nil;
	gradePointLabel = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Accecer Method

- (void)setRank:(int)rank {
	self.rankLabel.text = [NSString stringWithFormat:@"%d.", rank];
}


- (void)setUserName:(NSString *)userName {
	self.userNameLabel.text = userName;
	CGRect rankLabelFrame = [rankLabel textRectForBounds:rankLabel.bounds limitedToNumberOfLines:1];
	CGRect userNameLabelFrame = userNameLabel.frame;
	userNameLabelFrame.origin.x = rankLabel.frame.origin.x + rankLabelFrame.size.width + 5;
	self.userNameLabel.frame = userNameLabelFrame;
}

- (void)setStatus:(NSString *)status {
	self.statusLabel.text = status;
	CGRect userNameFrame = [userNameLabel textRectForBounds:userNameLabel.bounds limitedToNumberOfLines:1];
	CGRect statusLabelFrame = statusLabel.frame;
	statusLabelFrame.origin.x = userNameLabel.frame.origin.x + userNameFrame.size.width + 5;
	self.statusLabel.frame = statusLabelFrame;
}


- (void)setScore:(long long int)score {
	NSNumber *number = [[[NSNumber alloc] initWithInt:score] autorelease];
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    [formatter setGroupingSize:3];
	self.scoreLabel.text = [formatter stringForObjectValue:number];
}

- (void)setUserIconImage:(PNUser *)user {
	if ([user.username isEqualToString:[PNUser currentUser].username]) {
		self.userImageView.image = [UIImage imageNamed:@"PNDefaultSelfIcon.png"];
	} else {
		self.userImageView.image = [UIImage imageNamed:@"PNDefaultUserIcon.png"];
	}
	[self.userImageView loadImageOfUser:user];
}

- (void)setArrowIconImage:(UIImage *)iconImage {
	accessoryImageView.image = iconImage;
}

- (void)setCountry:(NSString *)countryCode {
	self.countryImageView.image = [PNCountryCodeUtil getFlagImageForAlpha2Code:countryCode];
}

- (void)setAchievementPoint:(NSInteger)point total:(NSInteger)total {
	self.achievementPointLabel.text = [NSString stringWithFormat:@"%d/%d", point, total];
}

- (void)setGrade:(PNUser *)user {
	self.gradePointLabel.text = [NSString stringWithFormat:@"%@(%d)", user.gradeName, user.gradePoint];
}

@end
