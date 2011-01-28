#import "PNFriend.h"
#import "PNFriend+Package.h"
#import "PNUserModel.h"
#import "PNGlobal.h"

@implementation PNFriend (Package)

@dynamic gradeEnabled;

@dynamic userName;
@dynamic iconUrl;
@dynamic countryCode;
@dynamic achievementPoint;
@dynamic gradeName;
@dynamic gradePoint;
@dynamic isFollowing;
@dynamic isBlocking;

- (void)setUserName:(NSString*)arg { PNSETPROP(userName,arg); }
- (void)setIconUrl:(NSString*)arg { PNSETPROP(iconUrl,arg); }
- (void)setCountryCode:(NSString*)arg { PNSETPROP(countryCode,arg); }
- (void)setAchievementPoint:(NSString*)arg { PNSETPROP(achievementPoint,arg); }
- (void)setGradeName:(NSString*)arg { PNSETPROP(gradeName,arg); }
- (void)setGradePoint:(NSString*)arg { PNSETPROP(gradePoint,arg); }
- (void)setIsFollowing:(BOOL)arg { PNPSETPROP(isFollowing,arg); }
- (void)setIsBlocking:(BOOL)arg { PNPSETPROP(isBlocking,arg); }
- (void)setGradeEnabled:(BOOL)arg { PNPSETPROP(gradeEnabled,arg); }

- (NSString*)userName { PNGETPROP(NSString*,userName); }
- (NSString*)iconUrl { PNGETPROP(NSString*,iconUrl); }
- (NSString*)countryCode { PNGETPROP(NSString*,countryCode); }
- (NSString*)achievementPoint { PNGETPROP(NSString*,achievementPoint); }
- (NSString*)gradeName { PNGETPROP(NSString*,gradeName); }
- (NSString*)gradePoint { PNGETPROP(NSString*,gradePoint); }
- (BOOL)isFollowing { PNGETPROP(BOOL,isFollowing); }
- (BOOL)isBlocking { PNGETPROP(BOOL,isBlocking); }
- (BOOL)gradeEnabled { PNGETPROP(BOOL,gradeEnabled); }

- (id)initWithUserModel:(PNUserModel*)model
{
	if (self = [self init]){
		self.userName         = model.username;
		self.iconUrl          = model.icon_url;
		self.countryCode      = model.country;
		if (model.install.achievement_status.achievement_total) {
			self.achievementPoint = [NSString stringWithFormat:@"%d/%d",
									 model.install.achievement_status.achievement_point, model.install.achievement_status.achievement_total];
		}
		self.gradeName        = model.install.grade_status.grade.name;
		self.gradePoint       = [NSString stringWithFormat:@"%d", model.install.grade_status.grade_point];
		self.gradeEnabled     = model.install.game.grade_enabled;
		self.isFollowing      = model.is_following;
		self.isBlocking			= model.is_blocking;
		
		if (model.twitter != nil) {
			self.twitterId				= [NSString stringWithFormat:@"%d", model.twitter.id];
		}
		if ([model.icon_used isEqualToString:@"TWITTER"]) {
			iconType = PNUserIconTypeTwitter;
		} else {
			iconType = PNUserIconTypeDefault;
		}
		
	}
	return self;
}

@end


@implementation PNFriend

@dynamic userName, iconUrl, countryCode, achievementPoint, gradeName, gradePoint, isFollowing, isBlocking;
@synthesize iconType, twitterId;
-(id)init
{
	if([super init]){
		
	}
	return self;
}

-(void)dealloc
{	
	self.userName			= nil;
	self.iconUrl			= nil;
	self.countryCode		= nil;
	self.achievementPoint	= nil;
	self.gradeName			= nil;
	self.gradePoint			= nil;
	self.twitterId			= nil;
	[super dealloc];
}

@end
