#import "PNManager.h"
#import "PNRoom.h"
#import "PNRoomManager.h"
#import "PNLeaderboardManager.h"
#import "PNInvitationManager.h"
#import "PNHTTPService.h"
#import "PNHTTPRequestHelper.h"
#import "PNNetworkError.h"
#import "PNSessionManager.h"
#import "PNServiceNotifyDelegate.h"
#import "PNTCPConnectionService.h"
#import "PNUDPConnectionService.h"
#import "PNAchievementManager.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNSubscription.h"
#import "JSON.h"
#import "JsonHelper.h"
#import "PNLogger+Package.h"
#import "PNGlobal.h"
#import "PNHTTPRequestCacheManager.h"
#import "PNLocalLeaderboard.h"
#import "PNItemHistory.h"
#import "PNStoreManager.h"
#import "PNIntrospectionRequestHelper.h"
#import "PNGlobalManager.h"
#import	"PNAlertHelper.h"
#import "GameKit/GKLocalPlayer.h"
#import	"PNSettingManager.h"
#import "PNGameManager.h"

#import "PNNotificationNames.h"

static PNManager *_instance = nil;

static const int kPlistSyncInterval = 24 * 60 * 60;	// PLIST同期のインターバル(24時間)

@interface PNManager()
@property (nonatomic, retain) NSDate* previousLoginTryDate;
- (void)verifyLatestSession;
@end

// begin - lerry added code
@interface PNManager(Private)
-(void)acceptGameCenterLoginRequest;
-(void)rejectGameCenterLoginRequest;
@end
// end - lerry added code

@implementation PNManager
@synthesize notifyDelegate;
@synthesize delegate;
@synthesize roomManager;
@synthesize invitationManager;
@synthesize isLoggedIn = _isLoggedIn;
@synthesize isScreenActive = _isScreenActive;
@synthesize canResend = _canResend;
@synthesize sessionManager;
@synthesize previousLoginTryDate;

-(id)init
{
	if(self = [super init]){
		self.notifyDelegate		= nil;
		self.roomManager		= [[[PNRoomManager alloc] init] autorelease];
		self.invitationManager	= [[[PNInvitationManager alloc] init] autorelease];
		self.sessionManager = [PNSessionManager sharedObject];
		
		NATCheckCounter = 0;
		_isLoggedIn	    = NO;
		_loggedinOnce	= NO;//起動後に一度目のログインしたかどうか。
		_canResend      = YES;
		[PNUser currentUser].countryCode = kPNCountryCodeDefault;//一度もログインをしていない場合は国がないにする。
		
		self.roomManager->asyncBehaviorDelegate			= self;
		self.invitationManager->asyncBehaviorDelegate	= self;
		
		[PNTCPConnectionService setObserver:self.roomManager	key:@"PNRoomManager"];
		[PNTCPConnectionService setObserver:self				key:@"PNManager"];
	}
	return self;
}

+ (PNRoomManager*)roomManager
{
	PNManager *pInstance = [PNManager sharedObject];
	return pInstance.roomManager;
}

- (BOOL)loggedinOnce
{
	return _loggedinOnce;
}

#pragma mark -

- (void)syncLocalData
{	
	BOOL itemEnabled = [[PNGlobalManager sharedObject] itemEnabled];
	
	// 商品一覧はゲストユーザの時でも取得しにいく
	if (itemEnabled) [[PNStoreManager sharedObject] createCache];
	
	if (![PNUser currentUser].isGuest && _canResend) {
		//アチーブメントをサーバーと同期する
		[[PNAchievementManager sharedObject] syncWithServer];
		
		//リーダーボードをサーバーと同期します
		//現在オーナー不在(UserID = 0)となっているレコードを、現在のユーザに結びつけます
		[[PNLocalLeaderboard sharedObject] changeRecordOwnerFrom:0 to:[PNUser currentUserId]]; 
		[[PNLocalLeaderboard sharedObject] doDownSync];
		[[PNLocalLeaderboard sharedObject] doUpSync];
	}
	
	if (itemEnabled && ![PNUser currentUser].isGuest) {
		//アイテム所有情報を同期します
		[[PNItemHistory sharedObject] sync];
	}
	
	self.canPush = YES;
}

- (void)masterSynchronizationDone
{
	PNCLog(PNLOG_CAT_SESSION, @"masterSync done");
	[self syncLocalData];
}
- (void)masterSynchronizationFailed
{
	PNWarn(@"Master data synchronization failed.");
	
	// マスターの同期に失敗した場合は、仕方ないので現在のデータで同期を行います。
	[self syncLocalData];
}

// ログインした瞬間によばれるメソッドです。
// このメソッドはゲーム側にログイン完了通知が呼ばれる前に呼ばれます。
- (void)onLoggedIn
{
	// 前回サーバーとマスターPLISTを同期した時刻を取得します。
	// 同期記録がない場合は1970/01/01 00:00:00が返ってきます。
	NSDate* lastPlistSyncDate = [[PNGameManager sharedObject] lastPlistSyncDate];
	
	// 前回サーバーとマスターPLISTを同期してからの経過時間を取得します
	NSTimeInterval timeElapsedFromPlistSyncDate = - [lastPlistSyncDate timeIntervalSinceNow];
	
	// 今回の起動ではじめてのログイン or 前回同期してから一定時間経っていたら、マスターPLISTの同期を行います
	// マスターPLISTの同期が完了するまで、アイテムやリーダーボード、アチーブメントの同期は行いません。
	if (_loggedinOnce == NO || timeElapsedFromPlistSyncDate >= kPlistSyncInterval) {
		[PNMasterSynchronizer startWithDelegate:self];
	} else {
		// PLISTの同期は行わず、すぐにアチーブメント／リーダーボード／アイテムの同期を行います。
		[self syncLocalData];
	}
}

- (void)setIsLoggedIn:(BOOL)isLoggedIn
{
	PNCLog(PNLOG_CAT_SESSION, @"[%p]%s:_loginOnce=%d, _isLoggedIn=%d, isLoggedIn=%d", self, __FUNCTION__, _loggedinOnce, _isLoggedIn, isLoggedIn);
	
	if ( _loggedinOnce== NO && isLoggedIn == NO ) { //一度もログインしていない時
	} else if ( _isLoggedIn == YES && isLoggedIn == NO) { //ログインの状態で、ログオフまたは回線が切れてしまった時
		[self performSelector:@selector(login) withObject:nil afterDelay:0.0f];
	}
	else if (_isLoggedIn == NO && isLoggedIn == YES){ //ログインしていない状態からログインした時
		[self onLoggedIn];
	}
	
	if (isLoggedIn) {//一度でもログインしたらフラグをたてておく。
		_loggedinOnce = YES;
	}
	
	_isLoggedIn = isLoggedIn;
}

// begin - lerry added code
-(BOOL)gameCenterOptionSet {
	return [[PNSettingManager sharedObject] boolValueForKey:@"GameCenterEnabled"];
}

-(BOOL)gameCenterEnabled {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"GameCenterEnabled"];
}

-(void)setGameCenterToState:(BOOL)state {
	[[NSUserDefaults standardUserDefaults] setBool:state forKey:@"GameCenterEnabled"];
}

- (void)authenticateLocalPlayer {
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError* error) {
		if (error == nil) {
			PNCLog(PNLOG_CAT_GAME_CENTER, @"Game Center logged in.");
			[PNSettingManager storeBoolValue:YES forKey:@"GameCenterEnabled"];
		} else {
			PNCLog(PNLOG_CAT_GAME_CENTER, @"Game Center login failed: %@", [error localizedDescription]);
			[PNSettingManager storeBoolValue:NO forKey:@"GameCenterEnabled"];
		}
	}];
}

- (void)acceptGameCenterLoginRequest {
	[self authenticateLocalPlayer];
}

-(void)rejectGameCenterLoginRequest {
	[PNSettingManager storeBoolValue:NO forKey:@"GameCenterEnabled"];
	[PNAlertHelper showAlertForGameCenterLoginRequestRejected:self];
}
// end - lerry added code

- (void)setCanResend:(BOOL)boo
{
	_canResend = boo;
}

- (void)setIsScreenActive:(BOOL)boo
{
	_isScreenActive = boo;
}

- (BOOL)canPush {
	return canPush;
}

- (void)setCanPush:(BOOL)aBool {
	canPush = aBool;
	if (canPush) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kPNManagerFinishLoginNotification object:self];
	}

}

#pragma mark -

-(void)connectToPingPongServer
{
	NSString *session = [PNUser session];
	if(session) {
		if([PNTCPConnectionService startWithSession:session]) {
			self.isLoggedIn = YES;
		} else {
			self.isLoggedIn = NO;
			PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
			e.message = @"Can't connect to server.";
			e.errorType = kPNTCPErrorFailed;
			if([delegate respondsToSelector:@selector(manager:didFailConnectionWithError:)])
				[delegate manager:self didFailConnectionWithError:e];
			
			if([delegate respondsToSelector:@selector(manager:didFailWithError:)])
				[delegate manager:self didFailWithError:e];
		}
	}
}


-(void)disconnect
{
	PNTCPConnectionService *tcpService = [PNTCPConnectionService sharedObject];
	[tcpService stop];
	self.isLoggedIn = NO;
}

#pragma mark -
- (BOOL)login
{	
	// If already logged in, exit.
	if (self.isLoggedIn) return YES;
	
	// If gamekey is nil, exit.
	if ([PNGlobalManager sharedObject].gameKey == nil){
		PNWarn(@"Error: gameKey is null.");
		return NO;
	}
	
	// To reduce server load, postpone login request if interval was too short.
	if (previousLoginTryDate != nil && -[previousLoginTryDate timeIntervalSinceNow] < kPNLoginDelay){
		[self performSelector:@selector(login) withObject:nil afterDelay:kPNLoginDelay];
		return NO;
	}
	
	// ----------------------------------------
	// Start try login
	// ----------------------------------------
	self.sessionManager.managerDelegate = delegate;
	NSString* latestSessionId = sessionManager.latestSessionId;
	if (latestSessionId == nil || [latestSessionId length] == 0){	// If previous session id not exists, try create session.
		[sessionManager createSessionWithDelegate:self onSucceededSelector:@selector(createSessionSucceeded:) 
								 onFailedSelector:@selector(createSessionFailedWithError:)];
	} else {	// If previous session id exists, try verifying previous session id.
		[self verifyLatestSession];
	}
	
	// Try again automatically.
	self.previousLoginTryDate = [NSDate date];
	[self performSelector:@selector(login) withObject:nil afterDelay:kPNLoginDelay];
	
	return YES;
}

// Check if latest session is valid or not. If valid, use it again. If not, delete latest session and create new one.
- (void)verifyLatestSession
{
	[sessionManager verifyLastSessionWithCompleteHandler:^(BOOL isValid, PNError* error) {
		if (isValid) {
			self.isLoggedIn = YES;
			[self onCreatingOrVerifyingSessionSucceeded];
		} else {
			if (error != nil && ![error isConnectionError]) {	// No error but session was invalid (session was destroyed.)
				[PNSessionManager sharedObject].latestSessionId = nil;
			} else {	// If network error, ignore it and try again.
				PNCLog(PNLOG_CAT_SESSION, @"error: %@", error);
			}
		}
	}];
}

- (void)createSessionSucceeded:(PNUser*)user
{
	PNCLog(PNLOG_CAT_SESSION, @"session/create succeeded.");
	PNCLog(PNLOG_CAT_ITEM, @"coin: %lld", user.coins);
	
	[PNSessionManager sharedObject].latestSessionId = user.sessionId;
	//ログイン完了を通知します
	if (delegate != nil && [delegate respondsToSelector:@selector(manager:didLogin:)]){
		[delegate manager:self didLogin:user];
	}
	[self onCreatingOrVerifyingSessionSucceeded];
}
- (void)createSessionFailedWithError:(PNError*)error
{
	PNCLog(PNLOG_CAT_SESSION, @"session/create failed.");
	// device/registerとの整合性がなかった場合はキャッシュを削除します
	if (error.errorType == kPNSessionErrorInvalidUDID){
		[[PNHTTPRequestCacheManager sharedObject] clearAll];
	}
	
	// ログインに失敗したことを通知します
	if (delegate != nil && [delegate respondsToSelector:@selector(manager:didFailWithError:)]){
		[delegate manager:self didFailWithError:error];
	}
}
/**! セッション作成時および復元時に呼ばれるメソッドです。
 * すなわち、サーバーと接続できたときに呼ばれるメソッドです。
 * この中で、NATチェックやサーバーとのPING/PONGを開始します。
 */
- (void)onCreatingOrVerifyingSessionSucceeded
{
	NATCheckCounter = 0;
	[PNUDPConnectionService checkNATWithDelegate:(id<PNUDPConnectionServiceDelegate>)self session:[PNUser currentUser].sessionId];
	[self connectToPingPongServer];
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
	
	// ゲームセンターにログインの判断ロジック
	/*
	 // begin - lerry test code
	 if ([self gameCenterOptionSet]) {
	 if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GameCenterEnabled"]==nil) {
	 // if GameCenter option is not initialized in settings, pop the dialog
	 [PNAlertHelper showAlertForGameCenterLoginRequest:self onLogin:@selector(acceptGameCenterLoginRequest) onCancel:@selector(rejectGameCenterLoginRequest)];
	 } else {
	 if ([self gameCenterEnabled]) {
	 PNCLog(PNLOG_CAT_SESSION, @"Game Center enabled.");
	 if (![GKLocalPlayer localPlayer].authenticated) {
	 PNCLog(PNLOG_CAT_SESSION, @"Authenticating local user ...");
	 [self authenticateLocalPlayer];
	 }
	 } else {
	 PNCLog(PNLOG_CAT_SESSION, @"Game Center disabled.");
	 }
	 }
	 }
	 */
	// end - lerry test code
}

#pragma mark delegate for session
// BEGIN - lerry added code
- (void)apiSession:(PNSessionManager*)apiSession didCreateSession:(NSString*)session
{
	PNLog(@"Created session.");
	//comment out for debugtp
	NATCheckCounter = 0;
	[PNUDPConnectionService checkNATWithDelegate:(id<PNUDPConnectionServiceDelegate>)self session:session];
	[self connectToPingPongServer];
	PNLog(@"Created session.");
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
}
// END - lerry added code

- (void)apiSession:(PNSessionManager*)apiSession didFailWithError:(PNNetworkError*)error
{
	PNLog(@"Login error.");
	PNLog(@"ERRORCODE:%d %@ ",error.errorType,error.message);
}

- (void)service:(PNTCPConnectionService*)service didFailWithError:(PNNetworkError*)error
{
	
}

-(void)didStartWithService:(PNUDPConnectionService*)service
{
	PNLog(@"Started stun service.");
}


-(void)stunService:(PNUDPConnectionService*)aService didDetecteNat:(NSNumber*)aNATType
{
	PNNATType natType = [aNATType intValue];
	NATCheckCounter++;
	if(natType == kPNSymmetricNAT || natType == kPNUnknownNAT) {
		NSString* session = [PNUser session];
		if(NATCheckCounter <= 1) {
			[PNUDPConnectionService checkNATWithDelegate:(id<PNUDPConnectionServiceDelegate>)self session:session];
		}
	}
	
	[PNUser currentUser].natType = natType;	
	if([delegate respondsToSelector:@selector(didEndNetworkCheckingWithManager:)])
		[delegate didEndNetworkCheckingWithManager:self];
}

-(void)stunService:(PNUDPConnectionService*)service didError:(PNNetworkError*)error
{
	PNLog(@"Stun service error : %@", error.message);
	
	switch (error.errorType) {
		case kPNStunPunchingRTTOverrange:
			// TODO
			break;
		default:
			break;
	}
}

-(void)stunService:(PNUDPConnectionService*)service didReport:(NSString*)report
{
	PNLog(@"Pairing report : %@", report);
}

-(void)stunService:(PNUDPConnectionService*)service willStartPairing:(PNPeer*)peer
{
	PNLog(@"Pairing opponent : %@ %d %@",peer.address,peer.udpPort,peer.user.username);
}

-(void)stunService:(PNUDPConnectionService*)service didDonePairing:(PNPeer*)peer
{
	PNLog(@"Pairing done : %@ %d %@",peer.address,peer.udpPort,peer.user.username);
}



-(void)didConnectWithService:(PNTCPConnectionService*)service
{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPNNotificationConnectionEstablished object:nil]];
}

-(void)subscriptionAddUserResponse:(PNHTTPResponse*)response
{
	NSDictionary *json = [response jsonDictionary];	
	
	PNLog(@"SUB : %@",json);
	if(response.isValidAndSuccessful) {
		
	}
}


-(void)didDisconnectWithService:(PNTCPConnectionService*)service
{
	PNLogMethod(@"Disconnected TCP service.");
	self.isLoggedIn = NO;
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPNNotificationConnectionDisconnected object:nil]];
}

- (void)didRecievePushNotification:(NSString *)notif {
	if ([delegate respondsToSelector:@selector(manager:didRecievePushNotification:fromUser:)]) {
		[delegate manager:self didRecievePushNotification:notif fromUser:nil];
	}
}
- (void)showDebugNotice:(NSString*)title description:(NSString*)description{
	if (delegate && [delegate respondsToSelector:@selector(manager:didReceiveDebugInfo:description:)]){
		[delegate manager:self didReceiveDebugInfo:title description:description];
	}
}

- (void)sendReport:(NSString*)text
{
	NSString* report = [NSString stringWithFormat:@"User<%@:%@> %@", [PNUser currentUser].username, [PNUser currentUser].sessionId, text];
	[PNIntrospectionRequestHelper sendReport:report level:@"info" delegate:self selector:@selector(sendReportResponse:) requestKey:@"PNIntrospectionReport"];
}
- (void)sendReportResponse:(PNHTTPResponse*)response
{
}

#pragma mark -
#pragma mark Singleton Pattern


+ (PNManager*) sharedObject {
    @synchronized(self) {
        if (!_instance) {
            [[self alloc] init];
		}
    }
    return _instance;
}


+ (id)allocWithZone:(NSZone*)zone{
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

-(void)didPushNotificationBehavior:(id)aSender name:(NSString*)aBehaviorName params:(NSDictionary*)aParams
{
	if([aBehaviorName isEqualToString:@"MATCH/FINISH"]) {
		[notifyDelegate didFinishMatch:[[aParams objectForKey:@"changePoint"] intValue]
						 newGradePoint:[[aParams objectForKey:@"newGradePoint"] intValue]];
	} else if ([aBehaviorName isEqualToString:@""]) {
	}
}

// Application Delegate
- (void)applicationWillTerminate:(UIApplication *)application
{
	if(self.sessionManager) [self.sessionManager terminate];
	if(self.roomManager) [self.roomManager terminate];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
	// begin - lerry modified code
	[self disconnect];
	[PNUDPConnectionService suspend];
	self.isLoggedIn = NO;
	// end - lerry modified code
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
	// begin - lerry modified code
	[self connectToPingPongServer];
	[PNUDPConnectionService resume];
	// end - lerry modified code
	//[self login];
}

- (void)registerDelegateToBackchannel:(id)anObject forKey:(id)akey
{
	[[PNTCPConnectionService sharedObject].delegates setObject:anObject forKey:akey];
}

- (BOOL)isCheckedNetwork
{
	return [PNUDPConnectionService sharedObject].isChecked;
}

- (void)dealloc
{
	self.notifyDelegate			= nil;
	self.delegate				= nil;
	self.roomManager			= nil;
	self.invitationManager		= nil;
	self.previousLoginTryDate	= nil;
	[super dealloc];
}

- (void)error:(PNError*)err userInfo:(PNUser*)userInfo {
	if (delegate != nil && [delegate respondsToSelector:@selector(manager:didFailConnectionWithError:)]) {
		[delegate manager:self didFailConnectionWithError:err];
	}
}

@end
