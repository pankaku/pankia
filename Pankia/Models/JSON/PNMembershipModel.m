#import "PNMembershipModel.h"

//Membership
#define kPNMembershipDefaultID				@""
#define kPNMembershipDefaultIP				@""

@implementation PNMembershipModel
@synthesize id = _id, user = _user, ip = _ip;

- (id) init{
	if (self = [super init]){
		self.id = kPNMembershipDefaultID;
		self.ip = kPNMembershipDefaultIP;
		self.user = nil;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.id = [aDictionary stringValueForKey:@"id" defaultValue:kPNMembershipDefaultID];
		self.ip = [aDictionary stringValueForKey:@"ip" defaultValue:kPNMembershipDefaultIP];
		if ([aDictionary hasObjectForKey:@"user"]){
			self.user = [[[PNUserModel alloc] initWithDictionary:[aDictionary objectForKey:@"user"]] autorelease];
		}
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc{
	self.id		= nil;
	self.ip		= nil;
	self.user		= nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n id:%@\n ip:%@\n user:%p",
			NSStringFromClass([self class]),self,_id, _ip, _user];
}
@end
