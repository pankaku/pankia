//
//  PNHighScoreCell.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewCell.h"

/**
 @brief ユーザの情報とスコアを表示するCellクラスです。
 PNHighScoreViewControllerに所属。
 */
@class PNImageView;
@class PNUser;
@class PNLocalizableLabel;

//@interface PNHighScoreCell : UITableViewCell {
@interface PNHighScoreCell : PNTableViewCell {
	PNImageView *userImageView;
	UIImageView *countryImageView;
	UIImageView *accessoryImageView;
	PNLocalizableLabel *rankLabel;
	PNLocalizableLabel *userNameLabel;
	PNLocalizableLabel *statusLabel;
	PNLocalizableLabel *scoreLabel;
	PNLocalizableLabel *achievementPointLabel;
	PNLocalizableLabel *gradeNameLabel;
	PNLocalizableLabel *gradePointLabel;
}

- (void)setRank:(int)rank;
- (void)setUserName:(NSString *)userName;
- (void)setStatus:(NSString *)status;
- (void)setScore:(long long int)score;
- (void)setUserIconImage:(PNUser *)user;
- (void)setArrowIconImage:(UIImage *)iconImage;
- (void)setCountry:(NSString *)countryCode;
- (void)setAchievementPoint:(NSInteger)point total:(NSInteger)total;
- (void)setGrade:(PNUser *)user;


@end
