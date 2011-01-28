#import "PNTwitterModel.h"


@implementation PNTwitterModel

@synthesize id          = _id;
@synthesize screen_name = _screen_name;

- (id) init{
	if (self = [super init]){
		self.id          = kPNTwitterDefaultID;
		self.screen_name = kPNTwitterDefaultScreenName;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.id = [aDictionary intValueForKey:@"id" defaultValue:kPNTwitterDefaultID];
		self.screen_name = [aDictionary stringValueForKey:@"screen_name" defaultValue:kPNTwitterDefaultScreenName];
	}
	return self;
}

- (void)dealloc
{
	self.screen_name = nil;
	[super dealloc];
}

@end
