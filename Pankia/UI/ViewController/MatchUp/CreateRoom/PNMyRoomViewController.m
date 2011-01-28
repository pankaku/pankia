#import "PNMyRoomViewController.h"
#import "PNGameSession.h"
#import "PNUser.h"
#import "PNManager.h"
#import "PNInviteFriendsViewController.h"
#import "PNControllerLoader.h"
#import "PNDashboard.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PankiaNet+Package.h"
#import "PNGlobal.h"
#import "PNLobby.h"
 
#import "PNStoreManager.h"
#import "PNAlertHelper.h"
#import "PNGlobalManager.h"
#import "PNItemOwnershipModel.h"


@interface PNMyRoomViewController (Private)
- (void)createARoom;
@end

@implementation PNMyRoomViewController

@synthesize joinedRoomCell;
@synthesize myRoomEventCell_;
@synthesize headerCell_;
@synthesize leaveButton_;
@synthesize hostName;
@synthesize roomName;
@synthesize myRoom;
@synthesize maxMemberNum;
@synthesize gradeFilter;
@synthesize isPublish;
@synthesize isCreateRoom;
@synthesize speedLevels;
@synthesize joinedUsers;
@synthesize lobby;


- (void)awakeFromNib {
	[super awakeFromNib];
	self.isCreateRoom = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self.navigationItem setHidesBackButton:YES];	// UINavigationItem -> setHidesBackButton:animated:表示のON/OFFを指定
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (self.isCreateRoom) {
		[self createARoom];
	} else {
		[PNDashboard hideIndicator];
		[PNDashboard disableAllButtons];
	}

	// この画面ではスリープを無効化。
	[UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)createARoom {
	[PNDashboard showIndicator];
	[PNDashboard disableAllButtons];
	
	[self resetRoomData];
	PNRoomManager*	roomManager = [PNManager sharedObject].roomManager;
	roomManager.delegate = self;
	int lobbyId = (lobby != nil) ? lobby.lobbyId : -1;
	[roomManager createRoomWithMemberNumAndGrade:maxMemberNum 
									 publishFlag:isPublish 
										roomName:roomName 
									  gradeRange:self.gradeFilter
										 lobbyId:lobbyId
									roomDelegate:self];
	
	self.isCreateRoom = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	// この画面ではスリープを有効化。
	[UIApplication sharedApplication].idleTimerDisabled = [PNGlobalManager sharedObject].originalIdleTimerDisabled;
}

-(void)resetRoomData {
	if (lobby) {
		if(myRoom) {
			self.title = [NSString stringWithFormat:@"%@ / %@", myRoom.roomName, lobby.name];
		}
		else {
			self.title = [NSString stringWithFormat:@"%@",lobby.name];
		}
	}
	else {
		self.title = myRoom.roomName;
	}
	enableInvite = YES;
	joinedUsers = [[NSMutableArray alloc] init]; // Do not autorelease! this variable is private member variable.	
	showedAlert = NO;
}

// delegate for backing to CreateRoom
- (void)backToCreateRoom {
	if ([[PNDashboard getWrappedNavigationController] isIndicatorAnimating]) return;
	
	PNCLog(PNLOG_CAT_ACHIEVEMENT, @"%s called", __FUNCTION__);

	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:BUTTON:Leave")
										   message:getTextFromTable(@"PNTEXT:UI:leave_info")
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelectedBack) 
								 cancelButtonTitle:getTextFromTable(@"PNTEXT:CANCEL")
								  onCancelSelected:@selector(onCancelSelectedBack)
										  delegate:self];
}

- (void)onOKSelectedBack {
	[PNDashboard showIndicator];
	[self leaveRoom];
}

- (void)onCancelSelectedBack {
	
}

-(void)leaveRoom {
	[myRoom leave];
	[PNDashboard resetAllButtons];	
	if (myRoom) {
		self.myRoom = nil;
	}
}

///////////
// PNRoomManagerDelegate.

//server
- (void)didCreateRoom:(PNRoom*)room requestId:(int)requestId {
	self.myRoom = room;
	self.myRoom.lobby = lobby;
	self.myRoom.delegate = self;
	
	self.title = myRoom.roomName;
	
	[self reloadData];
	PNLog(@"didCreateRoom   PNMyRoomTableViewController");

	[PNDashboard hideIndicator];
	[PNDashboard disableAllButtons];
}

- (void)didFailToCreateARoomWithError:(PNError *)error {
	if (error.errorType == kPNRoomErrorFailedNoCoins) {
		[PNAlertHelper showAlertForCoinPurchaseWithDelegate:self
												 onPurchase:@selector(purchaseCoins) 
												   onCancel:@selector(noPurchase)];
	}
}

- (void)purchaseCoins {
//	[[PNStoreManager sharedObject] purchaseDefaultCoinSetWithDelegate:self
//														  onSucceeded:@selector(purchaseSucceeded:) 
//															 onFailed:@selector(noPurchase)];
}

- (void)noPurchase {
	[PNDashboard hideIndicator];
	[PNDashboard popViewController];
}

- (void)purchaseSucceeded:(PNItemOwnershipModel*)item {
	[PNUser currentUser].coins = item.quantity;
	[PNDashboard updateDashboard];
	[self performSelector:@selector(createARoom) withObject:nil afterDelay:1.0f];
}

//client
-(void)didFindActiveRoom:(PNRoom*)room requestId:(int)requestId {
	PNLog(@"didFindActiveRoom\n");
}


///////////
// PNRoomDelegate.
-(void)roomDidJoin:(PNRoom*)room {
	PNLog(@"roomDidJoin\n");
}

-(void)room:(PNRoom*)room didFailJoinWithError:(PNNetworkError*)error {
	PNLog(@"didFailJoinWithError\n");
}

-(void)roomDidLeave:(PNRoom*)room {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"roomDidLeave\n");
}

-(void)room:(PNRoom*)room didJoinUser:(PNUser*)user {
	PNLog(@"didJoinUser\n");
}

-(void)room:(PNRoom*)room didLeaveUser:(PNUser*)user {
}

-(void)didLeaveRoom:(PNRoom *)room
{
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didLeaveRoom\n");
	[[PNManager sharedObject] setCanPush:YES];
	[[PNDashboard getWrappedNavigationController] popViewControllerAnimated:NO];
	[[PNDashboard getWrappedNavigationController] popViewControllerAnimated:YES];
}

-(void)room:(PNRoom*)room didUpdateJoinedUsers:(NSArray*)users {
	self.joinedUsers = [NSMutableArray arrayWithArray:[room.peers allValues]];
	int memberCount = room.joinCount;
	if (memberCount == room.maxMemberNum ) {
		enableInvite = NO;
	}	
	
	[self reloadData];

	[PNDashboard hideIndicator];

	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didUpdateJoinedUser\n");
}


-(void)room:(PNRoom*)room willBeginGameSession:(PNGameSession*)gameSession {
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionWillBegin:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionWillBegin:gameSession];
	}
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"willBeginGameSession\n");
	[PNDashboard showLargeIndicator];
	[PNDashboard updateIndicatorDescription:@"PNTEXT:MATCH:Match_will_start_soon"];

}

-(void)room:(PNRoom*)room didBeginGameSession:(PNGameSession*)gameSession {
	[PNDashboard hideIndicator];

	if([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidBegin:)]){
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidBegin:gameSession];
	}
	
	[PankiaNet dismissDashboard];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didBeginGameSession\n");
}

-(void)room:(PNRoom*)aRoom didRestartGameSession:(PNGameSession*)gameSession {
	[PNDashboard hideIndicator];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidRestart:)]){
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidRestart:gameSession];
	}
	
	[PankiaNet dismissDashboard];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didRestartGameSession\n");
}



#pragma mark Rematch Process 

-(void)didStartRematchProcessing {
	// ダッシュボードをここで開く
	NSArray* controllers = nil;
	if (myRoom.lobby != nil) {
		controllers = [NSArray arrayWithObjects:@"PNLobbyViewController", self, nil];
	} else {
		controllers = [NSArray arrayWithObjects:@"PNMatchUpViewController", self, nil];
	}
	[[PNDashboard sharedObject] launchWithPushControllers:controllers];
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
	// begin - lerry modified
	BOOL coinEnabled = [[PNGlobalManager sharedObject] coinsEnabled];
	if (coinEnabled == NO || (coinEnabled == YES && [PNUser currentUser].coins > 0)) {
		// if coin feature is not enabled, or if coin feature is enabled and the user has coin, ask for rematch voting
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
// Member of the remainder. Element type is PNPeer* 
- (void)decidedRematchResult:(NSArray*)memberArray {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"decidedRematchResult\n");
	
	// リマッチしない選択をした場合は退室処理をします
	if (memberArray == nil) {
		[self leaveRoom];
		return;
	}
}

- (void)room:(PNRoom*)room didEndGameSession:(PNGameSession*)gameSession {
	[[PNManager sharedObject] setCanPush:YES];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil && 
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidEnd:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidEnd:gameSession];
	}
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"didEndGameSession\n");
	//[PankiaNet launchDashboardWithInternetMatchView];
}

- (void)room:(PNRoom*)room didFailWithError:(PNNetworkError*)error {
	
	[[PNManager sharedObject] setCanPush:YES];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidFailWithError:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidFailWithError:error];
	}
	
	if (error.errorType == kPNRoomErrorFailedSync){
		//インターネットマッチのタイトル画面に移動します
		[[PNDashboard getWrappedNavigationController] returnRootView];
		[[PNDashboard getWrappedNavigationController] pushViewController:[PNControllerLoader load:@"PNMatchUpViewController" filesOwner:nil] animated:YES];
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:MATCH:Synchronous_fail.")
											   message:error.message
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:@selector(onOKSelectedBack) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}	
	[PNDashboard showErrorView:self withErrorMessage:error.message];
}

- (void)start {
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



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [joinedUsers count] + 2; // HeaderとEventCell部分を追加する。
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
		[NSString stringWithFormat:@"PNMyRoomHeaderCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
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
		[cell setMyCoin];
		return cell;
	}
	else if (indexPath.row == ([joinedUsers count] + 1))  {
		NSString* identifier =
		[NSString stringWithFormat:@"PNMyRoomEventCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNMyRoomEventCell* cell = (PNMyRoomEventCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = myRoomEventCell_;
			self.myRoomEventCell_ = nil;
		}
		cell.delegate = self;
		cell.selectionStyle	= UITableViewCellSelectionStyleNone;
		[self setBackgroundImage:cell];
		[cell setRoomMemberNum:[joinedUsers count] maxMemberNum:myRoom.maxMemberNum];

		if (myRoom.maxMemberNum <= [joinedUsers count]) {
			[cell.inviteButton_ setEnabled:NO];
		}		
		
		return cell;		
	}
	else {
		NSString* identifier =
		[NSString stringWithFormat:@"PNJoinedRoomCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNJoinedRoomCell* cell = (PNJoinedRoomCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
		
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
			cell = joinedRoomCell;
			self.joinedRoomCell = nil;
		}
		
		int rowIndex = indexPath.row - 1;
		PNPeer *peer = [joinedUsers objectAtIndex:rowIndex];
		PNUser *user = peer.user;
		
		[self setBackgroundImage:cell];
		[cell setUserName:user.username];	// 頭文字とルームIDを取ります。
		[cell setFlagImageForCountryCode:user.countryCode];
		[cell setAchievementPoint:[NSString stringWithFormat:@"%d/%d",user.achievementPoint,user.achievementTotal]];
		[cell setIcon:[UIImage imageNamed:@"PNDefaultUserIcon.png"]];
		
		[cell.headIcon loadImageOfUser:user];

		NSString* gradeName = user.gradeName;
		[cell setGradeEnabled:user.gradeEnabled];
		[cell setGradeName:gradeName];
		[cell setGradePoint:[NSString stringWithFormat:@"%d", user.gradePoint]];
		
		// セルのユーザーが自分自身だった場合
		if ([[PNUser currentUser].username isEqualToString:user.username]) {
			[cell hideSignalImage];
			[cell.contentView addSubview:[self setLeaveButton:cell]];
		}
		else {
			[cell setSignalImageWithSpeedLevel:peer.speedLevel];
			[self hideLeaveButton];
		}
		[cell setLayout:MATCH_CELL];

		return cell;
	}
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UIButton*)setLeaveButton:(const UITableViewCell *)cell {
	UIButton* leaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leaveButton.frame = CGRectMake(370.0f, 7.0f, 90.0f, 36.0f);
	leaveButton.titleLabel.font = [UIFont fontWithName:kPNDefaultFontName size:11.0f];
	[leaveButton setTitle:getTextFromTable(@"PNTEXT:BUTTON:Leave") forState:UIControlStateNormal];
	
	UIImage* backgroundImage = [UIImage imageNamed:@"PNNegativeButton.png"];
	[leaveButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	[leaveButton addTarget:self
					action:@selector(backToCreateRoom)
		  forControlEvents:UIControlEventTouchUpInside];
	
	leaveButton_ = leaveButton;
	return leaveButton;
}

- (void)hideLeaveButton {
	[leaveButton_ setHidden:YES];
}

- (void)invite {
	if ([[PNDashboard getWrappedNavigationController] isIndicatorAnimating]) return;
	
	PNInviteFriendsViewController* controller =
	(PNInviteFriendsViewController*)[PNControllerLoader load:@"PNInviteFriendsViewController"
												  filesOwner:nil];
	[PNDashboard pushViewController:controller];
}

// PNGameSessionDelegate
- (void)gameSession:(PNGameSession*)gameSession didConnectPeer:(PNPeer*)opponent {}
- (void)gameSession:(PNGameSession*)gameSession didDisconnectPeer:(PNPeer*)opponent {}
- (void)gameSession:(PNGameSession*)gameSession didReceiveData:(NSData*)data from:(PNPeer*)opponent {}
- (void)gameSession:(PNGameSession*)gameSession didSendError:(PNError*)error opponent:(PNPeer*)peer data:(NSData*)data {}
- (void)didGameSessionEnd:(PNGameSession *)gameSession{}

- (void)dealloc {
	self.myRoomEventCell_		= nil;
	self.headerCell_			= nil;
	self.leaveButton_			= nil;
	self.joinedRoomCell			= nil;
	self.hostName				= nil;
	self.roomName				= nil;
	self.myRoom					= nil;
	self.gradeFilter			= nil;
	self.joinedUsers			= nil;
	PNSafeDelete(speedLevels);
	[super dealloc];
}

@end

