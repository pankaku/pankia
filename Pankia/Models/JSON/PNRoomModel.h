#import "PNDataModel.h"

/**
 @brief Roomに関するJSONから作られる構造体
 */
@interface PNRoomModel : PNDataModel {
	NSString *_id;
	NSString *_name;
	BOOL _is_public;
	int _max_members;
	NSArray *_memberships;
	BOOL _is_locked;
	int lobby_id;
}

@property (assign, nonatomic) int max_members;
@property (assign, nonatomic) BOOL is_public, is_locked;
@property (retain, nonatomic) NSString *id, *name;
@property (retain, nonatomic) NSArray *memberships;
@property (assign, nonatomic) int lobby_id;
@end
