#import "PNDataModel.h"

@class PNMembershipModel;
@class PNMatchModel;

@interface PNEventDataModel : PNDataModel {
	int _max_rtt;
	int _maxed_out;
	PNMembershipModel* _membership;
	PNMatchModel* _match;

}

@property(assign) int max_rtt;
@property(assign) int maxed_out;
@property(retain) PNMembershipModel* membership;
@property(retain) PNMatchModel* match;

@end


@interface PNEventModel : PNDataModel {
	PNEventDataModel* _data;
	NSString* _topic;
}

@property (retain) PNEventDataModel* data;
@property (retain) NSString* topic;

@end
