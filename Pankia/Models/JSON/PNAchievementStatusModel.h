#import "PNDataModel.h"

/**
 @brief AchievementStatusに関するJSONから作られる構造体
 */
@interface PNAchievementStatusModel : PNDataModel {
	int								_achievement_point;
	int								_achievement_total;
}

@property (assign, nonatomic) int				achievement_point;
@property (assign, nonatomic) int				achievement_total;

@end
