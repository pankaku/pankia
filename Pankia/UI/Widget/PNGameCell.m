//
//  PNGameCell.m
//  PankakuNet
//
//  Created by 横江 宗太 on 10/09/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGameCell.h"
#import "PNGame.h"
#import "PNGradeAndAchievementsLabel.h"
#import "PNTreeIcon.h"
#import "UIView+Slide.h"

#define kPNSpecialCellBackgroundImage   @"PNSpecialTableCellBackgroundImage.png"


@interface PNGameCell ()
@property (nonatomic, retain) PNGradeAndAchievementsLabel* statusLabel;
@end

@implementation PNGameCell
@synthesize statusLabel, game;

- (void)setGame:(PNGame *)aGame {
	if (game != nil) {
		[game release];
		game = nil;
	}
	game = [aGame retain];
	
	CGRect detailFrame = self.detailTextLabel.frame;
	CGRect textFrame = self.textLabel.frame;
	
	self.textLabel.text = aGame.gameTitle;

	if (aGame.gradeName != nil) {
		statusLabel.gradeName = aGame.gradeName;
		statusLabel.gradePoint = [aGame.gradePoint intValue];
	}
	
	statusLabel.achievementPoint = [aGame.achievementPoint intValue];
	statusLabel.achievementTotal = [aGame.achievementTotal intValue];
	statusLabel.frame = CGRectMake(detailFrame.origin.x, detailFrame.origin.y, textFrame.size.width, detailFrame.size.height);
	if (statusLabel.frame.origin.x > 5.0f)	//原因不明のバグ(左上に一瞬表示される)対策
		statusLabel.hidden = NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNSpecialCellBackgroundImage]] autorelease];
		self.detailTextLabel.text = @" ";
		self.highlightable = NO;
		
		statusLabel = [[[PNGradeAndAchievementsLabel alloc] init] autorelease];
		[self addSubview:statusLabel];
		statusLabel.hidden = YES;
		
		if (self.treeIcon == nil) {
			self.treeIcon = [[[PNTreeIcon alloc] init] autorelease];
			[self addSubview:self.treeIcon];
			self.treeIcon.frame = CGRectMake(0.0f, 14.0f, 12.0f, 12.0f);
		}
    }
	
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

}


- (void)dealloc {
	self.game        = nil;
	self.statusLabel = nil;
    [super dealloc];
}


@end
