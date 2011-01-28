
#import "PNDataModel.h"
#import "PNInstallModel.h"
#import "PNTwitterModel.h"
#import "PNFacebookAccountModel.h"

/**
 @brief ユーザに関するJSONから作られる構造体
 */
@interface PNUserModel : PNDataModel {
	NSInteger _id;
	NSString* _username;
	NSString* _fullname;
	NSString* _country;
	NSString* _icon_url;
	PNInstallModel* _install;
	PNTwitterModel* _twitter;
	// BEGIN - lerry added code
	PNFacebookAccountModel* _facebook;
	// END - lerry added code
	BOOL _is_guest;
	BOOL _is_secured;
	NSString *_twitter_id;
	BOOL _is_following;
	BOOL _is_blocking;
	NSArray *_relationships;
	NSArray *_installs;
	NSString* icon_used;
}

@property (assign, nonatomic) NSInteger id;
@property (retain, nonatomic) NSString *username, *fullname, *country, *icon_url, *twitter_id;
@property (retain, nonatomic) PNInstallModel *install;
@property (retain, nonatomic) PNTwitterModel *twitter;
// BEGIN - lerry added code
@property (retain, nonatomic) PNFacebookAccountModel* facebook;
// END - lerry added code
@property (assign, nonatomic) BOOL is_guest, is_secured, is_following, is_blocking;
@property (retain, nonatomic) NSArray *relationships, *installs;
@property (retain, nonatomic) NSString* icon_used;
@property (retain, nonatomic) NSString* externalId;

@end
