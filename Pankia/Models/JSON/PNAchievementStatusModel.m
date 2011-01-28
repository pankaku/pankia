#import "PNAchievementStatusModel.h"

//Achievement Status
#define kPNAchievementStatusDefaultPoint		-1
#define kPNAchievementStatusDefaultTotal		-1

@implementation PNAchievementStatusModel

@synthesize achievement_point = _achievement_point;
@synthesize achievement_total = _achievement_total;

- (id) init{
	if (self = [super init]){
		self.achievement_point = kPNAchievementStatusDefaultPoint;
		self.achievement_total = kPNAchievementStatusDefaultTotal;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.achievement_point = [aDictionary intValueForKey:@"achievement_point" defaultValue:kPNAchievementStatusDefaultPoint];
		self.achievement_total = [aDictionary intValueForKey:@"achievement_total" defaultValue:kPNAchievementStatusDefaultTotal];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n achievement_point:%d\n achievement_total:%d",
			NSStringFromClass([self class]),self,_achievement_point, _achievement_total];
}

@end
