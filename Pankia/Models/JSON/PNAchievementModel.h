#import "PNDataModel.h"

/**
 @brief Achievemnentに関するJSONから作られる構造体
 */
@interface PNAchievementModel : PNDataModel {
	int								_id;
	NSString*						_name;
	NSString*						_description;
	int								_value;
	NSString*						_icon_url;
	BOOL							_is_secret;
}

@property (assign, nonatomic) int				id;
@property (retain, nonatomic) NSString*			name;
@property (retain, nonatomic) NSString*			description;
@property (assign, nonatomic) int				value;
@property (retain, nonatomic) NSString*			icon_url;
@property (assign, nonatomic) BOOL				is_secret;

@end
