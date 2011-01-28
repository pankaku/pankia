//
//  PNGlobalManager.m
//  PankakuNet
//
//  This class can be referred from anywhere!
//

#import "PNGlobalManager.h"
#import "NSDictionary+GetterExt.h"

static PNGlobalManager* _sharedInstance;

@interface PNGlobalManager ()
@property (nonatomic, retain) NSMutableDictionary* globalDictionary;
@end

@implementation PNGlobalManager
@synthesize globalDictionary;

- (void)setGameKey:(NSString *)value
{
	[globalDictionary setObject:value forKey:@"game_key"];
}
- (NSString*)gameKey
{
	return [self stringForKey:@"game_key"];
}
- (void)setGameSecret:(NSString *)value
{
	[globalDictionary setObject:value forKey:@"game_secret"];
}
- (NSString*)gameSecret
{
	return [self stringForKey:@"game_secret"];
}
- (void)setGameTitle:(NSString *)value
{
	[globalDictionary setObject:value forKey:@"game_title"];
}
- (NSString*)gameTitle
{
	return [self stringForKey:@"game_title"];
}

- (void)setSessionId:(NSString *)value
{
	[globalDictionary setObject:value forKey:@"session_id"];
}
- (NSString*)sessionId
{
	return [self stringForKey:@"session_id"];
}
- (void)setStartupDate:(NSDate *)date
{
	[globalDictionary setObject:date forKey:@"startup_date"];
}
- (NSDate*)startupDate
{
	return [globalDictionary objectForKey:@"startup_date"];
}
- (void)setLaunchedFromLocalNotification:(BOOL)value
{
	[globalDictionary setObject:[NSNumber numberWithBool:value] forKey:@"launched_from_local_notification"];
}
- (BOOL)launchedFromLocalNotification
{
	return [[globalDictionary objectForKey:@"launched_from_local_notification"] boolValue];
}
- (void)setLocalNotificationUserInfo:(NSDictionary *)value
{
	[globalDictionary setObject:value forKey:@"local_notification_user_info"];
}
- (NSDictionary*)localNotificationUserInfo
{
	return [globalDictionary objectForKey:@"local_notification_user_info"];
}
- (void)setOriginalIdleTimerDisabled:(BOOL)value
{
	[globalDictionary setObject:[NSNumber numberWithBool:value] forKey:@"original_idle_timer_disabled"];
}
- (BOOL)originalIdleTimerDisabled
{
	return [[globalDictionary objectForKey:@"original_idle_timer_disabled"] boolValue];
}
#pragma mark -
- (void)setObject:(id)obj forKey:(NSString*)key
{
	[globalDictionary setObject:obj forKey:key];
}
- (id)objectForKey:(NSString*)key
{
	return [globalDictionary objectForKey:key];
}
- (NSString*)stringForKey:(NSString*)key
{
	id obj = [self objectForKey:key];
	if ([obj isKindOfClass:[NSString class]]) {
		return (NSString*)obj;
	} else {
		return @"";
	}
}

- (NSString*)preferedLanguage{
	return [(NSArray*)([[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]) objectAtIndex:0];
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		self.globalDictionary = [NSMutableDictionary dictionary];
	}	
	return self;
}

- (void) dealloc
{
	self.globalDictionary = nil;
	[super dealloc];
}

+ (PNGlobalManager *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
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

- (BOOL) matchEnabled
{
	id feature = [globalDictionary objectForKey:@"match_enabled"];
	if (feature!=nil) {
		return [feature boolValue];
	} else {
		return NO;
	}
}

- (BOOL) coinsEnabled
{
	id feature = [globalDictionary objectForKey:@"coin_enabled"];
	if (feature!=nil) {
		return [feature boolValue];
	} else {
		return NO;
	}
}

- (BOOL) itemEnabled
{
	return [globalDictionary boolValueForKey:@"item_enabled" defaultValue:NO];
}

@end
