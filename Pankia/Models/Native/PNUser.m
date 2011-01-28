#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNError.h"
#import "JsonHelper.h"
#import "PNAchievementRequestHelper.h"
#import "PNUserModel.h"
#import "PNSessionModel.h"
#import "PNUserManager.h"
#import "PNLogger+Package.h"
#import "PNGlobal.h"
#import "Helpers.h"

#import "PNSocialServiceConnector.h"


#define kPNOfflineGuestAccount							@"PLAYER"
#define kPNDefaultGradeName								@""

//user cache data paths
#define	kPNUsersUserNameCache							@"PN_USER_USERNAME_CACHE"
#define	kPNUsersCountrycodeCache						@"PN_USER_COUNTRYCODE_CACHE"
#define	kPNUsersIconURLCache							@"PN_USER_ICONURL_CACHE"
#define kPNUsersGuestCache								@"PN_USER_ISGUEST_CACHE"
#define	kPNUsersGradeNameCache							@"PN_USER_GRADENAME_CACHE"
#define	kPNUsersGradePointCache							@"PN_USER_GRADEPOINT_CACHE"
#define	kPNUsersAchievementPointCache					@"PN_USER_ACHIEVEMENTPOINT_CACHE"
#define	kPNUsersAchievementTotalCache					@"PN_USER_ACHIEVEMENTTOTAL_CACHE"
#define	kPNUsersSecuredCache							@"PN_USER_ISSECURED_CACHE"
#define kPNUsersUserIDCache								@"PN_USER_USERID_CACHE"
#define kPNUsersExternalIDCache								@"PN_USER_EXTERNALID_CACHE"


static PNUser	*p_currentUser	= nil;
static int		p_dedupCounter	= 1;


@implementation PNUser(Package)

@dynamic udid;
@dynamic username;
@dynamic status;
@dynamic countryCode;
@dynamic iconURL;
@dynamic gradePoint;
@dynamic gradeName;
@dynamic achievementPoint;
@dynamic achievementTotal;
@dynamic twitterId;
@dynamic twitterAccount;
// BEGIN - lerry added code
@dynamic facebookId;
@dynamic facebookAccount;
// END - lerry added code
@dynamic gradeId;

-(void)setUdid:(NSString *)arg { PNSETPROP(udid,arg); }
-(void)setUsername:(NSString *)arg { PNSETPROP(username,arg); }
-(void)setStatus:(NSString *)arg { PNSETPROP(status,arg); }
-(void)setCountryCode:(NSString *)arg { PNSETPROP(countryCode,arg); }
-(void)setIconURL:(NSString *)arg { PNSETPROP(iconURL,arg); }
-(void)setGradePoint:(int)arg { PNPSETPROP(gradePoint,arg); }
-(void)setGradeName:(NSString *)arg { PNSETPROP(gradeName,arg); }
-(void)setAchievementPoint:(int)arg { PNPSETPROP(achievementPoint,arg); }
-(void)setAchievementTotal:(int)arg { PNPSETPROP(achievementTotal,arg); }
-(void)setTwitterId:(NSString *)arg { PNSETPROP(twitterId,arg); }
-(void)setTwitterAccount:(NSString *)arg { PNSETPROP(twitterAccount,arg); }
// BEGIN - lerry added code
-(void)setFacebookId:(NSString*)arg { PNSETPROP(facebookId,arg); }
-(void)setFacebookAccount:(NSString*)arg { PNSETPROP(facebookAccount, arg); }
// END - lerry added code
-(void)setGradeId:(int)arg { PNPSETPROP(gradeId,arg); }
-(void)setExternalId:(NSString *)arg { PNPSETPROP(externalId,arg); }

-(NSString*)udid { PNGETPROP(NSString*,udid); }
-(NSString*)username { PNGETPROP(NSString*,username); }
-(NSString*)status { PNGETPROP(NSString*,status); }
-(NSString*)countryCode { PNGETPROP(NSString*,countryCode); }
-(NSString*)iconURL { PNGETPROP(NSString*,iconURL); }
-(int)gradePoint { PNGETPROP(int,gradePoint); }
-(NSString*)gradeName { PNGETPROP(NSString*,gradeName); }
-(int)achievementPoint { PNGETPROP(int,achievementPoint); }
-(int)achievementTotal { PNGETPROP(int,achievementTotal); }
-(NSString*)twitterId { PNGETPROP(NSString*,twitterId); }
-(NSString*)twitterAccount { PNGETPROP(NSString*,twitterAccount); }
// BEGIN - lerry added code
-(NSString*)facebookId { PNGETPROP(NSString*,facebookId); }
-(NSString*)facebookAccount { PNGETPROP(NSString*,facebookAccount); }
// END - lerry added code
-(int)gradeId { PNGETPROP(int,gradeId); }
-(NSString*)externalId { PNGETPROP(NSString*,externalId); }


@dynamic userId;
@dynamic sessionId;
@dynamic publicSessionId;
@dynamic gameId;
@dynamic isSecured;
@dynamic isLinkTwitter;
@dynamic isLinkFacebook;
@dynamic isGuest;
@dynamic gradeEnabled;
@dynamic natType;
@dynamic coins;


-(void)setUserId:(NSString*)arg { PNSETPROP(userId,arg); }
-(void)setSessionId:(NSString*)arg { PNSETPROP(sessionId,arg); }
-(void)setPublicSessionId:(NSString*)arg { PNSETPROP(publicSessionId,arg); }
-(void)setGameId:(NSString*)arg { PNSETPROP(gameId,arg); }
-(void)setNatType:(PNNATType)arg { PNPSETPROP(natType,arg); }
-(void)setGradeEnabled:(BOOL)arg { PNPSETPROP(gradeEnabled,arg); }
-(void)setIsLinkTwitter:(BOOL)arg { PNPSETPROP(isLinkTwitter,arg); }
-(void)setIsGuest:(BOOL)arg { PNPSETPROP(isGuest,arg); }
-(void)setIsSecured:(BOOL)arg { PNPSETPROP(isSecured,arg); }
-(void)setCoins:(int64_t)arg { PNPSETPROP(coins,arg); }

-(NSString*)userId{ PNGETPROP(NSString*,userId); }
-(NSString*)sessionId{ PNGETPROP(NSString*,sessionId); }
-(NSString*)publicSessionId{ PNGETPROP(NSString*,publicSessionId); }
-(NSString*)gameId{ PNGETPROP(NSString*,gameId); }
-(PNNATType)natType{ PNGETPROP(PNNATType,natType); }
-(BOOL)gradeEnabled{ PNGETPROP(BOOL,gradeEnabled); }
-(BOOL)isLinkTwitter{ PNGETPROP(BOOL,isLinkTwitter); }
-(BOOL)isLinkFacebook{ PNGETPROP(BOOL,isLinkFacebook); }
-(BOOL)isGuest{ PNGETPROP(BOOL,isGuest); }
-(BOOL)isSecured{ PNGETPROP(BOOL,isSecured); }
-(NSUInteger)coins{ PNGETPROP(NSUInteger,coins); }





- (id)initWithUserModel:(PNUserModel *)model
{
	if (self = [super init]) {
		self.sessionId                  = nil;
		self.publicSessionId			= nil;
		self.gameId                     = nil;
		self.natType                    = kPNUnknownNAT;
		[self updateFieldsFromUserModel:model];
	}
	return  self;
}

- (void)updateFieldsFromUserModel:(PNUserModel*)aModel
{
	if (aModel.id) {
		self.userId = [NSString stringWithFormat:@"%d", aModel.id];
	}
	
	if (aModel.username) {
		self.username                     = aModel.username;		
	}
	
	if (aModel.country) {
		self.countryCode                = aModel.country;		
	}
	
	if (aModel.icon_url) {
		self.iconURL                    = aModel.icon_url;
	}
	
	self.gradeEnabled				= aModel.install.grade_status != nil;
	
	if (aModel.install.grade_status.grade.name) {
		self.gradeName              = aModel.install.grade_status.grade.name;		
	}
	
	if (aModel.install.grade_status.grade.id) {
		self.gradeId              = aModel.install.grade_status.grade.id;		
	}	
	self.achievementPoint		= aModel.install.achievement_status.achievement_point;		
	if (aModel.install.grade_status.grade_point != kPNGradeDefaultPoint) {
		self.gradePoint             = aModel.install.grade_status.grade_point;
	}	
	self.achievementTotal		= aModel.install.achievement_status.achievement_total;		
	
	if (self.isGuest				== YES) {
		self.isGuest				= aModel.is_guest;
	}	
	if (self.isSecured				== NO) {
		self.isSecured				= aModel.is_secured;
	}
	
	if (aModel.install != nil && aModel.install.coin_ownership) {
		self.coins = aModel.install.coin_ownership.quantity;
	} else {
		PNCLog(PNLOG_CAT_ITEM, @"User model doesn't have coin_ownership model.");
//		self.coins = 0;
	}

	
	if (aModel.twitter != nil) {
		self.twitterId				= [NSString stringWithFormat:@"%d", aModel.twitter.id];
		self.twitterAccount			= aModel.twitter.screen_name;
	}
	else {
		self.twitterId				= [NSString stringWithFormat:@"%d", kPNTwitterDefaultID];
		self.twitterAccount			= kPNTwitterDefaultScreenName;
	}
	
	if ([aModel.icon_used isEqualToString:@"TWITTER"]) {
		iconType = PNUserIconTypeTwitter;
	} else {
		self.iconURL = nil;
	}
	
	// BEGIN - lerry added code
	if (aModel.facebook != nil) {
		self.facebookId = [NSString stringWithFormat:@"%lld", aModel.facebook.id];
		self.facebookAccount = aModel.facebook.name;
	} else {
		self.facebookId = @"";
		self.facebookAccount = kPNFacebookDefaultScreenName;
	}
	
	if (aModel.externalId != nil) {
		self.externalId = aModel.externalId;
	}
	
	// END - lerry added code
}

- (void)socialServiceConnectorDidReceiveTwitterIconURL:(NSString*)twitterIconURL
{
	NSLog(@"didReceiveTwitterURL: %@", twitterIconURL);
}

- (void)updateFieldsFromSessionModel:(PNSessionModel *)model
{
	PNUserModel* userModel = model.user;
	PNGameModel* gameModel = model.game;
	
	self.sessionId                  = model.id;
	self.publicSessionId			= nil;
	self.gameId                     = [NSString stringWithFormat:@"%d",gameModel.id];
	self.natType                    = kPNUnknownNAT;
	
	self.isGuest					= model.user.is_guest;
	
	self.gradeEnabled				= gameModel.grade_enabled;

	[self updateFieldsFromUserModel:userModel];
	
}

- (void) dealloc
{
	self.userId						= nil;
	self.sessionId                  = nil;
	self.publicSessionId			= nil;
	self.gameId                     = nil;
	
	self.udid                       = nil;
	self.username                   = nil;
	self.status                     = nil;
	self.gradeName					= nil;
	self.countryCode                = nil;
	self.iconURL                    = nil;
	self.twitterId					= nil;
	self.twitterAccount				= nil;
	
	[super dealloc];
}


+(PNUser*)user
{
	return [[[PNUser alloc] init] autorelease];
}

+(NSString*)session
{
	return [PNUser currentUser].sessionId;
}

+(int)currentUserId
{	
	if ([PNUser currentUser] != nil && [PNUser currentUser].isGuest == NO && [PNUser currentUser].userId != nil){
		return [[PNUser currentUser].userId intValue];
	}else{
		return 0;
	}
}

// BEGIN - lerry added code
- (BOOL)isLinkedWithFacebook
{
	return ([self.facebookId longLongValue] > 0);
}
// END - lerry added code

- (void)downloadLatestStatusFromServer
{
	[[PNUserManager sharedObject] getDetailsOfUser:[PNUser currentUser].username 
										   include:@"enrollments" 
										  delegate:self 
									   onSucceeded:@selector(gotDetailsOfCurrentUser:)
										  onFailed:nil];
}
- (void)gotDetailsOfCurrentUser:(PNUserModel*)userModel{
	[[PNUser currentUser] updateFieldsFromUserModel:userModel];
}

- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNLog(@"%@ %d",error.message,error.errorType);
}


+(PNUser*)loadFromCache
{
	PNUser*	cacheUser			= [PNUser user];
	cacheUser.username			= [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersUserNameCache];
	cacheUser.externalId		= [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersExternalIDCache];
	cacheUser.countryCode		= [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersCountrycodeCache];
	cacheUser.iconURL			= [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersIconURLCache];
	cacheUser.gradeName			= [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersGradeNameCache];
	cacheUser.userId			= [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersUserIDCache];
	
	if(!cacheUser.udid){
		cacheUser.udid = [UIDevice currentDevice].uniqueIdentifier;
	}
	if(!cacheUser.username) {
		double rndNum = arc4random()%100000;	
		//p_currentUser.username = [NSString stringWithFormat:@"%@%.0f",[[UIDevice currentDevice] model],rndNum];
		cacheUser.username = [NSString stringWithFormat:@"%@%.0f",kPNOfflineGuestAccount,rndNum];
	}
	if (!cacheUser.countryCode) {
		cacheUser.countryCode = kPNCountryCodeDefault;
	}
	
	NSString* is_guest;
	if (is_guest = [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersGuestCache]) {
		cacheUser.isGuest		= [is_guest boolValue];
	}
	else {
		cacheUser.isGuest = YES;
	}
	
	NSString* grade_point;
	if (grade_point = [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersGradePointCache]) {
		cacheUser.gradePoint	= [grade_point intValue];	
	}
	
	NSString* achievement_point;
	if (achievement_point = [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersAchievementPointCache]) {
		cacheUser.achievementPoint =  [achievement_point intValue];	
	}	
	
	NSString* achievement_total;
	if (achievement_total = [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersAchievementTotalCache]) {
		cacheUser.achievementTotal =  [achievement_total intValue];	
	}	
	
	NSString* is_secured;
	if (is_secured = [[NSUserDefaults standardUserDefaults] stringForKey:kPNUsersGuestCache]) {
		cacheUser.isSecured		= [is_secured boolValue];
	}	
	else {
		cacheUser.isSecured = NO;
	}
	
	if (cacheUser.gradeName = nil) {
		cacheUser.gradeName = kPNDefaultGradeName;
	}
	
	return cacheUser;
}

/**
 そのユーザの情報をカレントユーザとしてNSUserDefaultsに保存します。
 そうすることで、次回起動時にインターネットに接続されていない状況でもユーザ情報を復元することができます。
 */
- (void)saveToCacheAsCurrentUser{
	[[NSUserDefaults standardUserDefaults] setObject:self.username			forKey:kPNUsersUserNameCache];
	[[NSUserDefaults standardUserDefaults] setObject:self.externalId			forKey:kPNUsersExternalIDCache];	
	[[NSUserDefaults standardUserDefaults] setObject:self.countryCode		forKey:kPNUsersCountrycodeCache];	
	[[NSUserDefaults standardUserDefaults] setObject:self.iconURL			forKey:kPNUsersIconURLCache];	
	[[NSUserDefaults standardUserDefaults] setObject:self.gradeName			forKey:kPNUsersGradeNameCache];	
	[[NSUserDefaults standardUserDefaults] setObject:self.userId			forKey:kPNUsersUserIDCache];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.isGuest]				forKey:kPNUsersGuestCache];	
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.gradePoint]			forKey:kPNUsersGradePointCache];		
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.achievementPoint]	forKey:kPNUsersAchievementPointCache];	
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.achievementPoint]	forKey:kPNUsersAchievementTotalCache];
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.isSecured]			forKey:kPNUsersSecuredCache];	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(int)countUpDedupCounter
{
	p_dedupCounter++;
	return p_dedupCounter;
	
}

-(NSString*)verifierStringWithGameSecret:(NSString*)gameSecret
{
	NSString* verifierSourceString = [[NSArray arrayWithObjects:gameSecret, 
									   self.sessionId, [NSString stringWithFormat:@"%d",p_dedupCounter], nil]
									  componentsJoinedByString:@""];
	return [NSData sha1FromString:verifierSourceString];
}

@end


@implementation PNUser
@dynamic udid;
@dynamic username;
@dynamic status;
@dynamic countryCode;
@dynamic iconURL;
@dynamic gradePoint;
@dynamic gradeName;
@dynamic achievementPoint;
@dynamic achievementTotal;
@dynamic twitterId;
@dynamic twitterAccount;
// BEGIN - lerry added code
@dynamic facebookId;
@dynamic facebookAccount;
// END - lerry added code
@dynamic gradeId;
@synthesize coins;
@synthesize iconType;
@dynamic externalId;

+(PNUser*) currentUser
{
	@synchronized(self) {
        if (p_currentUser == nil) {
			p_currentUser.udid = [UIDevice currentDevice].uniqueIdentifier;
			p_currentUser = [[PNUser loadFromCache] retain];
        }
    }
	return p_currentUser;
}


- (id) init
{
	if (self = [super init]) {
		self.sessionId                  = nil;
		self.publicSessionId			= nil;
		self.gameId                     = nil;
		self.udid                       = nil;
		self.username                     = nil;
		self.countryCode                = nil;
		self.gradeName                  = nil;
		self.iconURL                    = nil;
		self.isGuest                    = YES;
		self.achievementPoint			= 0;
		self.gradePoint                 = 0;
		self.achievementTotal			= 0;
		self.isSecured                  = NO;
		self.natType                    = kPNUnknownNAT;
		self.gradeId					= kPNGradeDefaultID;
	}
	
	return  self;
}

@end

