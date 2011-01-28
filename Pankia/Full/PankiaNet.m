#import "PankiaNet.h"
#import "PankiaNet+Package.h"
#import "PankiaNetworkLibrary+Package.h"


#import "PNControllerLoader.h"
#import "PNRootViewController.h"
#import "PNRootNavigationController.h"
#import "PNRegistrationViewController.h"
#import "PNErrorViewController.h"
#import "PNInformationViewController.h"
#import "NSString+VersionString.h"
 
#import "PNDashboard.h"
#import "PNRootViewController.h"
#import "PNNavigationController.h"

#import "PNNotificationService.h"
#import "PNNotificationNames.h"

#import "PNGlobal.h"

#import "PNLocalLeaderboard.h"
#import "PNUser+Package.h"
#import "PNStoreManager.h"
#import "PNSplashManager.h"
#import "PNSplash.h"

#import "PNSplashView.h"
#import "PNGlobalManager.h"
#import "PNDeviceManager.h"


static PankiaNet* _pankakunetInstance = nil;
static NSDictionary*			receivedDic;
static NSDictionary*			waitingDic;
static BOOL						alerting;


@interface PankiaNet (Private)
- (void)clearCachedImages;
- (void)prepareLoadingCaches;
@end


@implementation PankiaNet
@synthesize pankiaNetDelegate;


-(id)init
{
	if(self = [super init]){
		
		[PNDashboard sharedObject];	//ダッシュボードを初期化しておきます
		[PNDashboard sharedObject].delegate = self;
		
		receivedDic = nil;
		waitingDic = nil;
		alerting = NO;
		
		[[PNManager sharedObject] registerDelegateToBackchannel:self forKey:@"PankiaNet"];
		[[PNManager sharedObject] setIsScreenActive:YES];
		
		
		//ログイン通知を受けるメソッドを登録
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLogin:) name:kPNManagerFinishLoginNotification object:[PNManager sharedObject]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(achievementUnlocked:) name:kPNNotificationAchievementUnlockedInLocalDatabase object:nil];
	}
	return self;
}

/*! 
 * @brief PankiaNetを初期化するためのイニシャライザです。最初に呼んでください。
 * 
 * このメソッドが呼ばれるとPankiaNetが初期化され、ダッシュボードや通信機能などを利用可能となります。
 * 自動ログインが試みられます。
 * ゲームごとのPankiaNetの設定はアプリケーションのResourcesディレクトリのPankiaNet.plistに記述してください。
 */
+ (void)initWithGameKey:(NSString*)_gameKey
			 gameSecret:(NSString*)_secret
				  title:(NSString*)_title
			   delegate:(id<PankiaNetDelegate>)delegate
				options:(NSDictionary*)options {
	
	//ゲームキーなどの情報はPNGlobalManagerクラスのsharedObjectに保持させます。
	//今後ゲームキーなどを参照したいときは関数の引数などで引き継ぐのではなく、
	//[PNGlobalManager sharedObject].gameKeyのような形で参照してください。
	[PNGlobalManager sharedObject].gameKey = _gameKey;
	[PNGlobalManager sharedObject].gameSecret = _secret;
	[PNGlobalManager sharedObject].gameTitle = _title;
	
	[PNGlobalManager sharedObject].originalIdleTimerDisabled = [UIApplication sharedApplication].idleTimerDisabled;
	
	[PankiaNet sharedObject].pankiaNetDelegate = delegate;
	
	
	
	PNManager *manager = [PNManager sharedObject];
	manager.notifyDelegate = [PankiaNet sharedObject];
	manager.delegate = [PankiaNet sharedObject];
	
	[PNDashboard sharedObject].appTitle = _title;
	
	//UDIDを元に自動ログインを試みます
	//ログインできなかった場合はユーザ登録画面が表示されます
	//このメソッドはasynchronousです。
	//ログインに成功するとmanager:didLoginが呼ばれます。
#ifndef PNUsingExternalID
	[manager login];
#endif

	//キャッシュされた画像ファイルを削除します
	[[PankiaNet sharedObject] clearCachedImages];
	
	//高速化のための最適化をします
	[[PankiaNet sharedObject] prepareLoadingCaches];
	
	//アプリケーションデリゲートをハックする
	[[PNExtendedAppDelegate sharedObject] registerDelegate:[self sharedObject]];
	
	//バッジをクリアする
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	
	[PNLocalLeaderboard sharedObject].delegate = [PankiaNet sharedObject];
	
}

/**
 Notification等を高速に読み込むためのキャッシュを作成します
 */
- (void) prepareLoadingCaches{
	[PNControllerLoader loadUIViewFromNib:@"PNTextNofiticationView" filesOwner:@""];
}

/**
 * 画像のキャッシュを削除します。(主にtwitterのアイコン周り)
 */
- (void)clearCachedImages
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* cacheDir = [documentsDirectory stringByAppendingPathComponent:@"caches/"];
	
	BOOL success = [fileManager fileExistsAtPath:cacheDir];
	if (success)
	{
		NSError*	error;
		[fileManager removeItemAtPath:cacheDir error:&error];
	}
}
+ (BOOL)isLoggedIn
{
	return [PNManager sharedObject].isLoggedIn;
}



#pragma mark -



// アプリケーション終了のフック
+ (void)terminate
{
	
}



#pragma mark public methods for Twitter

+ (BOOL)isTwitterLinked
{
	return [PNUser currentUser].isLinkTwitter;
}

+ (void)followWithName:(NSString*)username{	//Warning: 古い仕様との互換性のために残しています。時間がたったら消します。
	[self followUserByName:username];
}
+ (void)followUserByName:(NSString*)username
{
	[[PNUserManager sharedObject] followUserById:username delegate:nil onSucceeded:nil onFailed:nil];
}

+ (void)postTweet:(NSString*)tweet onSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[[PNTwitterManager sharedObject] postTweet:tweet onSuccess:onSuccess onFailure:onFailure];
}

#pragma mark -
- (void)managerDidDoneNatCheck:(PNManager *)manager {
	[PNDashboard updateDashboard];
	[PNDashboard sharedObject].isAvailableNatType = YES;
}

-(void)manager:(PNManager*)manager didLogin:(PNUser*)user { //無事ログインできた場合の処理。
	PNCLog(PNLOG_CAT_SESSION, @"PankiaNet Class manager didLogin:%@", user.username);
	
	//デリゲート先(ユーザーアプリケーション側)でメソッドが定義されば、それを呼びます。
	if([pankiaNetDelegate respondsToSelector:@selector(userDidLogin:)])
		[pankiaNetDelegate userDidLogin:user];
	
	//ゲストアカウントの場合は登録画面を表示します
#ifndef PNUsingExternalID	
	BOOL shouldShowRegistrationView = YES;
	if ([PNSettingManager storedBoolValueForKey:@"PNPankiaDisabled" defaultValue:NO] == YES) {
		shouldShowRegistrationView = NO;
	}
	
	if (shouldShowRegistrationView && pankiaNetDelegate != nil && [pankiaNetDelegate respondsToSelector:@selector(shouldShowRegistrationView)]){
		shouldShowRegistrationView = [pankiaNetDelegate shouldShowRegistrationView];
	}
	
	if (user.isGuest == YES && shouldShowRegistrationView == YES ) {
		[PNDashboard showRegistrationViewPushControllers:nil isLaunchDashboard:NO];
	}
#else
	if (user.isGuest == YES) {
		NSString* userName = [NSString stringWithFormat:@"Player%d", [PNUser currentUser].userId];
		NSLog(@"Change user name to:%@", userName);
		[[PNUserManager sharedObject] changeName:userName onSuccess:^{
			[[PNDashboard sharedObject] showLoginedNotification];
		} onFailure:^(PNError *aError){}];
	}
#endif
	
	[PNDashboard updateDashboard];
	
	//ゲストアカウントでなければログインした旨を通知します
	if (user.isGuest == NO) {
		[[PNDashboard sharedObject] showLoginedNotification];
	}
	
	// If there were splash to show, show first one.
	PNSplash* splashToShow = [[PNSplashManager sharedObject] splashToShow];
	if (splashToShow) {
		PNCLog(PNLOG_CAT_SPLASH, @"Splash to show! %d", splashToShow.id);
		PNSplashView* splashView = [PNSplashView showSplash:splashToShow orientation:[PNDashboard sharedObject].dashboardOrientation];
		splashView.autoRotateEnabled = NO;
		
//		This method is temporally disabled for debugging.
//		[[PNSplashManager sharedObject] popSplash:splashToShow];
	}
	
}
- (void)manager:(PNManager*)manager didFailLoginWithError:(PNError*)error
{
    PNWarn(@"Failed to log into PANKIA.");
    PNPrintError(error);
	if([pankiaNetDelegate respondsToSelector:@selector(userDidFailToLoginWithError:)])
		[pankiaNetDelegate userDidFailToLoginWithError:error];
}

- (void)didEndNetworkCheckingWithManager:(PNManager*)manager
{
	if([pankiaNetDelegate respondsToSelector:@selector(networkCheckDidFinish)])
		[pankiaNetDelegate networkCheckDidFinish];
}


- (void)manager:(PNManager*)manager didFailWithError:(PNNetworkError*)error {
	
	[PNDashboard updateDashboard];

	if([pankiaNetDelegate respondsToSelector:@selector(userDidFailToLoginWithError:)]){
		[pankiaNetDelegate userDidFailToLoginWithError:error];
	}		
}

// TCPコネクション、あるいはHTTPのコネクションが切れたり確立できない場合に呼ばれます。
-(void)manager:(PNManager*)manager didFailConnectionWithError:(PNError*)error {
	manager.isLoggedIn = NO;
}


-(void)manager:(PNManager*)manager didRecievePushNotification:(NSString *)message fromUser:(PNUser*)user {
	PNLog(@"didRecievePushNotification");
}

-(void)manager:(PNManager*)manager didRecieveInvitation:(PNRoom*)room fromUser:(PNUser *)user {
	PNLog(@"didRecieveInvitation");
}

#pragma mark delegate for User

- (void)didUpdateUser:(PNUser*)user
{
	[[PNAchievementManager sharedObject] syncWithServer];
	if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(userDidUpdate:) ]) {		
		[[PankiaNet sharedObject].pankiaNetDelegate userDidUpdate:user];
	}		
}

- (void)didFailWithError:(PNError*)error requestKey:(NSString*)key
{
	if ([key compare:@"rank"] == NSOrderedSame) {
		if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(fetchRankOnLeaderboardFailedWithError:) ]) {
			[[PankiaNet sharedObject].pankiaNetDelegate fetchRankOnLeaderboardFailedWithError:error];
		}
	}
	else if([key compare:@"postScore"] == NSOrderedSame){
		if( [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(postScoreFailedWithError:) ]) {
			[[PankiaNet sharedObject].pankiaNetDelegate postScoreFailedWithError:error];
		}		
	}
}

/**
 アプリケーションの最新版情報を取得したときに呼ばれるデリゲートメソッドです。
 最新版があればノーティフィケーションを表示します。
 ただし、iTunesURLが登録されていない場合は表示しません。
 ノーティフィケーションを表示させたくない場合はdelegate先でshouldShowVersionUpNotificationでNOを返すようにしてください。
 */
- (void)manager:(PNManager*)manager didGetLatestVersion:(NSString*)latestVersionString iTunesURL:(NSString*)iTunesURL{
	//現在のアプリのバージョンと比較して、最新版の方が値がおおきければノーティフィケーションを表示します。
	NSString * currentVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	if ([currentVersionString versionIntValue] < [latestVersionString versionIntValue] && iTunesURL != nil && ![iTunesURL isEqualToString:@""]){
		
		BOOL shouldShowNotification = YES;
		if (pankiaNetDelegate != nil && [pankiaNetDelegate respondsToSelector:@selector(shouldShowUpgradeNotification)]){
			shouldShowNotification = [pankiaNetDelegate shouldShowUpgradeNotification];
		}
		
		if (shouldShowNotification){
			[PNDashboard showTextNotice:[NSString stringWithFormat:getTextFromTable(@"PNTEXT:UI:New_version_available"), latestVersionString] 
													 description:getTextFromTable(@"PNTEXT:UI:Click_here_to_get_new_version") 
													   iconImage:[UIImage imageNamed:@"PNNotificationPankiaIcon.png"]
													   urlToJump:iTunesURL];
		}
	}
}

- (void)finishLogin:(NSNotification *)aNotification {
	//ウエイトしていた招待処理を実行する。
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"finishLogin:");
	if (waitingDic) {
		NSDictionary* myDic = waitingDic;
		[waitingDic autorelease];
		waitingDic = nil;
		[self application:[UIApplication sharedApplication] didReceiveRemoteNotification:myDic];
	}
}

- (void)pnAlertView:(UIAlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
	PNCLog(PNLOG_CAT_UNDEFINED,@"self.receievedDic = %@",receivedDic);
	alerting = NO;
	if (buttonIndex == 0) return;
	
	PNRoom* invitedRoom = [receivedDic objectForKey:@"invitedRoom"];
	[[self class] launchDashboardWithInternetMatchRoom:invitedRoom];
}


-(void)didGetShowRoom:(PNRoom*)room requestId:(int)requestId
{
	alerting = YES;
	
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Push_Notification")
							message:getTextFromTable(@"PNTEXT:TCP:TIMEOUT:push:received invitation")
					  okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
				  cancelButtonTitle:getTextFromTable(@"PNTEXT:CANCEL") onCancelSelected:@selector(onCancelSelected)
						   delegate:self];
	
	NSMutableDictionary* dic = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	[dic setObject:room forKey:@"invitedRoom"];
	
	PNSafeDelete(receivedDic);
	receivedDic = [dic retain];
}

- (void)onOKSelected{
	
	alerting = NO;
	
	PNRoom* invitedRoom = [receivedDic objectForKey:@"invitedRoom"];
	[[self class] launchDashboardWithInternetMatchRoom:invitedRoom];
}

- (void)onCancelSelected{
	
	alerting = NO;
}

- (void)didUpdate:(PNManager*)aManager
{
	PNCLog(PNLOG_CAT_UNIMPORTANT, @"Update dashboard.");
	[PNDashboard updateDashboard];
}

- (void)didFinishMatch:(int)aChangePoint newGradePoint:(int)aNewGradePoint
{
	NSString* title = nil;
	NSString* description = nil;
	
	PNCLog(PNLOG_CAT_UNIMPORTANT, @"Get text.");
	if (aChangePoint > 0) {//増加
		title = getTextFromTable(@"PNTEXT:FINISH_UP_TITLE");
		description = getTextFromTable(@"PNTEXT:FINISH_UP_DESCRIPTION");
	} else if (aChangePoint < 0) {//減少
		title = getTextFromTable(@"PNTEXT:FINISH_DOWN_TITLE");
		description = getTextFromTable(@"PNTEXT:FINISH_DOWN_DESCRIPTION");
	} else if (aChangePoint == 0) {//変化無し
		title = getTextFromTable(@"PNTEXT:FINISH_SAME_TITLE");
		description = @"";
	}
	
	
	PNCLog(PNLOG_CAT_UNIMPORTANT, @"Update dashboard.");
	[PNDashboard updateDashboard];
	
	PNCLog(PNLOG_CAT_UNIMPORTANT, @"PNNotificationService showTextNotice");
	[PNDashboard showTextNotice:title 
					description:[NSString stringWithFormat:description, aChangePoint] 
					  iconImage:[UIImage imageNamed:@"PNNotificationGradeIcon.png"]
				 smallIconImage:[UIImage imageNamed:@"PNGradeIconSmall.png"]
					pointString:[NSString stringWithFormat:@"%d", aNewGradePoint]];
	
}


//Switch Account
- (void)userDidSwitchAccount:(PNUser*)user
{
	[PNManager sharedObject].canResend = YES;
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil
		&& [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(userDidSwitchAccount:)]){
			[[PankiaNet sharedObject].pankiaNetDelegate userDidSwitchAccount:user];
	}
}

- (void)userWillSwitchAccount:(PNUser*)user
{
	[PNManager sharedObject].canResend = NO;
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil
		&& [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(userWillSwitchAccount:)]){
			[[PankiaNet sharedObject].pankiaNetDelegate userWillSwitchAccount:user];
	}
}



//Appdelegate
- (void)pnApplicationDidBecomeActive:(UIApplication *)application
{
	if (![PNManager sharedObject].isScreenActive
		&& ![PNManager sharedObject].isLoggedIn) {
		[[PNManager sharedObject] login];
	}	
	[PNManager sharedObject].delegate = self;
	[[PNManager sharedObject] setIsScreenActive:YES];
}
- (void)pnApplicationWillEnterForeground:(UIApplication *)application
{
	[[PNManager sharedObject] applicationWillEnterForeground:application];
}
- (void)pnApplicationDidEnterBackground:(UIApplication *)application
{
	[[PNManager sharedObject] applicationDidEnterBackground:application];
}
+ (void)applicationWillEnterForeground:(UIApplication *)application{
	[[PankiaNet sharedObject] pnApplicationWillEnterForeground:application];
}
+ (void)applicationDidEnterBackground:(UIApplication *)application{
	[[PankiaNet sharedObject] pnApplicationDidEnterBackground:application];
}

- (void)pnApplicationWillResignActive:(UIApplication*)application
{
	[[PNManager sharedObject] setIsScreenActive:NO];
}
- (void)pnApplication:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	[[[[PNDeviceManager alloc] init] autorelease] registerDeviceToken:deviceToken];
}
- (void)pnApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	if (![[PNManager sharedObject] canPush]) {
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Can not push.");
		
		if (waitingDic) {
			[waitingDic release];
		}
		waitingDic = [userInfo retain];
		return;
	}
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"userInfo = %@", userInfo);
	NSDictionary* pankiaData = [userInfo objectForKey:@"pn"];
	NSString* roomId = [pankiaData objectForKey:@"room"];
	if (roomId) {
		PNRoomManager* roomManager = [PNManager roomManager];
		roomManager.delegate = (id<PNRoomManagerDelegate>)self;
		[roomManager showRoom:roomId];
	}
	
	PNSafeDelete(receivedDic);
	receivedDic = [userInfo retain];
}

- (void)dealloc
{
	self.pankiaNetDelegate  = nil;
	[super dealloc];
}
#pragma mark Settings
+ (void)setInternetMatchMinRoomMember:(int)minMember
{
	[[PNSettingManager sharedObject] setInternetMatchMinRoomMember:minMember];
}
+ (void)setInternetMatchMaxRoomMember:(int)maxMember
{
	[[PNSettingManager sharedObject] setInternetMatchMaxRoomMember:maxMember];
}
+ (void)setNearbyMatchMinRoomMember:(int)minMember
{
	[[PNSettingManager sharedObject] setNearbyMatchMinRoomMember:minMember];
}
+ (void)setNearbyMatchMaxRoomMember:(int)maxMember
{
	[[PNSettingManager sharedObject] setNearbyMatchMaxRoomMember:maxMember];
}
# pragma mark -
# pragma mark Singleton Pattern
+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (!_pankakunetInstance) {
            _pankakunetInstance = [super allocWithZone:zone];
            return _pankakunetInstance;
        }
    }
    return nil;
}

+ (PankiaNet*) sharedObject
{
    @synchronized(self) {
		if (!_pankakunetInstance) {
			[[self alloc] init];
		}
    }
    return _pankakunetInstance;
}

- (id)copyWithZone:(NSZone*)zone{return self;}



- (void)applicationWillTerminate:(UIApplication *)application
{
	[PankiaNet terminate];
}

@end
