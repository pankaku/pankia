#import "PNSessionManager.h"
#import "PNNetworkError.h"
#import "PNGlobalManager.h"
#import "PNHTTPService.h"
#import "PNHTTPRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "Helpers.h"
#import "PNAlertHelper.h"
#import "PNUserModel.h"
#import "PNSessionModel.h"
#import "PNUserModel.h"
#import "PNSessionRequestHelper.h"
#import "PNUserManager.h"
#import "NSObject+PostEvent.h"
#import "PNRequestKeyManager.h"
#import "PNLogger+Package.h"
#import "PNGlobal.h"
#import "PNSettingManager.h"
#import "PNHTTPRequestCacheManager.h"
#import "PNAPIHTTPDefinition.h"
#import "PNSplashManager.h"
#import "PNManager.h"
#import "PNGameManager.h"
#import "PNHTTPDownload.h"
#import "PNHTTPResponse.h"
#import "PNNotificationNames.h"
#import "PNTwitterManager.h"

NSString* const kPNSessionManagerChangeLastestSessionNotification = @"PNSessionManagerChangeLastestSessionNotification";

@interface PNSessionManager()
- (void)createSessionResponse:(PNHTTPResponse*)response;
@end

@implementation PNSessionManager

@synthesize managerDelegate;
@synthesize latestSessionId;

static PNSessionManager* _instance = nil;

- (id) init {
	if (self = [super init]) {
		self.managerDelegate	= nil;
	}
	return self;
}

- (void)dealloc
{
	self.managerDelegate	= nil;
	[super dealloc];
}

- (void)setLatestSessionId:(NSString *)sessionId
{
	if ([latestSessionId isEqualToString:sessionId]) return;
	
	if (latestSessionId != nil){
		[latestSessionId release];
		latestSessionId = nil;
	}
	latestSessionId = [sessionId retain];
	
	PNCLog(PNLOG_CAT_SESSION, @"Latest SessionID: %@", latestSessionId);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kPNSessionManagerChangeLastestSessionNotification object:self];
}
#pragma mark -
- (void)createSessionWithDelegate:(id)delegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector
{
	NSDictionary *params = [PNSessionRequestHelper paramsForAuthByDevice];
	NSString* urlString = [PNHTTPRequestHelper urlStringFromPath:kPNHTTPRequestCommandSessionCreate params:params];
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	
	[PNHTTPDownload asyncDownloadFromURL:urlString 
								 success:^(PNHTTPResponse* response) {
									 response.requestKey = requestKey;
									 [self createSessionResponse:response];
								 }
	 							 failure:^(PNError* error) {
									 PNWarn(@"Session error. %@", error);
								 }];
	return;
}

- (void)verifyTwitterLink
{
	if ([PNUser currentUser].twitterId != nil && [[PNUser currentUser].twitterId intValue] > 0) {
		[[PNTwitterManager sharedObject] verifyWithOnSuccess:^() {
		} onFailure:^(PNError *error) {
			PNWarn(@"Twitter link verify error. %@", error);
		}];
	}
}

// this method is obsolete
- (void)createSessionResponse:(PNHTTPResponse*)response
{
	if (response.isValidAndSuccessful) {
		PNCLog(PNLOG_CAT_SESSION, @"createdSession : %@", response.jsonString);
		PNSessionModel *sessionData = [PNSessionModel dataModelWithDictionary:response.jsonDictionary];
		
		NSString* session = sessionData.id;
		if (session) {	//セッションを作ることができた場合
			
			//レスポンスの内容を元に、currentUserの情報を書き換えます
			PNUser *u = [PNUser currentUser];
			[u updateFieldsFromSessionModel:sessionData];
			[u saveToCacheAsCurrentUser];		//このユーザの情報をカレントユーザの情報としてキャッシュに保存します

			[self verifyTwitterLink];
			

			//EnabledなFeatureを取り出します
			if (sessionData.game != nil && sessionData.game.features != nil) {
				[[PNGameManager sharedObject] setFeatures:sessionData.game.features];
			}
			
			// Register splashes
			[[PNSplashManager sharedObject] processSplashModels:sessionData.splashes];			

			
			//デリゲート先にログインに成功したこと／セッション生成に成功したことを通知します
			[PNRequestKeyManager callOnSucceededSelectorAndRemove:response.requestKey withObject:u];
			
			//最新版の情報を取得したことを通知します
			if(sessionData.game != nil && sessionData.game.currentVersion != nil){
				if([managerDelegate respondsToSelector:@selector(manager:didGetLatestVersion:iTunesURL:)]){
					PNVersionModel* latestVersion = sessionData.game.currentVersion;
					[managerDelegate manager:[PNManager sharedObject] didGetLatestVersion:latestVersion.value
								   iTunesURL:sessionData.game.iTunesURL];
				}
			}
			
			//! ボーナスコインの発生を確認し、追加されていた場合ユーザに通知する - kawahara add - [Beign]
			if(0 < sessionData.user.install.bonus_coins_count) {
				[PNAlertHelper showAlertForCoinBonus:self aquiredCoins:sessionData.user.install.bonus_coins_count currentCoins:u.coins];
			}
			//! ボーナスコインの発生を確認し、追加されていた場合ユーザに通知する - kawahara add - [End]
		} else {	//サーバーと通信はできたがセッションが作れなかった場合(通常は起こりえない)
			//しばらく時間をおいた後、再度セッションの生成リクエストを出します	
			
			PNCLog(PNLOG_CAT_SESSION, @"createSessionError. Got response but no session id.");
			PNNetworkError *error = [[[PNNetworkError alloc] init] autorelease];
			error.message	= @"Unknown error.";
			error.errorType	= 0;
			[PNRequestKeyManager callOnFailedSelectorAndRemove:response.requestKey withObject:error];
		}
	} else {
		PNCLog(PNLOG_CAT_SESSION, @"createSessionError. Detail : %@", response.jsonString);
		PNNetworkError *error = [[[PNNetworkError alloc] init] autorelease];
		error.message   = @"Response is NG.";
		
		//udidとの結びつけが原因の場合
		if ([[response.jsonDictionary objectForKey:@"subcode"] isEqualToString:@"udid"] || [[response.jsonDictionary objectForKey:@"detail"] isEqualToString:@"device not registered"]){
			error.errorType = kPNSessionErrorInvalidUDID;
		} else {
			error.errorType = kPNHTTPErrorInvalid;
		}
		
		[PNRequestKeyManager callOnFailedSelectorAndRemove:response.requestKey withObject:error];
	}
}
#pragma mark -
- (void)verifyLastSessionWithCompleteHandler:(void (^)(BOOL isValid, PNError* error))completionHandler
{
	NSDictionary* params = [NSDictionary dictionaryWithObject:latestSessionId forKey:@"session"];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandSessionVerify params:params 
								  onSuccess:^(PNHTTPResponse* response) {
									  completionHandler(YES, nil);
								  }
								  onFailure:^(PNError* error) {
									  completionHandler(NO, (PNError*)error);
								  }];	
}
#pragma mark -
// 通信エラーが発生したときに呼ばれます
- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNCLog(PNLOG_CAT_SESSION, @"%s %@ %d", __FUNCTION__, error.message,error.errorType);
	
	NSString* requestKey = [userInfo objectForKey:@"key"];
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];
	
	if ([delegate respondsToSelector:onFailedSelector]){
		[delegate performSelector:onFailedSelector withObject:error];
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}

- (void)destroySession
{
	if([PNUser session]) {
		[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandSessionDelete
									requestType:@"GET"
									  isMutable:NO
									 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
												 [PNUser session],		@"session",
												 nil]
									   delegate:self
									   selector:@selector(responseDestroySession:)
									callBackKey:@"DeleteSession"];
	}
}

- (void)transferDeviceWithOnSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	// Create parameters
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
	NSString* gameSecret = [PNGlobalManager sharedObject].gameSecret;	
	NSMutableString *verifier = [NSMutableString stringWithString:gameSecret];
	[verifier appendString:[UIDevice currentDevice].uniqueIdentifier];
	[params setObject:[NSData sha1FromString:verifier] forKey:@"verifier"];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandDeviceTransfer params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			onSuccess();
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
// アプリケーション終了時に呼ばれる。
- (void)terminate
{
	[self destroySession];
}

- (void)responseDestroySession:(NSNotification*)n
{
	PNLog(@"%@",n.object);
	// Ignore
}

#pragma mark -
#pragma mark Singleton pattern
+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (!_instance) {
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone{return self;}

- (id)retain{return self;}

- (unsigned)retainCount{return UINT_MAX;}

- (void)release {}

- (id)autorelease {return self;}


+ (PNSessionManager*)sharedObject
{
	@synchronized(self)
	{
		if(!_instance) {
			[[PNSessionManager alloc] init];
		}
	}
	
	return _instance;
}
@end
