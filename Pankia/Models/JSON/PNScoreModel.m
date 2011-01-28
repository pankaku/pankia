#import "PNScoreModel.h"

//Score
#define kPNScoreDefaultValue								0

@implementation PNScoreModel
@synthesize value = _value, user = _user;

- (id) init{
	if (self = [super init]){
		self.user = nil;
		self.value = kPNScoreDefaultValue;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		id valueNode = [aDictionary objectForKey:@"value"];
		if ([valueNode isKindOfClass:[NSNull class]]){
			self.value = 0;
		} else if([valueNode isKindOfClass:[NSNumber class]]) {
			self.value = [valueNode longLongValue];
		}else {
			PNWarn(@"Error at parsing: Unknown class %@\n%@", NSStringFromClass([valueNode class]), aDictionary);
		}
		
		if ([aDictionary hasObjectForKey:@"user"]){
			self.user = [[[PNUserModel alloc] initWithDictionary:[aDictionary objectForKey:@"user"]] autorelease];
		}
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc{
	self.user	= nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n value:%d\n user:%p",
			NSStringFromClass([self class]),self,_value, _user];
}

@end
