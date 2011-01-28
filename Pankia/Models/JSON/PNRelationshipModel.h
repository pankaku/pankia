#import "PNDataModel.h"
#import "PNUserModel.h"

@interface PNRelationshipModel : PNDataModel {
	int _id;
	NSString *_type;
	PNUserModel *_from, *_to;
}

@property (assign, nonatomic) int id;
@property (retain, nonatomic) NSString *type;
@property (retain, nonatomic) PNUserModel *from, *to;

@end
