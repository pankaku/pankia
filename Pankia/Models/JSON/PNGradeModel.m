#import "PNGradeModel.h"


@implementation PNGradeModel

@synthesize id = _id;
@synthesize name = _name;
@synthesize point = _point;

- (id) init{
	if (self = [super init]){
		self.id = kPNGradeDefaultID;
		self.point = kPNGradeDefaultPoint;
		self.name = kPNGradeDefaultName;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		if((NSNull*)aDictionary != [NSNull null]) {
			self.id = [aDictionary intValueForKey:@"id" defaultValue:kPNGradeDefaultID];
			self.name = [aDictionary stringValueForKey:@"name" defaultValue:kPNGradeDefaultName];
			self.point = [aDictionary intValueForKey:@"point" defaultValue:kPNGradeDefaultPoint];
		}
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	self.name		= nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n id:%d\n name:%@\n point:%d",
			NSStringFromClass([self class]),self,_id, _name, _point];
}


@end
