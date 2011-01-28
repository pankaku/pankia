#import "PNGradeModel.h"
#import "PNDataModel.h"

/**
 @brief GradeStatusに関するJSONから作られる構造体
 */
@interface PNGradeStatusModel : PNDataModel {
	int								_grade_point;
	PNGradeModel*					_grade;
}

@property (assign, nonatomic) int				grade_point;
@property (retain, nonatomic) PNGradeModel*	grade;

@end
