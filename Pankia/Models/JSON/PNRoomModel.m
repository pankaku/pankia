#import "PNRoomModel.h"
#import "PNMembershipModel.h"

//Room
#define kPNRoomDefaultID								@""
#define kPNRoomDefaultMaximumMembers					-1
#define kPNRoomDefaultPublic							NO
#define kPNRoomDefaultLocked							YES
#define kPNRoomDefaultPairingRequested					NO
#define kPNRoomDefaultName								@""


@implementation PNRoomModel
@synthesize max_members = _max_members;
@synthesize is_public = _is_public, is_locked = _is_locked;
@synthesize id = _id , name = _name;
@synthesize memberships = _memberships, lobby_id;

- (id) init{
	if (self = [super init]){
		self.max_members			= kPNRoomDefaultMaximumMembers;
		self.is_public				= kPNRoomDefaultPublic;
		self.id						= kPNRoomDefaultID;
		self.name					= kPNRoomDefaultName;
		self.memberships			= [NSArray array];
		self.is_locked				= kPNRoomDefaultLocked;
		self.lobby_id = 0;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.id = [aDictionary stringValueForKey:@"id" defaultValue:kPNRoomDefaultID];
		PNCLog(PNLOG_CAT_MODEL_PARSER,@"self.id = %@",self.id);

		self.max_members = [aDictionary intValueForKey:@"max_members" defaultValue:kPNRoomDefaultMaximumMembers];
		self.is_public = [aDictionary boolValueForKey:@"is_public" defaultValue:kPNRoomDefaultPublic];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:kPNRoomDefaultName];
		if ([aDictionary hasObjectForKey:@"memberships"]){
			self.memberships = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
			for (NSDictionary *membership in [aDictionary objectForKey:@"memberships"]){
				[(NSMutableArray*)_memberships addObject:
				 [[[PNMembershipModel alloc] initWithDictionary:membership] autorelease]];
			}
		}
		if ([aDictionary hasObjectForKey:@"lobby_id"]){
			self.lobby_id = [[aDictionary objectForKey:@"lobby_id"] intValue];
		}
		self.is_locked = [aDictionary boolValueForKey:@"is_locked" defaultValue:kPNRoomDefaultLocked];

	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc{
	self.id				= nil;
	self.name			= nil;
	self.memberships	= nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n id:%@\n name:%@\n max_members:%d\n is_public:%d\n memberships:%p\n is_locked:%d",
			NSStringFromClass([self class]),self,_id, _name, _max_members, _is_public, _memberships, _is_locked];
}

@end
