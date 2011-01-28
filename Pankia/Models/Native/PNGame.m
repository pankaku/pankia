#import "PNGame.h"
#import "PNInstallModel.h"

@implementation PNGame

@synthesize gameTitle, description, iconUrl, achievementPoint, achievementTotal, gradeName, gradePoint, gameId, gradeEnabled;
@synthesize screenshotUrls, iTunesUrl, thumbnailUrls, developerName, price;

-(id)init
{
	if([super init]){
		self.screenshotUrls = [NSArray array];
		self.thumbnailUrls = [NSArray array];
		self.developerName = nil;
		self.price = nil;
	}
	return self;
}

- (id)initWithInstallModel:(PNInstallModel*)model
{
	if (self = [self init]){
		self.gameTitle        = model.game.name;
		self.description      = model.game.description;
		self.iconUrl          = model.game.icon_url;
		self.achievementPoint = [NSString stringWithFormat:@"%d", model.achievement_status.achievement_point];
		self.achievementTotal = [NSString stringWithFormat:@"%d", model.achievement_status.achievement_total];
		self.gradeName        = model.grade_status.grade.name;
		self.gradePoint       = [NSString stringWithFormat:@"%d", model.grade_status.grade_point];
		self.gameId           = [NSString stringWithFormat:@"%d", model.game.id];
		self.gradeEnabled	  = model.game.grade_enabled;
		self.developerName	= model.game.developer_name;
		self.price			= model.game.price;
	}
	return self;
}

-(void)dealloc
{
	self.gameTitle			= nil;
	self.description		= nil;
	self.iconUrl			= nil;
	self.achievementPoint	= nil;
	self.achievementTotal	= nil;
	self.gradeName			= nil;
	self.gradePoint			= nil;
	self.gameId				= nil;
	self.screenshotUrls		= nil;
	self.thumbnailUrls		= nil;
	self.iTunesUrl			= nil;
	self.developerName		= nil;
	self.price				= nil;
	
	[super dealloc];
}

@end
