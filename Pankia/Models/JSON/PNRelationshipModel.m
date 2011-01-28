#import "PNRelationshipModel.h"

//Relationship
#define kPNRelationshipDefaultID			-1
#define kPNRelationshipDefaultType			@""

@implementation PNRelationshipModel
@synthesize id = _id, type = _type, from = _from, to = _to;

- (id) init{
	if (self = [super init]){
		self.id = kPNRelationshipDefaultID;
		self.type = kPNRelationshipDefaultType;
		self.from = nil;
		self.to = nil;
	}
	return self;
}
- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.id = [aDictionary intValueForKey:@"id" defaultValue:kPNRelationshipDefaultID];
		self.type = [aDictionary stringValueForKey:@"type" defaultValue:kPNRelationshipDefaultType];
		if ([aDictionary hasObjectForKey:@"from"]) {
			self.from = [[[PNUserModel alloc] initWithDictionary:[aDictionary objectForKey:@"from"]] autorelease];
		}
		if ([aDictionary hasObjectForKey:@"to"]){
			self.to = [[[PNUserModel alloc] initWithDictionary:[aDictionary objectForKey:@"to"]] autorelease];
		}
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}
- (void)dealloc{
	self.type		= nil;
	self.from		= nil;
	self.to		= nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n id:%d\n type:%@\n from:%p\n to:%p",
			NSStringFromClass([self class]),self,_id, _type, _from, _to];
}

@end
