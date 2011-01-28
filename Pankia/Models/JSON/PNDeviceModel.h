#import "PNDataModel.h"

/**
 @brief Deviceに関するJSONから作られる構造体
 */
@interface PNDeviceModel : PNDataModel {
	NSString*						_udid;
	NSString*						_name;
	NSString*						_os;
	NSString*						_hardware;
}

@property (retain, nonatomic) NSString*		udid;
@property (retain, nonatomic) NSString*		name;
@property (retain, nonatomic) NSString*		os;
@property (retain, nonatomic) NSString*		hardware;


@end
