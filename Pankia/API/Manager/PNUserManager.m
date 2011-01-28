#import "PNFriend.h"
#import "PNUserManager.h"
#import "PNError.h"
#import "NSObject+PostEvent.h"
#import "PNAchievementRequestHelper.h"	//TODO: DO REFACTORING
#import "PNSessionRequestHelper.h"
#import "JsonHelper.h"
#import "PNManager.h"
#import "PNRequestKeyManager.h"
#import "PNSessionModel.h"
#import "PNSessionManager.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNAchievementRequestQueue.h"
#import "PNLeaderboardManager.h"
#import "PNLogger+Package.h"
#import "PNAPIHTTPDefinition.h"
#import "PNUserModel.h"
#import "PNTwitterManager.h"

static PNUserManager* _sharedInstance;

@interface PNUserManager(Private)

- (void)secureUser:(PNUser*)user
			  name:(NSString*)name
			 email:(NSString*)email
		  password:(NSString*)password
		requestKey:(NSString*)requestKey;

- (void)updateUser:(PNUser*)user
			  name:(NSString*)name
			 email:(NSString*)email
		  password:(NSString*)password
		requestKey:(NSString*)requestKey;

@end

@implementation PNUserManager

#pragma mark -

- (void)changeName:(NSString*)name onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[PNUser currentUser].sessionId, @"session",
							name, @"username", nil];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserUpdate params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			PNUserModel* userModel = [PNUserModel dataModelWithDictionary:[response.jsonDictionary objectForKey:@"user"]];
			PNUser* user = [PNUser currentUser];
			user.username = userModel.username;
			user.isGuest	= NO;
			[user saveToCacheAsCurrentUser];
			
			onSuccess();
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
#pragma mark -
- (void)findByName:(NSString*)name include:(NSString*)include offset:(int)offset limit:(int)limit
		  delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
								 onFailedSelector:onFailedSelector];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:name forKey:@"user"];
	
//	if ([include isEqualToString:@"enrollments"]) {
	if (include != nil)
		[params setObject:include forKey:@"include"];	
//	}
	
	if (offset >= 0 && limit > 0) {
		[params setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
		[params setObject:[NSString stringWithFormat:@"%d", limit]  forKey:@"limit"];		
	}
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserFind
								requestType:@"GET"
								  isMutable:NO
						  parameters:params
							delegate:self
							selector:@selector(findByNameResponse:)
						 callBackKey:requestKey];	
}
- (void)findByNameResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];
	
	if(response.isValidAndSuccessful) {
		NSArray* users = [json objectForKey:@"users"];
		NSMutableArray *foundUsers = [NSMutableArray array];
		for (int i = 0; i < [users count]; i++) {
			PNUserModel* user = [[[PNUserModel alloc] initWithDictionary:[users objectAtIndex:i]] autorelease];
			PNFriend*   fData = [[[PNFriend alloc] initWithUserModel:user] autorelease];
			[foundUsers addObject:fData];  
		}
		
		if([delegate respondsToSelector:onSucceededSelector]){
			[delegate performSelector:onSucceededSelector withObject:foundUsers];
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		if([delegate respondsToSelector:onFailedSelector]){
			[delegate performSelector:onFailedSelector withObject:error];
		}				
	}
	
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
- (void)followUserById:(NSString*)user
			  delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
								 onFailedSelector:onFailedSelector];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserFollow
								requestType:@"GET"
								  isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  [PNUser currentUser].sessionId,		@"session",
									  user,									@"user",
									  nil]
							delegate:self
								   selector:@selector(defaultResponse:)
						 callBackKey:requestKey];
}
#pragma mark -
- (void)getFolloweesOfUser:(NSString*)user offset:(int)offset limit:(int)limit
				  delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
								 onFailedSelector:onFailedSelector];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:user forKey:@"user"];
	[params setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	[params setObject:[NSString stringWithFormat:@"%d", limit]  forKey:@"limit"];
	[params setObject:@"twitter" forKey:@"include"];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserFollowees
								requestType:@"GET"
								  isMutable:NO
								 parameters:params
								   delegate:self
								   selector:@selector(getFolloweesResponse:)
								callBackKey:requestKey];
}
- (void)getFolloweesInCurrentGameOfUser:(NSString*)user
                                 offset:(int)offset
                                  limit:(int)limit
                               delegate:(id)delegate
                            onSucceeded:(SEL)onSucceededSelector
                               onFailed:(SEL)onFailedSelector
{
    NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
                                                onFailedSelector:onFailedSelector];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:user forKey:@"user"];
	[params setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	[params setObject:[NSString stringWithFormat:@"%d", limit]  forKey:@"limit"];
    [params setObject:@"true" forKey:@"exclude_unenrolled"];
	[params setObject:@"twitter" forKey:@"include"];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserFollowees
								requestType:@"GET"
								  isMutable:NO
								 parameters:params
								   delegate:self
								   selector:@selector(getFolloweesResponse:)
								callBackKey:requestKey];
}
- (void)getFolloweesResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];

	if(response.isValidAndSuccessful) {
		NSArray* followeeDictionaryArray = [json objectForKey:@"followees"];
		NSMutableArray* followees = [NSMutableArray array];
		for (NSDictionary* f in followeeDictionaryArray) {
			PNUserModel* userModel	= [[[PNUserModel alloc] initWithDictionary:f] autorelease];
			PNFriend* fData			= [[[PNFriend alloc] initWithUserModel:userModel] autorelease];
			[followees addObject:fData];
		}
		if([delegate respondsToSelector:onSucceededSelector]){
			[delegate performSelector:onSucceededSelector withObject:followees];
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		if([delegate respondsToSelector:onFailedSelector]){
			[delegate performSelector:onFailedSelector withObject:error];
		}				
	}
	
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}

#pragma mark -
- (void)getFollowersOfUser:(NSString*)user offset:(int)offset limit:(int)limit
				  delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
								 onFailedSelector:onFailedSelector];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:user forKey:@"user"];
	[params setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	[params setObject:[NSString stringWithFormat:@"%d", limit]  forKey:@"limit"];
	[params setObject:@"twitter" forKey:@"include"];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserFollowers
								requestType:@"GET"
								  isMutable:NO
								 parameters:params
								   delegate:self
								   selector:@selector(getFollowersResponse:)
								callBackKey:requestKey];
}
- (void)getFollowersResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];
	
	if(response.isValidAndSuccessful) {
		NSArray* followerDictionaryArray = [json objectForKey:@"followers"];
		NSMutableArray* followers = [NSMutableArray array];
		for (NSDictionary* f in followerDictionaryArray) {
			PNUserModel* userModel	= [[[PNUserModel alloc] initWithDictionary:f] autorelease];
			PNFriend* fData			= [[[PNFriend alloc] initWithUserModel:userModel] autorelease];
			[followers addObject:fData];
		}
		if([delegate respondsToSelector:onSucceededSelector]){
			[delegate performSelector:onSucceededSelector withObject:followers];
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		if([delegate respondsToSelector:onFailedSelector]){
			[delegate performSelector:onFailedSelector withObject:error];
		}				
	}
	
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
- (void)getDetailsOfUser:(NSString*)user include:(NSString*)include delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
								 onFailedSelector:onFailedSelector];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserShow
								requestType:@"GET"
								  isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  [PNUser currentUser].sessionId,		@"session",
									  include,				                @"include",
									  user,									@"user",
									  nil]
								   delegate:self
								   selector:@selector(getDetailsOfUserResponse:)
								callBackKey:requestKey];
}
- (void)getDetailsOfUserResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];
	
	PNCLog(NO, @"json = %@",json);
	if(response.isValidAndSuccessful) {
		PNUserModel* user = [PNUserModel dataModelWithDictionary:[json objectForKey:@"user"]];
		
		if([delegate respondsToSelector:onSucceededSelector]){
			[delegate performSelector:onSucceededSelector withObject:user];
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		if([delegate respondsToSelector:onFailedSelector]){
			[delegate performSelector:onFailedSelector withObject:error];
		}
	}
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
- (void)secureUser:(PNUser *)user name:(NSString *)name email:(NSString *)email password:(NSString *)password requestKey:(NSString*)requestKey{
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserSecure
								requestType:@"GET"
								  isMutable:NO
						 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									 user.sessionId,	@"session",
									 email,				@"email",
									 name,				@"username",
									 password,			@"password",
									 nil]
						   delegate:self
						   selector:@selector(secureUserResponse:)
						callBackKey:requestKey];
}
- (void)updateUser:(PNUser *)user name:(NSString *)name email:(NSString *)email password:(NSString *)password requestKey:(NSString*)requestKey{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:user.sessionId forKey:@"session"];
	if(name){
		[dic setObject:name forKey:@"username"];
	}
	if(email){
		[dic setObject:email forKey:@"email"];
	}
	if(password){
		[dic setObject:password forKey:@"password"];
	}	
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserUpdate
								requestType:@"GET"
								  isMutable:NO
								 parameters:dic
								   delegate:self
								   selector:@selector(updateUserResponse:)
								callBackKey:requestKey];
}
- (void)secureOrUpdateUser:(PNUser *)user name:(NSString *)name email:(NSString *)email password:(NSString *)password 
				  delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
								 onFailedSelector:onFailedSelector];
	if (user.isSecured){
		[self updateUser:user name:name email:email password:password requestKey:requestKey];
	}else{
		[self secureUser:user name:name email:email password:password requestKey:requestKey];
	}
}
- (void)secureUserResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp = [response jsonString];
	
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];
	
	if(response.isValidAndSuccessful) {
		if([delegate respondsToSelector:onSucceededSelector]){
			[delegate performSelector:onSucceededSelector withObjects:[NSArray arrayWithObjects:[PNUser currentUser], [NSNumber numberWithBool:YES], nil]];
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		if([delegate respondsToSelector:onFailedSelector]){
			[delegate performSelector:onFailedSelector withObject:error];
		}				
	}
	
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
- (void)updateUserResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp = [response jsonString];
	
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];

	if(response.isValidAndSuccessful) {
		if([delegate respondsToSelector:onSucceededSelector]){
			[delegate performSelector:onSucceededSelector withObjects:[NSArray arrayWithObjects:[PNUser currentUser], [NSNumber numberWithBool:NO], nil]];
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		if([delegate respondsToSelector:onFailedSelector]){
			[delegate performSelector:onFailedSelector withObject:error];
		}				
	}
	
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}

#pragma mark -
- (void)resetupUserAccount:(PNHTTPResponse*)response onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	PNSessionModel *sessionModel = [PNSessionModel dataModelWithDictionary:response.jsonDictionary];
	
	if (sessionModel.id) {
		[PNUser currentUser].iconURL = nil;
		PNUser* loginUser = [PNUser currentUser];
		[loginUser updateFieldsFromUserModel:sessionModel.user];
		[loginUser setSessionId:sessionModel.id];
		
		//最新のセッションIDを登録します
		[[PNSessionManager sharedObject] setLatestSessionId:sessionModel.id];
		
		//スイッチ後のユーザをキャッシュに保存します
		//そうすることで、次回起動時にオフラインだった場合でもユーザIDなどを利用できます
		[loginUser saveToCacheAsCurrentUser];
		
		
		//PNManager経由でスイッチユーザしたことを通知します(後で改善の必要あり)
		PNManager* pnManager = [PNManager sharedObject];
		id<PNManagerDelegate> managerDelegate = pnManager.delegate;		
		
		if([managerDelegate respondsToSelector:@selector(manager:didSwitchAccount:)]){
			[managerDelegate manager:[PNManager sharedObject] didSwitchAccount:loginUser];
		}
		
		if([managerDelegate respondsToSelector:@selector(manager:didLogin:)]){
			[managerDelegate manager:[PNManager sharedObject] didLogin:loginUser];
		}
		[pnManager onCreatingOrVerifyingSessionSucceeded];
		
		//twitterとのリンク状況を取得します。
		[[PNTwitterManager sharedObject] verifyWithOnSuccess:^() {
		} onFailure:^(PNError *error) {
			PNWarn(@"Twitter link verify error. %@", error);
		}];
		
		[[PNSessionManager sharedObject] transferDeviceWithOnSuccess:^() {
			onSuccess();
		} onFailure:onFailure];
	} else {			
		PNNetworkError *error = [[[PNNetworkError alloc] init] autorelease];
		error.message   = @"Unknown error.";
		error.errorType = 0;
		
		[PNRequestKeyManager callOnFailedSelectorAndRemove:response.requestKey withObject:error];
	}
}
- (void)switchAccountByUsername:(NSString*)account password:(NSString*)password onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	NSDictionary* params = [PNSessionRequestHelper paramsForAuthByLoginID:account password:password];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandSessionCreateByPassword params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			[self resetupUserAccount:response onSuccess:onSuccess onFailure:onFailure];
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
- (void)switchAccountByTwitterID:(NSString*)account password:(NSString*)password 
					   onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	NSDictionary* params = [PNSessionRequestHelper paramsForAuthByLoginID:account password:password];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandSessionCreateByTwitter params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			[self resetupUserAccount:response onSuccess:onSuccess onFailure:onFailure];
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}
#pragma mark -
// BEGIN - lerry added code
- (void)switchAccountByFacebookSessionKey:(NSString*)sessionKey secret:(NSString*)secret
								 delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector];
	[PNSessionRequestHelper switchAccountByFacebookSessionKey:sessionKey secret:secret 
													 delegate:self selector:@selector(switchAccountByFacebookResponse:) key:requestKey];	
}
- (void)switchAccountByFacebookResponse:(NSNotification*)n
{
	NSString* requestKey = [n name];
	id delegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];
	
	NSString*		resp = n.object;
	NSDictionary*	json = [resp JSONValue];
	
	if ([JsonHelper isApiSuccess:json]) 
	{
		PNCLog(PNLOG_CAT_SESSION, @"Switch account ok. %@", json);
		
		PNSessionModel *sessionModel = [PNSessionModel dataModelWithDictionary:json];
		
		if (sessionModel.id) {
			[PNUser currentUser].iconURL = nil;
			PNUser* loginUser = [PNUser currentUser];
			[loginUser updateFieldsFromUserModel:sessionModel.user];
			[loginUser setSessionId:sessionModel.id];
			
			//最新のセッションIDを登録します
			[[PNSessionManager sharedObject] setLatestSessionId:sessionModel.id];
			
			//スイッチ後のユーザをキャッシュに保存します
			//そうすることで、次回起動時にオフラインだった場合でもユーザIDなどを利用できます
			[loginUser saveToCacheAsCurrentUser];
			
			
			//switchのリクエストは成功しましたが、device/transferが成功しないと
			//次回起動時に前のユーザでログインしてしまうのでdevice/transferの成功を待ってから成功を通知します
			[[PNSessionManager sharedObject] transferDeviceWithDelegate:delegate
															onSucceeded:onSucceededSelector 
															   onFailed:onFailedSelector];
			
			//PNManager経由でスイッチユーザしたことを通知します(後で改善の必要あり)
			PNManager* pnManager = [PNManager sharedObject];
			id<PNManagerDelegate> managerDelegate = pnManager.delegate;		
			
			if([managerDelegate respondsToSelector:@selector(manager:didSwitchAccount:)]){
				[managerDelegate manager:[PNManager sharedObject] didSwitchAccount:loginUser];
			}
			
			if([managerDelegate respondsToSelector:@selector(manager:didLogin:)]){
				[managerDelegate manager:[PNManager sharedObject] didLogin:loginUser];
			}
		} else {			
			PNLog(@"Error");
			PNNetworkError *error = [[[PNNetworkError alloc] init] autorelease];
			error.message   = @"Unknown error.";
			error.errorType = 0;
			if([delegate respondsToSelector:onFailedSelector]){
				[delegate performSelector:onFailedSelector withObject:error];
			}
		}
	} else {
		PNCLog(PNLOG_CAT_SESSION, @"error = %@", json);
		PNNetworkError *error = [[[PNNetworkError alloc] init] autorelease];
		error.message   = @"Switch Account Response is NG.";
		error.errorType = kPNHTTPErrorInvalid;
		error.errorCode = [json objectForKey:@"code"];
		if([delegate respondsToSelector:onFailedSelector]){
			[delegate performSelector:onFailedSelector withObject:error];
		}
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
// END - lerry added code

#pragma mark -
- (void)unfollowUserById:(NSString*)user
				delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
								 onFailedSelector:onFailedSelector];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserUnfollow
								requestType:@"GET"
								  isMutable:NO
								 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
											 [PNUser currentUser].sessionId,		@"session",
											 user,									@"user",
											 nil]
								   delegate:self
								   selector:@selector(defaultResponse:)
								callBackKey:requestKey];
}
#pragma mark -
- (void)blockUser:(NSString*)userName delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector 
		 onFailed:(SEL)onFailedSelector withObject:(id)object
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector withObject:object];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserBlock
								requestType:@"GET"
								  isMutable:NO
								 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
											 [PNUser currentUser].sessionId,		@"session",
											 userName,									@"user",
											 nil]
								   delegate:self
								   selector:@selector(defaultResponse:)
								callBackKey:requestKey];
}
- (void)unblockUser:(NSString*)userName delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector 
		   onFailed:(SEL)onFailedSelector withObject:(id)object
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector withObject:object];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserUnblock
								requestType:@"GET"
								  isMutable:NO
								 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
											 [PNUser currentUser].sessionId,		@"session",
											 userName,									@"user",
											 nil]
								   delegate:self
								   selector:@selector(defaultResponse:)
								callBackKey:requestKey];
}
#pragma mark -
- (void)pushToUser:(NSString*)userName withText:(NSString *)aString delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector withObject:(id)object {
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector withObject:object];
	
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandUserPush
								requestType:@"GET"
								  isMutable:NO
								 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
											 [PNUser currentUser].sessionId,		@"session",
											 userName,									@"user",
											 nil]
								   delegate:self
								   selector:@selector(defaultResponse:)
								callBackKey:requestKey];
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	

	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

+ (PNUserManager *)sharedObject
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
