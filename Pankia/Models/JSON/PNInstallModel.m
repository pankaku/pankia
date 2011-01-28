#import "PNInstallModel.h"
#import "PNGradeStatusModel.h"
#import "PNAchievementStatusModel.h"
#import "PNAchievementModel.h"

@implementation PNInstallModel

@synthesize grade_status = _grade_status;
@synthesize achievement_status = _achievement_status;
@synthesize game = _game;
@synthesize achievements = _achievements;
@synthesize coin_ownership = _coin_ownership;
@synthesize bonus_coins_count = _bonus_coins_count;

- (id) init{
	if (self = [super init]){
		self.grade_status = nil;
		self.achievement_status = nil;
		self.achievements = nil;
		self.game = nil;
		self.coin_ownership = nil;
    self.bonus_coins_count = 0;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		if (aDictionary == nil || [aDictionary isKindOfClass:[NSNull class]]) {
			return nil;
		}
		
		if ([aDictionary hasObjectForKey:@"achievement_status"]){
			self.achievement_status = [[[PNAchievementStatusModel alloc] 
								   initWithDictionary:[aDictionary objectForKey:@"achievement_status"]] autorelease];
		}
		if ([aDictionary hasObjectForKey:@"grade_status"]){
			self.grade_status = [[[PNGradeStatusModel alloc]
							 initWithDictionary:[aDictionary objectForKey:@"grade_status"]] autorelease];
		}
		if ([aDictionary hasObjectForKey:@"game"]){
			self.game = [[[PNGameModel alloc] initWithDictionary:[aDictionary objectForKey:@"game"]] autorelease];
		}
		if ([aDictionary hasObjectForKey:@"coin_ownership"]) {
			self.coin_ownership = [PNItemOwnershipModel dataModelWithDictionary:[aDictionary objectForKey:@"coin_ownership"]];
		}
		if ([aDictionary hasObjectForKey:@"achievements"]){
			self.achievements = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
			for (NSDictionary *achievement in [aDictionary objectForKey:@"achievements"]){
				[(NSMutableArray*)_achievements addObject:
				  [[[PNAchievementModel alloc] initWithDictionary:achievement] autorelease ]];
			}
			
		}

		if ([aDictionary hasObjectForKey:@"bonus_coins_count"]) {
			self.bonus_coins_count = [[aDictionary objectForKey:@"bonus_coins_count"] integerValue];
		}

	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc{
	self.grade_status = nil;
	self.achievement_status = nil;
	self.achievements = nil;
	self.game = nil;
	self.coin_ownership = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>",
			NSStringFromClass([self class]),self];
}
@end
