
#import "PNQuickMatchViewController.h"
#import "PNJoinedRoomViewController.h"
#import "PNControllerLoader.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNDashboard.h"
#import "PNGlobal.h"
#import "PankiaNet+Package.h"
#import "PNStoreManager.h"
#import "PNAlertHelper.h"
#import "PNGlobalManager.h"
#import "PNItemOwnershipModel.h"
#import "PNGradeModel.h"

#define kPNFetchRoomsNum 10

// ソートで使用するメソッド
NSInteger intSort(id num1, id num2, void *context)
{
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


@interface PNQuickMatchViewController (Private)
- (void)startFindingRooms;
- (PNRoom*)decideRoomToJoin:(NSArray*)rooms;
- (void) createARoomByMyself;
@end

@implementation PNQuickMatchViewController

@synthesize matchUpRoomCell;
@synthesize noneCell;
@synthesize roomToJoin;
@synthesize failedRoomNames;
@synthesize joinedRoomViewController;
@synthesize currentGameSession;
@synthesize statusLabel;
@synthesize lobby;
@synthesize lobbyName;

- (void)viewDidLoad
{
	hasJoinedRoomViewControllerPushed = NO;
	canCancelMatching = YES;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	isPushedCancelButton = NO;
	
	cancelButton = [[[UIBarButtonItem alloc] init] autorelease];
	cancelButton.title = getTextFromTable(@"PNTEXT:BUTTON:Cancel");
	cancelButton.target = self;
	cancelButton.action = @selector(cancelQuickMatching);	
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	[[PNManager sharedObject] setCanPush:NO];
	[PNDashboard disableAllButtons];
	shouldCancelMatching = NO;
	currentStatus = kPNQuickMatchStateNone;
	
	// begin - lerry modified
	BOOL coinEnabled = [[PNGlobalManager sharedObject] coinsEnabled];
	if (coinEnabled == YES && [PNUser currentUser].coins <= 0) {
		[PNAlertHelper showAlertForCoinPurchaseWithDelegate:self onPurchase:@selector(purchaseCoins) 
												   onCancel:@selector(noPurchase)];
	} else {
		[self performSelector:@selector(startFindingRooms) withObject:nil afterDelay:1.0f];
	}	
	// end - lerry modified
	
	// この画面ではスリープを無効化。
	[UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	// この画面ではスリープを有効化。
	[UIApplication sharedApplication].idleTimerDisabled = [PNGlobalManager sharedObject].originalIdleTimerDisabled;
}

- (void)purchaseCoins {
	[PNDashboard disableAllButtons];
//	[[PNStoreManager sharedObject] purchaseDefaultCoinSetWithDelegate:self	onSucceeded:@selector(purchaseSucceeded:) 
//															 onFailed:@selector(noPurchase)];
}

- (void)noPurchase {
	[PNDashboard popViewController];
}

- (void)purchaseSucceeded:(PNItemOwnershipModel*)item {
	[PNUser currentUser].coins = item.quantity;
	[PNDashboard updateDashboard];
	
	[self performSelector:@selector(startFindingRooms) withObject:nil afterDelay:1.0f];
	
	[PNDashboard disableAllButtons];
}

- (void)cancelQuickMatching {
	shouldCancelMatching = YES;
	if (self.joinedRoomViewController != nil && canCancelMatching) {
		[[PNManager roomManager] leaveInternetRoom:self.joinedRoomViewController.myRoom delegate:self 
									   onSucceeded:@selector(leaveSucceeded) 
										  onFailed:@selector(leaveFailed)];
		[PNDashboard showIndicator];
	}
}

- (void)quitQuickMatching {
	if(!isPushedCancelButton) {
		[PNDashboard hideIndicator];
		if (self.joinedRoomViewController) {
			self.joinedRoomViewController.myRoom.delegate = nil;
			self.joinedRoomViewController.myRoom = nil;
			self.joinedRoomViewController = nil;
		}
		[PNManager roomManager].delegate = nil;
		[PNDashboard popViewController];
		[PNDashboard resetAllButtons];
		isPushedCancelButton = YES;
	}
}

- (void)leaveSucceeded
{
	[self quitQuickMatching];
}

// 部屋の一覧を取得しにいきます
- (void)startFindingRooms {
	currentStatus = kPNQuickMatchStateFinding;
	PNRoomManager* roomManager = [PNManager roomManager];
	roomManager.delegate = self;
	[roomManager findRooms:kPNFetchRoomsNum
				   inLobby:lobby.lobbyId
				  delegate:self
			   onSucceeded:@selector(findRoomsSucceeded:)
				  onFailed:@selector(findRoomsFailed:)];
	[statusLabel setText:@"PNTEXT:MATCH:FINDING_ROOMS"];
}

- (void)findRoomsSucceeded:(NSArray*)rooms {
	if (shouldCancelMatching) {
		[self quitQuickMatching];
		return;
	}
	
	//ランダムに一つ部屋を選びます
	self.roomToJoin = [self decideRoomToJoin:rooms];
	if (roomToJoin == nil) {
		//部屋がなければ自分で作ります
		[self createARoomByMyself];
		return;
	}
	
	[statusLabel setText:[NSString stringWithFormat:@"- %@ -", roomToJoin.roomName]];
	
	roomToJoin.delegate = self;
	roomToJoin.lobby = lobby;
	//	[myRoom join];
	[PNManager roomManager].delegate = self;
	[[PNManager roomManager] joinInternetRoom:roomToJoin
									 delegate:self 
								  onSucceeded:@selector(joinSucceeded) 
									 onFailed:@selector(joinFailed:)];
}
- (void)findRoomsFailed:(PNError*)error
{
	// 通常ここには到達しない
}

#pragma mark -

// 入る部屋を決定します
- (PNRoom*)decideRoomToJoin:(NSArray*)rooms {	
	// STEP 1. 既にJOINに失敗したルームを除外します
	NSMutableArray* roomsToJoin = [NSMutableArray array];
	for (PNRoom* room in rooms) {
		BOOL isAlreadyFailed = NO;
		for (NSString* failedRoomName in failedRoomNames) {
			if ([failedRoomName isEqualToString:room.roomName]) {
				isAlreadyFailed = YES;
				break;
			}
		}
		if (isAlreadyFailed == NO) {
			[roomsToJoin addObject:room];
		}
	}
	
	// STEP2. 2人部屋を優先的に選びます
	NSMutableDictionary* roomWithMemberNumbers = [NSMutableDictionary dictionary];
	for (PNRoom* room in roomsToJoin) {
		NSNumber* maxMemberNum = [NSNumber numberWithInt:room.maxMemberNum];
		if (![roomWithMemberNumbers objectForKey:maxMemberNum]){
			[roomWithMemberNumbers setObject:[NSMutableArray array] forKey:maxMemberNum];
		}
		[[roomWithMemberNumbers objectForKey:maxMemberNum] addObject:room];
	}
	
	// STEP3. 人数が少ない部屋から優先的に選んでいきます
	for (NSNumber* number in [[roomWithMemberNumbers allKeys] sortedArrayUsingFunction:intSort context:nil]){
		NSArray* rooms = [roomWithMemberNumbers objectForKey:number];
		return [rooms objectAtIndex:rand() % [rooms count]];
	}
	
	// 入るべき部屋がなければnilを返します
	return nil;
}

// 入るべき部屋がないときに自分で部屋を作ります
- (void) createARoomByMyself {
	[statusLabel setText:@"PNTEXT:MATCH:Creating_a_room"];
	[[PNManager roomManager] createAnInternetRoomWithMaxMemberNum:[[PNSettingManager sharedObject] internetMatchMinRoomMember]
														 isPublic:YES 
														 roomName:[NSString stringWithFormat:@"%@'s room", [PNUser currentUser].username]
													   gradeRange:kPNGradeAll 
														  lobbyId:lobby.lobbyId
														 delegate:self 
													  onSucceeded:@selector(createARoomSucceeded:)
														 onFailed:@selector(createARoomFailed:)];
}

- (void)createARoomSucceeded:(PNRoom*)room {
	[statusLabel setText:@"PNTEXT:UI:Rematch:Waiting_for_other_players"];
	
	room.delegate = self;
	room.lobby = lobby;
	
	self.joinedRoomViewController = (PNJoinedRoomViewController*)[PNControllerLoader load:@"PNJoinedRoomViewController"
																			   filesOwner:nil];
	joinedRoomViewController.myRoom = room;
	[joinedRoomViewController setTitle:roomToJoin.roomName];
	
}

- (void)createARoomFailed:(PNError*)error {
	// 1秒待って部屋の一覧を取得しなおし、別の部屋に入室を試みます
	[self performSelector:@selector(startFindingRooms) withObject:nil afterDelay:1.0f];
}

#pragma mark -

//入室に成功したときに呼ばれます
- (void)joinSucceeded {
	[statusLabel setText:@"PNTEXT:UI:Rematch:Waiting_for_other_players"];
	
	self.joinedRoomViewController = (PNJoinedRoomViewController*)[PNControllerLoader load:@"PNJoinedRoomViewController"
																			   filesOwner:nil];
	joinedRoomViewController.myRoom = (PNRoom*)roomToJoin;
	[self.joinedRoomViewController setTitle:roomToJoin.roomName];
}

//入室に失敗したときに呼ばれます
- (void)joinFailed:(PNError*)error {
	//	self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Join failed.");
	//	if ([PNDashboard sharedObject].isDismissed || backToRoomsViewAfterLeaving) return;
	
	// 入室処理中にメンバーの変更があったことによる失敗の場合は、リトライします
	if (error.errorType == kPNRoomErrorFailedMemberChange){
		[statusLabel setText:@"PNTEXT:MATCH:FINDING_ROOMS"];
		[self performSelector:@selector(startFindingRooms) withObject:nil afterDelay:1.0f];
		return;
	}
	BOOL isNecessaryBack = NO;
	NSString* errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
	if (error.errorType == kPNStunPunchingRTTOverrange) {
		errorMessage = getTextFromTable(@"PNTEXT:UDP:FAIL:p2p:speed is late");
	} else if (error.errorType == kPNStunPunchingFailed || error.errorType == kPNStunPunchingTimeout) {
		errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:ERROR:UHP_error");
	} else if (error.errorType == kPNRoomErrorFailedAlreadyStarted) {
		errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num");
		isNecessaryBack = YES;
	} else if (error.errorType == kPNRoomErrorFailedAlreadyDeleted) {
		errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
		isNecessaryBack = YES;
	}
	
	[statusLabel setText:@"PNTEXT:MATCH:FINDING_ROOMS"];

	// 失敗した部屋リストに登録します
	if (self.failedRoomNames == nil){
		self.failedRoomNames = [NSMutableArray array];
	}
	[self.failedRoomNames addObject:self.roomToJoin.roomName];
	self.roomToJoin = nil;
	
	// 1秒待って部屋の一覧を取得しなおし、別の部屋に入室を試みます
	[self performSelector:@selector(startFindingRooms) withObject:nil afterDelay:1.0f];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	PNRoomManager* roomManager = [PNManager roomManager];
	[roomManager stopFindActiveRooms];
	
	self.lobbyName = nil;
	self.roomToJoin = nil;
	self.failedRoomNames = nil;
	self.currentGameSession = nil;
	self.navigationItem.leftBarButtonItem = nil;
	
	PNSafeDelete(matchUpRoomCell);	
	[super dealloc];
}


#pragma mark PNRoomManagerDelegate Call back methods

///////////
// PNRoomManagerDelegate.

//サーバーの場合はこちらに通知される。
-(void)didCreateRoom:(PNRoom*)room requestId:(int)requestId {
	PNLog(@"didCreateRoom\n");
}

//クライアントの場合はこちらに通知される。
-(void)didFindActiveRoom:(PNRoom*)room requestId:(int)requestId {
	PNLog(@"didFindActiveRoom da\n");
}

-(void)didFindActiveRooms:(NSArray*)rooms requestId:(int)requestId {}


// JoinedRoomViewControllerにForwardします
-(void)roomDidJoin:(PNRoom*)room{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController roomDidJoin:room];
	}
}
-(void)room:(PNRoom*)room didFailJoinWithError:(PNNetworkError*)error{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController room:room didFailJoinWithError:error];
	}
}
-(void)roomDidLeave:(PNRoom*)room{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController roomDidLeave:room];
	}
}
-(void)room:(PNRoom*)room didJoinUser:(PNUser*)user{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController room:room didJoinUser:user];
	}
}
-(void)room:(PNRoom*)room didLeaveUser:(PNUser*)user{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController room:room didLeaveUser:user];
	}
}
-(void)didLeaveRoom:(PNRoom*)room{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController didLeaveRoom:room];
	}
}
-(void)room:(PNRoom*)room didUpdateJoinedUsers:(NSArray*)users{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController room:room didUpdateJoinedUsers:users];
	}
}
-(void)room:(PNRoom*)room didFailWithError:(PNError*)error{
	if (joinedRoomViewController != nil) {
		[joinedRoomViewController room:room didFailWithError:error];
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	PNLog(@"(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section");
	if (joinedRoomViewController != nil) {
		PNLog(@"joinedRoomViewController");
		return [joinedRoomViewController tableView:tableView numberOfRowsInSection:section];
	}
    return 0;
}



#pragma mark GameSession Start/End
-(void)room:(PNRoom*)room willBeginGameSession:(PNGameSession*)gameSession
{
	canCancelMatching = NO;
	self.currentGameSession = gameSession;
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionWillBegin:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionWillBegin:gameSession];
	}	
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"willBeginGameSession\n");
	//[PNDashboard showLargeIndicator];
	[statusLabel setText:getTextFromTable(@"PNTEXT:MATCH:Match_will_start_soon")];
}

-(void)room:(PNRoom*)room didBeginGameSession:(PNGameSession*)gameSession
{
	canCancelMatching = YES;
	[PNDashboard hideIndicator];
	[[PNManager sharedObject] setCanPush:NO];
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidBegin:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidBegin:gameSession];
	}
	[PNDashboard hideIndicator];
	PNLogMethod(@"didBeginGameSession\n");
	if (![PNDashboard sharedObject].isDismissed) {
		[PankiaNet dismissDashboard];
	}
	
}

-(void)room:(PNRoom*)aRoom didRestartGameSession:(PNGameSession*)gameSession
{
	[PNDashboard hideIndicator];
	
	if([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidRestart:)]){
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidRestart:gameSession];
	}
	
	[PankiaNet dismissDashboard];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didRestartGameSession\n");
}
-(void)room:(PNRoom*)room didEndGameSession:(PNGameSession*)gameSession
{
	
	[[PNManager sharedObject] setCanPush:YES];
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidEnd:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidEnd:gameSession];
	}
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didEndGameSession\n");
//		if (![PNDashboard sharedObject].isDismissed) {
//			[PankiaNet dismissDashboard];
//		}
//		
//		[PankiaNet launchDashboardWithInternetMatchView];
}

-(void)gameSession:(PNGameSession*)gameSession didConnectPeer:(PNPeer*)opponent{}
-(void)gameSession:(PNGameSession*)gameSession didDisconnectPeer:(PNPeer*)opponent{}
-(void)didGameSessionEnd:(PNGameSession*)gameSession
{
	
}
-(void)gameSession:(PNGameSession*)gameSession didReceiveData:(NSData*)data from:(PNPeer*)opponent{}
-(void)gameSession:(PNGameSession*)gameSession didSendError:(PNError*)error opponent:(PNPeer*)peer data:(NSData*)data {}

#pragma mark Rematch Process
-(void)didStartRematchProcessing
{
	if (self.joinedRoomViewController != nil) {
		if (hasJoinedRoomViewControllerPushed == NO){
			[PNDashboard pushViewController:joinedRoomViewController];
			hasJoinedRoomViewControllerPushed = YES;
		}
		[joinedRoomViewController didStartRematchProcessing];
		joinedRoomViewController.currentUserState = kPNInternetMatchRoomUserStateJoining;
		
		// メンバーリストを更新します
		if (joinedRoomViewController.joinedUsers == nil) joinedRoomViewController.joinedUsers = [NSMutableArray array];
		[joinedRoomViewController.joinedUsers removeAllObjects];
		for (PNPeer* peer in [currentGameSession peerList]) {
			[joinedRoomViewController.joinedUsers addObject:peer.user];
		}
		[joinedRoomViewController reloadData];
	}	
}

// When finished rematch synchronous processing, call back this method.
-(void)synchronizationBeforeVotingDone
{
	if (self.joinedRoomViewController != nil) {
		[joinedRoomViewController synchronizationBeforeVotingDone];
	}
}
- (void)rematchYes {

}
- (void)rematchNo {

}


-(void)receivedRequestMessage:(NSDictionary *)params
{
	if (self.joinedRoomViewController != nil) {
		[joinedRoomViewController receivedRequestMessage:params];
	}
}


// When finished result processing, call back this method.
-(void)decidedRematchResult:(NSArray*)memberArray // Member of the remainder. Element type is PNPeer*
{
	if (self.joinedRoomViewController != nil) {
		[joinedRoomViewController decidedRematchResult:memberArray];
	}
}

- (BOOL)shouldShowWrapperFrame
{
	return YES;
}

@end

