#import "PNEventModel.h"
#import "PNUserModel.h"
#import "PNMembershipModel.h"
#import "PNMatchModel.h"

@implementation PNEventDataModel
@synthesize max_rtt = _max_rtt, maxed_out = _maxed_out, membership = _membership, match = _match;

- (id) init
{
	if (self = [super init]){
		self.max_rtt = -1;
		self.maxed_out = -1;
		self.membership = nil;
		self.match = nil;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
#define ISNULL(a) ((a) && (a)!=[NSNull null])
	if (self = [self init]) {
		if(ISNULL([aDictionary objectForKey:@"max_rtt"]))
			self.max_rtt = [[aDictionary objectForKey:@"max_rtt"] intValue];
		if(ISNULL([aDictionary objectForKey:@"maxed_out"]))
			self.maxed_out = [[aDictionary objectForKey:@"maxed_out"] intValue];
		if(ISNULL([aDictionary objectForKey:@"membership"]))
			self.membership = [PNMembershipModel dataModelWithDictionary:[aDictionary objectForKey:@"membership"]];
		if(ISNULL([aDictionary objectForKey:@"match"]))
			self.match = [PNMatchModel dataModelWithDictionary:[aDictionary objectForKey:@"match"]];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc
{
	self.membership = nil;
	self.match = nil;
	[super dealloc];
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ :%p>\n->max_rtt: %d\n->maxed_out: %d\n->membership %p",
			NSStringFromClass([self class]),self,_max_rtt, _maxed_out, _membership];
}

@end

@implementation PNEventModel
@synthesize data = _data;
@synthesize topic = _topic;

- (id) init
{
	if (self = [super init]) {
		self.data	= nil;
		self.topic	= nil;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (self = [self init]) {
		self.data	= [PNEventDataModel dataModelWithDictionary:[aDictionary objectForKey:@"data"]];
		self.topic	= [aDictionary objectForKey:@"topic"];
	}
	return self;
}

- (void) dealloc
{
	self.data	= nil;
	self.topic	= nil;
	[super dealloc];
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ :%p>\n->data %p\n->topic %@",
			NSStringFromClass([self class]),self,_data,_topic];
}

@end
