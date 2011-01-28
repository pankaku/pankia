#import "PNTwitterManager.h"
#import "NSString+SBJSON.h"
#import "PNManager.h"
#import "PNLogger+Package.h"
#import "PNRequestKeyManager.h"
#import "PNUser+Package.h"
#import "PNUserModel.h"
#import "PNHTTPRequestHelper.h"
#import "PNNotificationNames.h"

#import "Helpers.h"

static PNTwitterManager *_sharedInstance;

@implementation PNTwitterManager

- (void)linkWithAccountName:(NSString*)accountName password:(NSString*)password 
				  onSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[PNUser currentUser].sessionId, @"session",
							accountName, @"user", password, @"password", nil];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandTwitterLink params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			PNCLog(PNLOG_CAT_TWITTER, @"link ok. %@", response.jsonString);
			PNUserModel* userModel = [PNUserModel dataModelWithDictionary:[response.jsonDictionary objectForKey:J_USER]];
			[[PNUser currentUser] updateFieldsFromUserModel:userModel];
			[PNUser currentUser].isLinkTwitter = YES;
			
			onSuccess();
		} else {
			PNCLog(PNLOG_CAT_TWITTER, @"error = %@", response.jsonString);
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}

- (void)unlinkWithOnSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandTwitterUnlink onSuccess:^(PNHTTPResponse *response) {
		[PNUser currentUser].isLinkTwitter = NO;
		onSuccess();
	} onFailure:onFailure];
}

- (void)postTweet:(NSString *)tweet onSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError *))onFailure
{
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[PNUser currentUser].sessionId, @"session",
							tweet, @"text", nil];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandTwitterPostTweet params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			onSuccess();
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}

	} onFailure:onFailure];
}

- (void)importGraphWithOnSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandTwitterImport onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			onSuccess();
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
- (void)verifyWithOnSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandTwitterVerify onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			PNUserModel* userModel = [PNUserModel dataModelWithDictionary:[response.jsonDictionary objectForKey:@"user"]];			
			PNUser* user = [PNUser currentUser];
			user.twitterId = [NSString stringWithFormat:@"%d", userModel.twitter.id];
			user.twitterAccount = userModel.twitter.screen_name;
			user.isLinkTwitter	= YES;
			
			[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPNNotificationUserStateUpdate object:nil]];
			onSuccess();
		} else {
			[PNUser currentUser].twitterId      = @"0";
			[PNUser currentUser].twitterAccount = nil;
			[PNUser currentUser].isLinkTwitter  = NO;
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

+ (PNTwitterManager *)sharedObject
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
@end
