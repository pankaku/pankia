#import "PNDataModel.h"
#import "PNUserModel.h"

/**
 @brief メンバーシップに関するJSONから作られる構造体
 */
@interface PNMembershipModel : PNDataModel {
	NSString *_id;
	PNUserModel *_user;
	NSString *_ip;
}

@property (retain, nonatomic) NSString *id, *ip;
@property (retain, nonatomic) PNUserModel *user;

@end
