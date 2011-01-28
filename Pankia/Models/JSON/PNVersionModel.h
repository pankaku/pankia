
#import "PNDataModel.h"

@interface PNVersionModel : PNDataModel {
	BOOL _isCurrent;
	NSString* _name;
	NSString* _value;
}

@property (assign) BOOL isCurrent;
@property (retain) NSString* name;
@property (retain) NSString* value;

@end
