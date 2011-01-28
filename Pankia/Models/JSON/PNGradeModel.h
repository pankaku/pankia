#import "PNDataModel.h"

#define kPNGradeDefaultID			-1
#define kPNGradeDefaultName			@""
#define kPNGradeDefaultPoint		-1

// [Grade Filter]
#define kPNGradeAll					@"all"
#define kPNGradeSame				@"eq"
#define kPNGradeGrater				@"gte"
#define kPNGradeLesser				@"lte"

/**
 @brief Gradeに関するJSONから作られる構造体
 */
@interface PNGradeModel : PNDataModel {
	int								_id;
	NSString*						_name;
	int								_point;
}

@property (assign, nonatomic) int			id;
@property (retain, nonatomic) NSString*		name;
@property (assign, nonatomic) int			point;

@end
