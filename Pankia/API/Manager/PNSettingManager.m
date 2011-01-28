#import "PNSettingManager.h"
#import "PNLeaderboard.h"
#import "PNGlobal.h"
#import "PNLobby.h"
#import "PNLogger+Package.h"

#import "NSString+VersionString.h"
#import "NSDictionary+GetterExt.h"

#define kPNUserSettingPListFile			@"PankiaNet"
#define kPNDefaultSettingPListFile		@"PankiaNetDefaults"
#define kPNSecondaryLanguage			@"en"
#define kPNDeviceRegisterCache			@"PN_DEVICE_REGISTER_CACHE"
#define kPNDeviceRegisterRequestCache	@"PN_DEVICE_REGISTER_REQUEST_CACHE"
#define kPNUserSettingInternetMatchMininumMember	@"PN_USER_SETTING_INTERNET_MATCH_MIN_MEMBER"
#define kPNUserSettingInternetMatchMaximumMember	@"PN_USER_SETTING_INTERNET_MATCH_MAX_MEMBER"
#define kPNUserSettingNearbyMatchMinimumMember		@"PN_USER_SETTING_NEARBY_MATCH_MIN_MEMBER"
#define kPNUserSettingNearbyMatchMaximumMember		@"PN_USER_SETTING_NEARBY_MATCH_MAX_MEMBER"
#define kPNUserSettingSideMenuEnabled				@"PN_USER_SETTING_SIDE_MENU_ENABLED"
#define kPNDefaultMatchMinimumMember 2
#define kPNDefaultMatchMaximumMember 4


NSDictionary* loadPlistFile(NSString* fileName){
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization
									   propertyListFromData:plistXML
									   mutabilityOption:NSPropertyListMutableContainersAndLeaves
									   format:&format
									   errorDescription:&errorDesc];
	if (!dictionary) {
		PNWarn(@"Load PLIST Error reading %@: %@, format: %d", fileName, errorDesc, format);
		return nil;
	}else{
		return dictionary;
	}
}

static PNSettingManager *sharedSettingManager = nil;

@interface PNSettingManager ()
@property (nonatomic, retain) NSDictionary* offlineSettingsDictionary;
@end

@implementation PNSettingManager
@synthesize matchEnabled, offlineSettingsDictionary;

- (id)init{
	if (self = [super init]){
		defaultDictionary = [loadPlistFile(kPNDefaultSettingPListFile) retain];
		userDictionary = [[NSMutableDictionary dictionaryWithDictionary:loadPlistFile(kPNUserSettingPListFile)] retain];
	}
	return self;
}

- (void)dealloc
{
	self.offlineSettingsDictionary = nil;
	PNSafeDelete(defaultDictionary);
	PNSafeDelete(userDictionary);
	[super dealloc];
}

#pragma mark -
+ (NSString*)pathForLocalSettingsPlist
{
	return [[NSBundle mainBundle] pathForResource:@"PNOfflineSettings" ofType:@"plist"];
}
+ (BOOL)hasLocalSettingPlist
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathForLocalSettingsPlist]];
}

- (NSDictionary*)offlineSettings
{
	if (self.offlineSettingsDictionary == nil) {
		NSString *errorDesc = nil;
		NSPropertyListFormat format;
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"PNOfflineSettings" ofType:@"plist"];
		NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
		NSDictionary *dictionary = (NSDictionary *)[NSPropertyListSerialization
													propertyListFromData:plistXML
													mutabilityOption:NSPropertyListMutableContainersAndLeaves
													format:&format
													errorDescription:&errorDesc];
		self.offlineSettingsDictionary = dictionary;
	}
	return self.offlineSettingsDictionary;
}

#pragma mark -
- (BOOL)boolValueForKey:(NSString*)key{
	if (userDictionary != nil && [userDictionary objectForKey:key] != nil) {
		return [[userDictionary objectForKey:key] boolValue];
	} else {
		if (defaultDictionary != nil && [defaultDictionary objectForKey:key] != nil) {
			return [[defaultDictionary objectForKey:key] boolValue];
		} else {
			return NO;
		}
	}
}

- (NSString*)stringValueForKey:(NSString*)key
{
	if (userDictionary != nil && [userDictionary objectForKey:key] != nil) {
		return [userDictionary objectForKey:key];
	} else {
		if (defaultDictionary != nil && [defaultDictionary objectForKey:key] != nil) {
			return [defaultDictionary objectForKey:key];
		} else {
			return @"";
		}
	}
}
- (int)intValueForKey:(NSString*)key
{
	if (userDictionary != nil && [self hasKey:key]){
		return [[userDictionary objectForKey:key] intValue];
	}else {
		if (defaultDictionary != nil && [defaultDictionary objectForKey:key] != nil) {
			return [[defaultDictionary objectForKey:key] intValue];
		} else {
			return 0;
		}

	}

}

- (BOOL)hasKey:(NSString*)key
{
	return ([userDictionary objectForKey:key] != nil);
}
- (void)setIntValue:(int)value forKey:(NSString*)key
{
	[userDictionary setObject:[NSNumber numberWithInt:value] forKey:key];
}
- (void)setBoolValue:(BOOL)value forKey:(NSString*)key
{
	[userDictionary setObject:[NSNumber numberWithBool:value] forKey:key];
}

#pragma mark -
- (NSString*)preferedLanguage{
	return [(NSArray*)([[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]) objectAtIndex:0];
}
- (NSArray*)lobbies{
	NSArray* lobbyDictionaries = [[[PNSettingManager sharedObject] offlineSettings] objectForKey:@"lobbies"];
	NSMutableArray *lobbyDetailsInCurrentLocale = [NSMutableArray array];

	if (lobbyDictionaries != nil){
		for (NSDictionary* lobbyDictionary in lobbyDictionaries) {
			[lobbyDetailsInCurrentLocale addObject:[[[PNLobby alloc] initWithLocalDictionary:lobbyDictionary] autorelease]];
		}
	}
	return [lobbyDetailsInCurrentLocale sortedArrayUsingSelector:@selector(compareOrderId:)];
}

- (void)setInternetMatchMinRoomMember:(int)minMember
{
	[self setIntValue:minMember forKey:kPNUserSettingInternetMatchMininumMember];
}
- (void)setInternetMatchMaxRoomMember:(int)maxMember
{
	[self setIntValue:maxMember forKey:kPNUserSettingInternetMatchMaximumMember];
}
- (void)setNearbyMatchMinRoomMember:(int)minMember
{
	[self setIntValue:minMember forKey:kPNUserSettingNearbyMatchMinimumMember];
}
- (void)setNearbyMatchMaxRoomMember:(int)maxMember
{
	[self setIntValue:maxMember forKey:kPNUserSettingNearbyMatchMaximumMember];
}
- (int)internetMatchMinRoomMember
{
	NSString* key = kPNUserSettingInternetMatchMininumMember;
	if ([self hasKey:key]) {
		return [self intValueForKey:key];
	} else {
		return kPNDefaultMatchMinimumMember;
	}
}
- (int)internetMatchMaxRoomMember
{
	NSString* key = kPNUserSettingInternetMatchMaximumMember;
	if ([self hasKey:key]) {
		return [self intValueForKey:key];
	} else {
		return kPNDefaultMatchMaximumMember;
	}
}
- (int)nearbyMatchMinRoomMember
{
	NSString* key = kPNUserSettingNearbyMatchMinimumMember;
	if ([self hasKey:key]) {
		return [self intValueForKey:key];
	} else {
		return kPNDefaultMatchMinimumMember;
	}
}
- (int)nearbyMatchMaxRoomMember
{
	NSString* key = kPNUserSettingNearbyMatchMaximumMember;
	if ([self hasKey:key]) {
		return [self intValueForKey:key];
	} else {
		return kPNDefaultMatchMaximumMember;
	}
}
- (void)setSideMenuEnabled:(BOOL)value
{
	[self setBoolValue:value forKey:kPNUserSettingSideMenuEnabled];
}
- (BOOL)isSideMenuEnabled
{
	NSString* key = kPNUserSettingSideMenuEnabled;
	if ([self hasKey:key]) {
		return [self boolValueForKey:key];
	} else {
		return YES;
	}
}

+ (int)currentVersionInt
{
	return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] versionIntValue];
}

#pragma mark -
+ (BOOL)storedBoolValueForKey:(NSString*)key defaultValue:(BOOL)defaultValue
{
	id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (obj == nil) {
		return defaultValue;
	} else {
		if ([obj respondsToSelector:@selector(boolValue)]) {
			return [((NSNumber*)obj) boolValue];
		} else {
			return defaultValue;
		}
	} 
}
+ (void)storeBoolValue:(BOOL)value forKey:(NSString*)key
{
	// begin - lerry modified
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
	// end - lerry modified
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Singleton pattern

+ (PNSettingManager*)sharedObject
{
    @synchronized(self) {
        if (sharedSettingManager == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return sharedSettingManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedSettingManager == nil) {
			sharedSettingManager = [super allocWithZone:zone];
			return sharedSettingManager;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}
@end
