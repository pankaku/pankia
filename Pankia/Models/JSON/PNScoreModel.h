#import "PNDataModel.h"
#import "PNUserModel.h"

/**
 @brief Scoreに関するJSONから作られる構造体
 */
@interface PNScoreModel : PNDataModel {
	long long int _value;
	PNUserModel *_user;
}

@property (assign, nonatomic) long long int value;
@property (retain, nonatomic) PNUserModel *user;

@end
