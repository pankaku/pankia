#import "PNMatchModel.h"
#import "PNUserModel.h"

@implementation PNMatchModel
@synthesize id = _id, room_id = _room_id, users = _users, start_at = _start_at, end_at = _end_at;

- (id) init
{
	if (self = [super init]) {
		self.id			= -1;
		self.room_id	= nil;
		self.users		= [NSMutableArray array];
		self.start_at	= nil;
		self.end_at		= nil;
	}
	
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (self = [self init]) {
		self.id	= [[aDictionary objectForKey:@"id"] intValue];
		self.room_id = [aDictionary objectForKey:@"room_id"];
		for(NSDictionary* u in [aDictionary objectForKey:@"users"]) {
			[self.users addObject:[PNUserModel dataModelWithDictionary:u]];
		}
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc
{
	self.users = nil;
	self.start_at = nil;
	self.end_at = nil;
	[super dealloc];
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ :%p>\n->id: %d\n->room_id: %d\n->users %p",
			NSStringFromClass([self class]),self,_id, _room_id, _users];
}

@end
