#import "PNGradeStatusModel.h"
#import "PNAchievementStatusModel.h"
#import "PNDataModel.h"
#import "PNGameModel.h"
#import "PNAchievementStatusModel.h"
#import "PNItemOwnershipModel.h"

/**
 @brief インストールに関するJSONから作られる構造体
 */
@interface PNInstallModel : PNDataModel {
	PNGradeStatusModel*							_grade_status;
	PNAchievementStatusModel*					_achievement_status;
	PNGameModel*								_game;
	PNItemOwnershipModel*						_coin_ownership;
	NSArray*									_achievements;
  int64_t                  _bonus_coins_count;
}

@property (retain, nonatomic) PNGradeStatusModel*			grade_status;
@property (retain, nonatomic) PNAchievementStatusModel*	achievement_status;
@property (retain, nonatomic) PNGameModel*					game;
@property (retain, nonatomic) PNItemOwnershipModel*			coin_ownership;
@property (retain, nonatomic) NSArray*						achievements;
@property (assign, nonatomic) int64_t						bonus_coins_count;

@end
