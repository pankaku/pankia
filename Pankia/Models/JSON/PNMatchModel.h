#import "PNDataModel.h"

@interface PNMatchModel : PNDataModel {
	int _id;
	NSString* _room_id;
	NSMutableArray* _users;
	NSDate* _start_at;
	NSDate* _end_at;
}

@property(assign) int id;
@property(retain) NSString* room_id;
@property(retain) NSMutableArray* users;
@property(retain) NSDate* start_at;
@property(retain) NSDate* end_at;

@end
