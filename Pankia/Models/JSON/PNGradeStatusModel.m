#import "PNGradeStatusModel.h"

//GradeStatus
#define kPNGradeStatusDefaultPoint						0

@implementation PNGradeStatusModel

@synthesize grade_point = _grade_point;
@synthesize grade = _grade;

- (id) init{
	if (self = [super init]){
		self.grade = nil;
		self.grade_point = kPNGradeStatusDefaultPoint;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.grade_point = [aDictionary intValueForKey:@"grade_point" defaultValue:kPNGradeStatusDefaultPoint];
		self.grade = [[[PNGradeModel alloc] initWithDictionary:[aDictionary objectForKey:@"grade"]] autorelease];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	self.grade		= nil;
	[super dealloc];

}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n grade=%p\n grade_point=%d",
			NSStringFromClass([self class]),self,_grade, self.grade_point];
}

@end
