#import "PNAchievement.h"
#import "PNAchievement+Package.h"
#import <sqlite3.h>
#import "NSString+VersionString.h"
#import "PNAchievementModel.h"
#import "PNAchievementManager.h"
#import "PNGlobal.h"
#import "PNParseUtil.h"

@implementation PNAchievement(Package)

@dynamic achievementId;
@dynamic title;
@dynamic description;
@dynamic value;
@dynamic iconUrl;
@dynamic isSecret;
@dynamic isUnlocked;
@dynamic orderNumber;

- (void)setAchievementId:(int)arg { PNPSETPROP(achievementId,arg); }
- (void)setTitle:(NSString*)arg { PNSETPROP(title,arg); }
- (void)setDescription:(NSString*)arg { PNSETPROP(description,arg); }
- (void)setValue:(NSUInteger)arg { PNPSETPROP(value,arg); }
- (void)setIconUrl:(NSString*)arg { PNSETPROP(iconUrl,arg); }
- (void)setIsSecret:(BOOL)arg { PNPSETPROP(isSecret,arg); }
- (void)setIsUnlocked:(BOOL)arg { PNPSETPROP(isUnlocked,arg); }
- (void)setOrderNumber:(int)arg { PNPSETPROP(orderNumber, arg); }

- (int)achievementId{ PNGETPROP(int,achievementId); }
- (NSString*)title{ PNGETPROP(NSString*,title); }
- (NSString*)description{ PNGETPROP(NSString*,description); }
- (NSUInteger)value{ PNGETPROP(NSUInteger,value); }
- (NSString*)iconUrl{ PNGETPROP(NSString*,iconUrl); }
- (BOOL)isSecret{ PNGETPROP(BOOL,isSecret); }
- (BOOL)isUnlocked{ PNGETPROP(BOOL,isUnlocked); }
- (int)orderNumber{ PNGETPROP(int,orderNumber); }

- (id)initWithAchievementId:(int)_achievementId{
	if (self = [self init]){
		self.achievementId = _achievementId;
		self.title = [NSString stringWithFormat:@"Achievement %d", _achievementId];
		self.description = [NSString stringWithFormat:@"Achievement description for %d", _achievementId];
	}
	return self;
}

- (id)initWithDataModel:(PNDataModel *)dataModel
{
	if (self = [super initWithDataModel:dataModel]) {
		PNAchievementModel* model = (PNAchievementModel*)dataModel;
		self.achievementId		= model.id;
		self.title	= model.name;
		self.description		= model.description;
		self.value			= model.value;
		self.iconUrl			= model.icon_url;
		self.isSecret			= model.is_secret;
		self.isUnlocked			= NO;
	}
	return self;
}
- (id)initWithAchievementModel:(PNAchievementModel*)model
{
	return [self initWithDataModel:model];
}

- (id)initWithDictionary:(NSDictionary*)dic
{
	if (self = [self init]) {
		PNAchievementModel* model = [[[PNAchievementModel alloc] initWithDictionary:dic] autorelease];
		self.achievementId		= model.id;
		self.title	= model.name;
		self.description		= model.description;
		self.value			= model.value;
		self.iconUrl			= model.icon_url;
		self.isSecret			= model.is_secret;
		self.isUnlocked			= NO;
	}
	return self;
}

- (id)initWithLocalDictionary:(NSDictionary*)dictionary
{
	if (self = [self init]) {
		self.achievementId = [dictionary intValueForKey:@"id" defaultValue:0];
		self.isSecret = [dictionary boolValueForKey:@"is_secret" defaultValue:NO];
		maxVersion = [[dictionary objectForKey:@"max_version"] versionIntValue];
		minVersion = [[dictionary objectForKey:@"min_version"] versionIntValue];
		self.value = [dictionary intValueForKey:@"value" defaultValue:0];
		
		NSDictionary* translations = [dictionary objectForKey:@"translations"];
		self.title = [PNParseUtil localizedStringForKey:@"name" inDictionary:translations defaultValue:@"-"];
		self.description = [PNParseUtil localizedStringForKey:@"description" inDictionary:translations defaultValue:@"-"];
	}
	return self;
}

@end


@implementation PNAchievement

@dynamic achievementId, title, description, value, iconUrl, isSecret, isUnlocked;
@synthesize id = achievementId;

// ソート用のメソッドです
// achievementIdを使ってソートするときに使用します
- (NSComparisonResult)compareId:(PNAchievement *)achievement {
	if (self.achievementId > achievement.achievementId ){
		return NSOrderedDescending;
	} else if (self.achievementId < achievement.achievementId){
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}
- (NSComparisonResult)compareOrderId:(PNAchievement *)achievement {
	if (self.orderNumber > achievement.orderNumber ){
		return NSOrderedDescending;
	} else if (self.orderNumber < achievement.orderNumber){
		return NSOrderedAscending;
	} else {
		return [self compareId:achievement];
	}
}


-(void)dealloc
{
	self.title			= nil;
	self.description				= nil;
	self.iconUrl					= nil;
	[super dealloc];
}


@end
