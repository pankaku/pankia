#import "PNJoinedRoomViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNInviteFriendsViewController.h"
#import "PNControllerLoader.h"
#import "PNDashboardHeaderView.h" 
#import "PNDashboard.h"
#import "PankiaNet+Package.h"
#import "PNGlobal.h"
#import "PNStoreManager.h"
#import "PNItemOwnershipModel.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNAlertHelper.h"

#import "PNGlobalManager.h"


//インターネットマッチで部屋の入室処理がタイムアウトになるまでの時間
#define kPNInternetMatchJoinTimeout					60.0f

@interface PNJoinedRoomViewController (Private)
- (void)setNavigationItemsEnabled:(BOOL)value;
- (void)checkDoneJoining:(NSNumber*)aTransactionID;
- (void)forceToLeave;
@end


@implementation PNJoinedRoomViewController

@synthesize joinedRoomCell;
@synthesize myRoom;
@synthesize isJoin;
@synthesize isReload;
@synthesize currentJoiningPhase;
@synthesize transactionNumber;
@synthesize speedLevels;
@synthesize currentUserState;
@synthesize isWaitingForRematch;
@synthesize joinedUsers;
@synthesize headerCell_;
@synthesize joinedRoomEventCell_;


#pragma mark Setter / Getter methods

- (void)setNavigationItemsEnabled:(BOOL)value {
	[self.navigationItem.leftBarButtonItem setEnabled:value];
	[self.navigationItem.rightBarButtonItem setEnabled:value];
}

- (void)setCurrentUserState:(PNInternetRoomUserState)newState {
	
	currentUserState = newState;
	
	switch (currentUserState) {
		case kPNInternetMatchRoomUserStateLoading:
			
			break;
		case kPNInternetMatchRoomUserStateObserving:
			
			break;
		case kPNInternetMatchRoomUserStateRequesting:
			[PNDashboard disableAllButtons];
			break;
		case kPNInternetMatchRoomUserStateJoining:
			[PNDashboard disableAllButtons];
			break;
		case kPNInternetMatchRoomUserStateLeaving:
			[PNDashboard disableAllButtons];
			break;
		default:
			break;
	}
}

- (void)setCurrentJoiningPhase:(PNInternetRoomJoiningPhase)phase {
	
	if (currentJoiningPhase == phase) return;
	
	currentJoiningPhase = phase;
	
	switch (currentJoiningPhase) {
		case kPNInternetMatchRoomJoiningStartPairing:	//入室処理を開始、UHPを試みます
			// 入室処理が開始されたら、左側のメニューを選べないようにします。
			[PNDashboard disableAllButtons];
			[PNDashboard updateIndicatorDescription:@"PNTEXT:MATCH:CONNECTING_PHASE:Connecting_to_room_members"];
			
			// 入室処理開始から一定時間たっても入室処理が完了していない場合はエラーにします。
			self.transactionNumber++;
			[self performSelector:@selector(checkDoneJoining:)
					   withObject:[NSNumber numberWithInt:self.transactionNumber]
					   afterDelay:kPNInternetMatchJoinTimeout];
			break;
		case kPNInternetMatchRoomJoiningStartPunching:
			[PNDashboard updateIndicatorDescription:@"PNTEXT:MATCH:CONNECTING_PHASE:Check_connection_speed"];
			break;
		case kPNInternetMatchRoomJoiningReport:
			PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Change status->reporting");
			[PNDashboard updateIndicatorDescription:@"PNTEXT:MATCH:CONNECTING_PHASE:Waiting_for_response_from_server"];
			break;
		case kPNInternetMatchRoomJoiningDone:
			PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Change status->done");
			self.currentUserState = kPNInternetMatchRoomUserStateJoining;
			self.isJoin = YES;
			[self setNavigationItemsEnabled:YES];
			[self reloadData];
			[[self class] cancelPreviousPerformRequestsWithTarget:self
														 selector:@selector(checkDoneJoining:)
														   object:[NSNumber numberWithInt:self.transactionNumber]];
			self.transactionNumber++; // TransactionをExpireします。
			break;
		case kPNInternetMatchRoomJoiningNone:	// 入室失敗や退室したときに出ます。
			self.currentUserState = kPNInternetMatchRoomUserStateObserving;
			[self setNavigationItemsEnabled:YES];
			[[self class] cancelPreviousPerformRequestsWithTarget:self
														 selector:@selector(checkDoneJoining:)
														   object:[NSNumber numberWithInt:self.transactionNumber]];
			self.transactionNumber++; // TransactionをExpireします。
			if (myRoom.isJoined == NO) {
				[PNDashboard resetAllButtons];
			}
			break;
		default:
			break;
	}
}
- (BOOL)isJoined {
	if (joinedUsers == nil || [joinedUsers count] == 0)
		return NO;
	
	if([joinedUsers indexOfObject:[PNUser currentUser]] == NSNotFound)
		return NO;
	else 
		return YES;
}

#pragma mark -
- (void)awakeFromNib {
	[super awakeFromNib];
	isWaitingForRematch = NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// 入室のタイミングではルームメンバーではないことを示します。
	self.currentUserState = kPNInternetMatchRoomUserStateLoading;
	self.tableView.separatorColor = [UIColor cyanColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self.navigationItem setHidesBackButton:YES];	// UINavigationItem -> setHidesBackButton:animated:表示のON/OFFを指定
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	roomMemberLoaded = NO;
	forceLeaveFlag = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	backToRoomsViewAfterLeaving = NO;
	
	if (self.currentUserState == kPNInternetMatchRoomUserStateRequesting
		|| self.currentUserState == kPNInternetMatchRoomUserStateJoining){
		[PNDashboard disableAllButtons];
	}
	
	[super viewDidAppear:animated];
	[self reloadStart];
	
	// この画面ではスリープを無効化。
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	appearDone = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	isReload = NO;
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	backToRoomsViewAfterLeaving = NO;
	[super viewDidDisappear:animated];
	// PNMyRoomViewControllerと同様に、ここでは[[myRoom leave]しないこと。
	// この画面ではスリープを有効化。
	[UIApplication sharedApplication].idleTimerDisabled = [PNGlobalManager sharedObject].originalIdleTimerDisabled;
}
#pragma mark -
- (void)resetRoomMembers {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"resetRoomMembers");
	if(![self.myRoom isGameRestarting]) {
		if(!joinedUsers) {
			joinedUsers = [[NSMutableArray alloc] init];
		}
		
		[self reloadData];
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"getMembers");
		//ルームメンバー一覧をサーバからダウンロードしてきます
		[[PNManager roomManager] getMembersOfRoom:self.myRoom
										 delegate:self 
									  onSucceeded:@selector(getMembersSucceeded:) 
										 onFailed:@selector(getMembersFailed:)];
	}
}

- (void)getMembersSucceeded:(NSArray*)peers {
	if (!self.speedLevels) {
		self.speedLevels = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	}
	
	for (PNPeer* peer in peers) {
		NSString* level = [NSString stringWithFormat:@"%d", peer.speedLevel];
		[self.speedLevels setObject:level forKey:peer.user.username];
	}
	
	// リマッチ待機中でなければ、ルームメンバに達している／ロックされた部屋からは退出します
	if (isWaitingForRematch == NO) {
		if (isJoin == NO && ([peers count] >= self.myRoom.maxMemberNum || self.myRoom.isLocked )) {
			//メンバーが既に最大人数に達していた場合、
			//あるいはロックされていた場合は戻ります
			isReload = NO;

			[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
												   message:getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num")
											 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
											  onOKSelected:@selector(onOKSelected) 
										 cancelButtonTitle:nil
										  onCancelSelected:nil
												  delegate:self];
			
			[[PNManager sharedObject] setCanPush:YES];
			[PNDashboard popViewController];
			return;
		}
		
		if (![peers count]) {
			[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
												   message:getTextFromTable(@"PNTEXT:ERROR:failed_remove_room")
											 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
											  onOKSelected:@selector(onOKSelected) 
										 cancelButtonTitle:nil
										  onCancelSelected:nil
												  delegate:self];
			
			[[PNManager sharedObject] setCanPush:YES];
			[PNDashboard popViewController];
			
			return;
		}
	}
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didUpdateJoinedUser\n");
	[joinedUsers removeAllObjects];
	for (PNPeer* peer in peers) {
		[joinedUsers addObject:peer.user];
	}
	roomMemberLoaded = YES;
	if (self.currentUserState == kPNInternetMatchRoomUserStateLoading) {
		self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	}
	if (self.currentUserState != kPNInternetMatchRoomUserStateRequesting) {
		[PNDashboard hideIndicator];
	}
	
	[self.myRoom roundTripTimeMeasurement:peers];	//RTT計測を行います
	[self reloadData];								//画面の表示を更新します
}

- (void)onOKSelected {
	[self roomDidLeave:self.myRoom];
	[PNDashboard hideIndicator];
}

- (void)getMembersFailed:(PNError*)error {
	
	if( isWaitingForRematch == NO) {
		NSString *errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
		if (error.errorType == kPNRoomErrorFailedAlreadyStarted) {
			errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num");
		}
		else if (error.errorType == kPNRoomErrorFailedAlreadyDeleted) {
			errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
		}

		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
											   message:errorMessage
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil
									  onCancelSelected:nil
											  delegate:self];
		[PNDashboard popViewController];
	}
}



#pragma mark -
#pragma mark PNRoomDelegate

- (void)room:(PNRoom*)room error:(PNNetworkError*)e requestKey:(NSString*)key
{
	
}



// 部屋にJOINしようとして失敗したときに呼ばれます。
- (void)room:(PNRoom*)room didFailJoinWithError:(PNNetworkError*)error {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didFailJoinWithError\n");
	//既に一度エラーメッセージが表示されていたら、２度目以降は表示しません
	if (hasSomeErrorForJoining == NO) {
		//表示するエラーメッセージの内容を決定します
		NSString *errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:ERROR:UHP_error");
		
		if (error.errorType == kPNStunPunchingRTTOverrange) {
			errorMessage = getTextFromTable(@"PNTEXT:UDP:FAIL:p2p:speed is late");
		}
		else if (error.errorType == kPNStunPunchingFailed || error.errorType == kPNStunPunchingTimeout) {
			errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:ERROR:UHP_error");
		}
		else if (error.errorType == kPNRoomErrorFailedAlreadyStarted) {
			errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num");
		}
		else if (error.errorType == kPNRoomErrorFailedAlreadyDeleted) {
			errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
		}
		
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
											   message:errorMessage
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil
									  onCancelSelected:nil
											  delegate:self];
	}
	hasSomeErrorForJoining = YES;
	self.currentJoiningPhase = kPNInternetMatchRoomJoiningNone;
}

- (void)room:(PNRoom*)room finishGetSpeedLevelForPeer:(PNPeer*)peer {
	[self.speedLevels setObject:[NSString stringWithFormat:@"%d",peer.speedLevel] forKey:peer.user.username];
	[self reloadData];
}


- (void)room:(PNRoom*)room willStartPairing:(PNPeer*)peer {
	if (self.currentUserState == kPNInternetMatchRoomUserStateRequesting) {
		self.currentJoiningPhase = kPNInternetMatchRoomJoiningStartPunching;
	}
}

- (void)roomDidLeave:(PNRoom*)room {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"roomDidLeave\n");
	self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	self.isJoin = NO;
	[self reloadData];
}

- (void)roomDidJoin:(PNRoom*)room {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"roomDidJoin\n");
	self.currentJoiningPhase = kPNInternetMatchRoomJoiningDone;
	self.currentUserState = kPNInternetMatchRoomUserStateJoining;
	[PNDashboard disableAllButtons];
	[self reloadData];
}

- (void)room:(PNRoom*)room didReport:(NSString*)report {
	if (self.currentUserState == kPNInternetMatchRoomUserStateRequesting) {
		self.currentJoiningPhase = kPNInternetMatchRoomJoiningReport;
	}
}

- (void)room:(PNRoom*)room didJoinUser:(PNUser*)user {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didJoinUser\n");
	if (user != nil){
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @" joinedUser: %@", user.username);
	}
	
	//入室処理が完了したことを設定します。
	self.currentJoiningPhase = kPNInternetMatchRoomJoiningDone;
}

- (void)room:(PNRoom*)room didLeaveUser:(PNUser*)user {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didLeaveUser\n");
	if (room == nil && user == nil) {
	}
	else {
		[self reloadData];		
	}
}

- (void)room:(PNRoom*)room didUpdateJoinedUsers:(NSArray*)users {
	
	if (!self.speedLevels) {
		self.speedLevels = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
	}
	
	for (PNPeer* peer in [room.peers allValues]) {
		NSString* level = [NSString stringWithFormat:@"%d", peer.speedLevel];
		[self.speedLevels setObject:level forKey:peer.user.username];
	}
	
	if (isJoin == NO && ([users count] >= room.maxMemberNum || room.isLocked )) {
		// メンバーが既に最大人数に達していた場合、あるいはロックされていた場合は戻ります。
		isReload = NO;
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
											   message:getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil
									  onCancelSelected:nil
											  delegate:self];
		
		[[PNManager sharedObject] setCanPush:YES];
		[PNDashboard popViewController];
		return;
	}
	[joinedUsers removeAllObjects];
	[joinedUsers addObjectsFromArray:users];
	roomMemberLoaded = YES;
	
	if (self.currentUserState == kPNInternetMatchRoomUserStateLoading) {
		self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	}
	
	if (self.currentUserState != kPNInternetMatchRoomUserStateRequesting) {
		[PNDashboard hideIndicator];
		
	}
	[self reloadData];
}



- (void)room:(PNRoom*)room didFailWithError:(PNNetworkError*)error {
	
	if ([PNDashboard sharedObject].isDismissed || backToRoomsViewAfterLeaving)
		return;
	
	[[PNManager sharedObject] setCanPush:YES];
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didFailWithError error:(%d)%@", error.errorCode, error.message);
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidFailWithError:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidFailWithError:error];
	}
	
	NSString* errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
	if (error.errorType == kPNStunPunchingRTTOverrange) {
		errorMessage = getTextFromTable(@"PNTEXT:UDP:FAIL:p2p:speed is late");
	}
	else if (error.errorType == kPNStunPunchingFailed || error.errorType == kPNStunPunchingTimeout) {
		errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:ERROR:UHP_error");
	}
	else if (error.errorType == kPNRoomErrorFailedAlreadyStarted) {
		errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num");
	}
	else if (error.errorType == kPNRoomErrorFailedAlreadyDeleted) {
		errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
	}
	else if (error.errorType == kPNRoomErrorFailedSync) {
		errorMessage = getTextFromTable(@"PNTEXT:MATCH:Synchronous_fail.");
	}
	
	//インターネットマッチのタイトル画面に移動します
	[[PNDashboard getWrappedNavigationController] returnRootView];
	[[PNDashboard getWrappedNavigationController] pushViewController:[PNControllerLoader load:@"PNMatchUpViewController"
																				   filesOwner:nil] animated:YES];
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
										   message:errorMessage
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil 
								  onCancelSelected:nil
										  delegate:self];
}



#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [joinedUsers count] + 2; // HeaderとEventCell部分を追加します。
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	if (indexPath.row == 0) {
		return 40.0f;
	}
	else {
		return 50.0f;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
		NSString* identifier =
		[NSString stringWithFormat:@"PNJoinedRoomHeaderCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNHeaderCell* cell = (PNHeaderCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = headerCell_;
			self.headerCell_ = nil;
		}
		cell.backgroundView =
		[[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNCellInfoBackgroundImage]] autorelease];
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		[cell setMyCoin];
		
		return cell;
	}
	else if (indexPath.row == ([joinedUsers count] + 1))  {
		NSString* identifier =
		[NSString stringWithFormat:@"PNJoinedRoomEventCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNJoinedRoomEventCell* cell = (PNJoinedRoomEventCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = joinedRoomEventCell_;
			self.joinedRoomEventCell_ = nil;
		}
		cell.delegate = self;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[self setBackgroundImage:cell];
		
		switch (self.currentUserState) {
			case kPNInternetMatchRoomUserStateLoading:
				cell.joinState = NOT_READY;
				break;
			case kPNInternetMatchRoomUserStateObserving:
				cell.joinState = NOT_JOINED;
				break;
			case kPNInternetMatchRoomUserStateRequesting:
				
				break; //
			case kPNInternetMatchRoomUserStateBuyingCoins:
				cell.joinState = JOINING;
				break;
			case kPNInternetMatchRoomUserStateJoining:
				cell.joinState = JOINED;
				break;
			default:
				break;
		}
		[cell setRoomMemberNum:[joinedUsers count] maxMemberNum:myRoom.maxMemberNum];
		
		if (myRoom.maxMemberNum <= [joinedUsers count]) {
			[cell.joinButton_ setEnabled:NO];
		}
		return cell;				
	}
	else {
		NSString *identifier =
		[NSString stringWithFormat:@"PNJoinedRoomCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNJoinedRoomCell *cell = (PNJoinedRoomCell *)[tableView dequeueReusableCellWithIdentifier:identifier];

		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = joinedRoomCell;
			self.joinedRoomCell = nil;		
		}
		
		int cellIndex = indexPath.row - 1;
		PNUser *user = [joinedUsers objectAtIndex:cellIndex];
		[cell setUserName:user.username];	// 頭文字とルームIDを取ります。
		[cell setFlagImageForCountryCode:user.countryCode];
		[cell setAchievementPoint:[NSString stringWithFormat:@"%d/%d", user.achievementPoint,user.achievementTotal]];
		
		if ([user.username isEqualToString:[PNUser currentUser].username]) {
			[cell setIcon:[UIImage imageNamed:@"PNDefaultSelfIcon.png"]];
		}
		else {
			[cell setIcon:[UIImage imageNamed:@"PNDefaultUserIcon.png"]];
		}
		
		[self setBackgroundImage:cell];
		[cell.headIcon loadImageOfUser:user];
		[cell setGradeEnabled:user.gradeEnabled];
		[cell setGradeName:user.gradeName];
		[cell setGradePoint:[NSString stringWithFormat:@"%d",user.gradePoint]];
		
		// 自分自身なら表示はしません。
		if ([[PNUser currentUser].username isEqualToString:user.username]) {
			[cell hideSignalImage];
		}
		else {
			NSString* speedLevel = [self.speedLevels objectForKey:user.username];
			[cell setSignalImageWithSpeedLevel:[speedLevel intValue]];
		}
		[cell setLayout:MATCH_CELL];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



#pragma mark User actions

- (BOOL)checkJoin {
	// ルームの人数はmaxだったらjoinしません。
	if (myRoom.maxMemberNum == [joinedUsers count]) {
		isReload = NO;
		[[PNManager sharedObject] setCanPush:YES];
		[PNDashboard popViewController];
		return NO;
	}
	return YES;
}

// 入室処理を行います。
- (void)join {
	// ルームメンバーのロードが完了していない、あるいは既にJOIN処理中だったら、なにもしません。
	if (roomMemberLoaded == NO || self.currentUserState == kPNInternetMatchRoomUserStateRequesting) {
		return;
	}
	
	isReload = NO;	// メンバーリストの自動更新を解除します。
	
	self.currentUserState = kPNInternetMatchRoomUserStateRequesting;	//ステートをジョイン処理中に設定します
	self.currentJoiningPhase = kPNInternetMatchRoomJoiningStartPairing;//ステートをペアリング開始にします。(セッターメソッド内でタイムアウト判定タイマーが生成されます)
	hasSomeErrorForJoining = NO;	// 前回入室しようとしたときに見つかったエラーを一度クリアします.
	myRoom.delegate = self;
//	[myRoom join];
	[PNManager roomManager].delegate = self;
	[[PNManager roomManager] joinInternetRoom:myRoom
									 delegate:self 
								  onSucceeded:@selector(joinSucceeded) 
									 onFailed:@selector(joinFailed:)];
	
	[self setNavigationItemsEnabled:NO];		// ナビゲーションバーを無効にします。
	[PNDashboard showLargeIndicator];			// 大きいインジケータを表示します。
	[PNDashboard disableAllButtons];
}

// 入室に成功したときに呼ばれます。
- (void)joinSucceeded
{
	NSLog(@"join succeeded");
}

// 入室に失敗したときに呼ばれます。
- (void)joinFailed:(PNError*)error
{
	self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Join failed.");
	if ([PNDashboard sharedObject].isDismissed || backToRoomsViewAfterLeaving) return;
	
	// 入室処理中にメンバーの変更があったことによる失敗の場合は、リトライします
	if (error.errorType == kPNRoomErrorFailedMemberChange) {
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Member has changed. Retry.");
		[self performSelector:@selector(join) withObject:nil afterDelay:3.0f];
		return;
	}
	
	if (error.errorType == kPNRoomErrorFailedNoCoins) {
		[PNAlertHelper showAlertForCoinPurchaseWithDelegate:self
												 onPurchase:@selector(purchaseCoins) 
												   onCancel:@selector(noPurchase)];
		return;
	}
	
	BOOL isNecessaryBack = NO;
	NSString* errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
	if (error.errorType == kPNStunPunchingRTTOverrange) {
		errorMessage = getTextFromTable(@"PNTEXT:UDP:FAIL:p2p:speed is late");
	}
	else if (error.errorType == kPNStunPunchingFailed || error.errorType == kPNStunPunchingTimeout) {
		errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:ERROR:UHP_error");
	}
	else if (error.errorType == kPNRoomErrorFailedAlreadyStarted) {
		errorMessage = getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num");
		isNecessaryBack = YES;
	}
	else if (error.errorType == kPNRoomErrorFailedAlreadyDeleted) {
		errorMessage = getTextFromTable(@"PNTEXT:ERROR:failed_remove_room.");
		isNecessaryBack = YES;
	}
	
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
										   message:errorMessage
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil
								  onCancelSelected:nil
										  delegate:self];
	
	[self setNavigationItemsEnabled:YES];	// ナビゲーションバーを再び有効にします。
	[PNDashboard resetAllButtons];
	
	if(isNecessaryBack) {
		[PNDashboard popViewController];
	}	
}

- (void)purchaseCoins {
	self.currentUserState = kPNInternetMatchRoomUserStateBuyingCoins;
	[PNDashboard showIndicator];
//	[[PNStoreManager sharedObject] purchaseDefaultCoinSetWithDelegate:self
//														  onSucceeded:@selector(purchaseSucceeded:) 
//															 onFailed:@selector(noPurchase)];
}

- (void)noPurchase {
	[PNDashboard popViewController];
}

- (void)purchaseSucceeded:(PNItemOwnershipModel*)item {
	[PNDashboard hideIndicator];
	[PNUser currentUser].coins = item.quantity;
	[PNDashboard updateDashboard];
	[self join];
}

#pragma mark -
/* delegate for backing to Rooms */
- (void)backToRooms {
	
	PNLogMethod(@"backToRooms");
	
	if (self.currentUserState == kPNInternetMatchRoomUserStateRequesting || [joinedUsers count] == myRoom.maxMemberNum) {
		// 入室処理中は退室できません。
		// 対戦人数に達した場合は退室できません。
		return;
	}
	else if (isJoin) {
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:BUTTON:Leave")
											   message:getTextFromTable(@"PNTEXT:UI:leave_info")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:@selector(onOKSelectedBackToRooms) 
									 cancelButtonTitle:getTextFromTable(@"PNTEXT:CANCEL")
									  onCancelSelected:@selector(onCancelSelectedBackToRooms)
											  delegate:self
											timerCount:0];
	}
	else {
		isReload = NO;
		[[PNManager sharedObject] setCanPush:YES];
		[PNDashboard popViewController];
	}
}

- (void)onOKSelectedBackToRooms
{	
	[self leave];
}

- (void)onCancelSelectedBackToRooms
{
	
}

- (void)backToRoomsAlertView:(UIAlertView *)alertView willDismissWithButtonIndex:(id)sender {
	NSInteger buttonIndex = [sender tag];
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"%s %x", __FUNCTION__, buttonIndex);
	if (buttonIndex == 1) {
		[self leave];
	}
}
#pragma mark -
- (void)invite {
	PNInviteFriendsViewController* controller = (PNInviteFriendsViewController*)[PNControllerLoader load:@"PNInviteFriendsViewController" filesOwner:nil];
	[PNDashboard pushViewController:controller];
}
#pragma mark -
- (void)leave {
	PNLogMethod(@"leave");
	//入室処理中は、退室できません。
	if (self.currentUserState == kPNInternetMatchRoomUserStateRequesting || [joinedUsers count] == myRoom.maxMemberNum) {
		PNWarn(@"can't leave while joining");
		return;
	}

	[self reloadStart];
	[PNDashboard showIndicator];
	[[PNManager roomManager] leaveInternetRoom:myRoom delegate:self 
								   onSucceeded:@selector(leaveSucceeded) 
									  onFailed:@selector(leaveFailed)];
}

- (void)forceToLeave {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Force to leave");
	[PNDashboard showIndicator];
	backToRoomsViewAfterLeaving = YES;
	[[PNManager roomManager] leaveInternetRoom:myRoom delegate:self 
								   onSucceeded:@selector(forceToLeaveSucceeded) 
									  onFailed:@selector(leaveFailed)];
}

- (void)leaveSucceeded {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"leaveSucceeded");
	myRoom.isJoined = NO;
	self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	[self resetRoomMembers];
	[PNDashboard resetAllButtons];
	[PNDashboard hideIndicator];
//	if (backToRoomsViewAfterLeaving){
//		PNLog(@"backToRoomsViewAfterLeaving is %s.",backToRoomsViewAfterLeaving ? "YES" : "NO");
		isReload = NO;
		[[PNManager sharedObject] setCanPush:YES];
		[PNDashboard popViewController];
//	}
}

- (void)forceToLeaveSucceeded {
	
	if (forceLeaveFlag == YES)
		return;
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"forceToLeaveOK.");
	myRoom.isJoined = NO;
	self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	[self resetRoomMembers];
	[PNDashboard resetAllButtons];
	[PNDashboard hideIndicator];
	isReload = NO;
	[[PNManager sharedObject] setCanPush:YES];
	[PNDashboard popViewController];
//	[[PNDashboard getWrappedNavigationController]  returnRootView];
//	[[PNDashboard sharedObject] showInternetMatchTopPage];
}

- (void)leaveFailed {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"leaveFailed.");
	myRoom.isJoined = NO;
	self.currentUserState = kPNInternetMatchRoomUserStateObserving;
	[self resetRoomMembers];
	[PNDashboard resetAllButtons];
	[PNDashboard hideIndicator];
		isReload = NO;
		[[PNManager sharedObject] setCanPush:YES];
		[PNDashboard popViewController];
}

#pragma mark GameSession Start/End
- (void)room:(PNRoom*)room willBeginGameSession:(PNGameSession*)gameSession {
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionWillBegin:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionWillBegin:gameSession];
	}	
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"willBeginGameSession\n");
	[PNDashboard showLargeIndicator];
	[PNDashboard updateIndicatorDescription:@"PNTEXT:MATCH:Match_will_start_soon"];
}

- (void)room:(PNRoom*)room didBeginGameSession:(PNGameSession*)gameSession {
	[PNDashboard hideIndicator];
	[[PNManager sharedObject] setCanPush:NO];
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidBegin:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidBegin:gameSession];
	}
	[PNDashboard hideIndicator];
	PNLogMethod(@"didBeginGameSession\n");
	
	if (![PNDashboard sharedObject].isDismissed) {
		[PankiaNet dismissDashboard];
	}
}

- (void)room:(PNRoom*)aRoom didRestartGameSession:(PNGameSession*)gameSession {
	[PNDashboard hideIndicator];
	
	if([PankiaNet sharedObject].pankiaNetDelegate != nil &&
	   [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidRestart:)]){
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidRestart:gameSession];
	}
	
	[PankiaNet dismissDashboard];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didRestartGameSession\n");
}

#pragma mark Rematch Process
- (void)didStartRematchProcessing {
	// ダッシュボードをここで開く
	NSArray* controllers = nil;
	if (myRoom.lobby != nil) {
		controllers = [NSArray arrayWithObjects:@"PNLobbyViewController", self, nil];
	}
	else {
		controllers = [NSArray arrayWithObjects:@"PNMatchUpViewController", self, nil];
	}
	[[PNDashboard sharedObject] launchWithPushControllers:controllers];
	self.isWaitingForRematch = YES;
	isJoin = YES;
	// ダッシュボードが開くのをまってから、インジケータを表示させます
	[self performSelector:@selector(showIndicatorBeforeVoting) withObject:nil afterDelay:0.5f];
	
}

- (void)showIndicatorBeforeVoting {
	[PNDashboard updateIndicatorDescription:@"PNTEXT:UI:Rematch:Waiting_for_other_players"];
	[PNDashboard showLargeIndicator];
}

// When finished rematch synchronous processing, call back this method.
-(void)synchronizationBeforeVotingDone {
	[PNDashboard hideIndicator];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"synchronizationBeforeVotingDone\n");
	
	// リマッチの投票を開始します
	// コインがあるときだけリマッチできます
	// begin - lerry modifed
	BOOL coinEnabled = [[PNGlobalManager sharedObject] coinsEnabled];
	if (coinEnabled == NO || (coinEnabled == YES && [PNUser currentUser].coins > 0)) {
		[[PNDashboard sharedObject] showAlertWithTitle:@"Rematch?" message:@"" 
										 okButtonTitle:@"YES" onOKSelected:@selector(rematchYes) 
									 cancelButtonTitle:@"NO" onCancelSelected:@selector(rematchNo) 
											  delegate:self timerCount:10];
	}
	else {
		[self performSelector:@selector(rematchNo) withObject:nil afterDelay:0.5];
	}
	// end - lerry modified
	[self.myRoom.gameSession checkRematchResult:10]; // 10秒後にチェックを行う。
}

- (void)rematchYes {
	[self.myRoom.gameSession postRematchMessage:YES];
}

- (void)rematchNo {
	[self.myRoom.gameSession postRematchMessage:NO];
}

- (void)receivedRequestMessage:(NSDictionary *)params {
	double aWaitTime = [[params objectForKey:@"wait"] doubleValue];
	NSString* reason = [params objectForKey:@"reason"];
	NSString* requestUser = [params objectForKey:@"user"];

	// 相手からのwaitメッセージに応じて待つカウンターを再セットする。
	// 再セットするだけでタイムアウトの秒数はリセットできます。
	[self.myRoom.gameSession checkRematchResult:aWaitTime]; 
	
	// 別のユーザがコイン購入中であれば、その旨を表示します
	if ([reason isEqualToString:kPNWaitReasonCoinPurchase] && ![requestUser isEqualToString:[PNUser currentUser].username]){
		[PNDashboard showLargeIndicator];
		[PNDashboard updateIndicatorDescription:@"PNTEXT:INTERNET_MATCH:REMATCH:Other_player_is_buying_coins."];
	}
}

// When finished result processing, call back this method.
// Member of the remainder. Element type is PNPeer.
- (void)decidedRematchResult:(NSArray*)memberArray {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"decidedRematchResult\n %@", memberArray);
	
	// リマッチしない選択をした場合は退室処理をします
	if (memberArray == nil) {
		[self forceToLeave];
		return;
	}
}

-(void)room:(PNRoom*)room didEndGameSession:(PNGameSession*)gameSession {
	
	[[PNManager sharedObject] setCanPush:YES];
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidEnd:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidEnd:gameSession];
	}
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didEndGameSession\n");
//	if (![PNDashboard sharedObject].isDismissed) {
//		[PankiaNet dismissDashboard];
//	}
//	
//	[PankiaNet launchDashboardWithInternetMatchView];
}





#pragma mark -
- (void)reloadThread {
	if (!isReload || isWaitingForRematch)
		return;
	
	// reload proccess..
	[self resetRoomMembers];
	[self performSelector:@selector(reloadThread) withObject:nil afterDelay:5];
}

// update room info.
- (void)reloadStart {
	isReload = YES;
	[self reloadThread];
}

// PNRoomDelegate
-(void)didLeaveRoom:(PNRoom *)room {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didLeaveRoom\n");
	[[PNManager sharedObject] setCanPush:YES];
	[[PNDashboard getWrappedNavigationController] popViewControllerAnimated:NO];
	[[PNDashboard getWrappedNavigationController] popViewControllerAnimated:YES];
}


// PNGameSessionDelegate
-(void)gameSession:(PNGameSession*)gameSession didConnectPeer:(PNPeer*)opponent {}
-(void)gameSession:(PNGameSession*)gameSession didDisconnectPeer:(PNPeer*)opponent {}
-(void)gameSession:(PNGameSession*)gameSession didReceiveData:(NSData*)data from:(PNPeer*)opponent {}
-(void)gameSession:(PNGameSession*)gameSession didSendError:(PNError*)error opponent:(PNPeer*)peer data:(NSData*)data {}
-(void)didGameSessionEnd:(PNGameSession *)gameSession {}

- (void)didFailToJoinWithTimeout {
	
	[myRoom cancelJoining];	// 入室処理をキャンセルします。
	self.isJoin = NO;
	self.currentJoiningPhase = kPNInternetMatchRoomJoiningNone;
	[PNDashboard hideIndicator];
	[self setNavigationItemsEnabled:YES];
	backToRoomsViewAfterLeaving = YES;
	[myRoom leave];
	
	isReload = NO;
	
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
										   message:getTextFromTable(@"PNTEXT:LOCALMATCH:connection_error")
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil onCancelSelected:nil
										  delegate:self];
	 
	[[PNManager sharedObject] setCanPush:YES];
	[PNDashboard popViewController];
	[PNDashboard showIndicator];
}

- (void)checkDoneJoining:(NSNumber*)aTransactionID {
	PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Join timeout check.");
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"checkDoneJoining");
	
	//既に入室が完了していればなにもしません
	if (self.isJoin == YES)
		return;
	
	if ([aTransactionID intValue] == self.transactionNumber) {
		PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"valid check.");
		self.transactionNumber++;
		
		// まだ入室処理中であればタイムアウトを発生させます。
		if (self.currentUserState == kPNInternetMatchRoomUserStateRequesting) {	
			[self didFailToJoinWithTimeout];
		}
	}
}

#pragma mark -
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
	self.myRoom					= nil;
	self.speedLevels			= nil;
	PNSafeDelete(joinedRoomEventCell_);
	PNSafeDelete(joinedRoomCell);
	PNSafeDelete(joinedUsers);
	PNSafeDelete(session);
	[super dealloc];
}

@end

