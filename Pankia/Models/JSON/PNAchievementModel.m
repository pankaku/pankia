#import "PNAchievementModel.h"

//Achievement
#define kPNAchievementDefaultID						-1
#define kPNAchievementDefaultName					@""
#define kPNAchievementDefaultDescription			@""
#define kPNAchievementDefaultIconURL				@""
#define kPNAchievementDefaultValue					0
#define kPNAchievementDefaultSecret					NO

@implementation PNAchievementModel

@synthesize id = _id;
@synthesize name = _name;
@synthesize description = _description;
@synthesize value = _value;
@synthesize icon_url = _icon_url;
@synthesize is_secret = _is_secret;

- (id) init{
	if (self = [super init]){
		self.id = kPNAchievementDefaultID;
		self.name = kPNAchievementDefaultName;
		self.description = kPNAchievementDefaultDescription;
		self.value = kPNAchievementDefaultValue;
		self.icon_url = kPNAchievementDefaultIconURL;
		self.is_secret = kPNAchievementDefaultSecret;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		self.id = [aDictionary intValueForKey:@"id" defaultValue:kPNAchievementDefaultID];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:kPNAchievementDefaultName];
		self.description = [aDictionary stringValueForKey:@"description" defaultValue:kPNAchievementDefaultDescription];
		self.value = [aDictionary intValueForKey:@"value" defaultValue:kPNAchievementDefaultValue];
		self.icon_url = [aDictionary stringValueForKey:@"icon_url" defaultValue:kPNAchievementDefaultIconURL];
		self.is_secret = [aDictionary boolValueForKey:@"is_secret" defaultValue:kPNAchievementDefaultSecret];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", [self description]);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	self.name			= nil;
	self.description	= nil;
	self.icon_url		= nil;
	[super dealloc];
}

//名前がdescriptionの変数とかぶってる。
-(NSString*)description_{ 
	return [NSString stringWithFormat:@"<%@ :%p>\n id:%d\n name:%@\n description:%@\n value:%d\n icon_url:%@\n is_secret:%d",
			NSStringFromClass([self class]),self,_id, _name, _description, _value, _icon_url, _is_secret];
}

@end
