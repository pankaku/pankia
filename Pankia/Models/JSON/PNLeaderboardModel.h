#import "PNDataModel.h"

/**
 @brief Leaderboardに関するJSONから作られる構造体
 */
@interface PNLeaderboardModel : PNDataModel {
	int								_id;
	NSString*						_name;
	NSString*						_type;
	NSString*						_sort_by;
	int64_t							_score_base;
	NSString*						_min_version;
	NSString*						_max_version;
	NSString*						_format;
}

@property (assign, nonatomic) int id;
@property (assign, nonatomic) int64_t score_base;
@property (retain, nonatomic) NSString *name, *type, *sort_by, *min_version, *max_version, *format;

@end
