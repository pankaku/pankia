//
//  PNGradeAndAchievementsLabel.h
//  PankakuNet
//
//  Created by 横江 宗太 on 10/09/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PNGradeAndAchievementsLabel : UIView {
	int gradePoint;
	int achievementPoint;
	int achievementTotal;
	NSString* gradeName;
	BOOL showGradepoint;
	BOOL showAchievements;
	
	UIImageView* gradeIcon;
	UIImageView* achievementIcon;
	
	UILabel* gradeLabel;
	UILabel* achievementLabel;
}
@property (nonatomic, retain) NSString* gradeName;
@property (nonatomic, assign) int gradePoint;
@property (nonatomic, assign) int achievementPoint;
@property (nonatomic, assign) int achievementTotal;
- (void)reset;
- (void)update;
@end
