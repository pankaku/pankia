#import "PNVersionModel.h"


@implementation PNVersionModel
@synthesize isCurrent = _isCurrent, name = _name, value = _value;

- (id) init{
	if (self = [super init]){
		self.isCurrent = NO;
		self.name = @"";
		self.value = @"";
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.isCurrent = [aDictionary boolValueForKey:@"is_current" defaultValue:NO];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:@""];
		self.value = [aDictionary stringValueForKey:@"value" defaultValue:@""];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc{
	self.name = nil;
	self.value = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n->name: %@\n->value: %@\n->isCurrent: %d",
			NSStringFromClass([self class]),self,_name, _value, _isCurrent];
}
@end
