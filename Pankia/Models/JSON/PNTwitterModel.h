#import "PNDataModel.h"

#define kPNTwitterDefaultID                0
#define kPNTwitterDefaultScreenName      @""

@interface PNTwitterModel : PNDataModel {
	int       _id;
	NSString* _screen_name;
}

@property (assign, nonatomic) int       id;
@property (retain, nonatomic) NSString* screen_name;

@end
