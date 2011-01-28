#import "PNMyLocalRoomViewController.h"
#import "PNLocalMatchViewController.h"
#import "PNControllerLoader.h"
#import "PNDashboard.h"
#import "PankiaNet+Package.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"
#import "PNGlobalManager.h"

@implementation PNMyLocalRoomViewController

@synthesize joinedLocalRoomCell;
@synthesize myRoomActionCell;
@synthesize hostName;
@synthesize roomName;
@synthesize localRoom;
@synthesize lobby;
@synthesize myRoomEventCell_;


- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// Configure the table view.
    self.tableView.separatorColor	= [UIColor cyanColor];
	joinedUsers						= [[NSMutableArray alloc] init]; // Do not autorelease!!
	
	// customize back navigation button
	UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] init] autorelease];
	backButton.title  = getTextFromTable(@"PNTEXT:BUTTON:Leave");
	backButton.target = self;
	backButton.action = @selector(backToRoom);
	
	[[PNManager sharedObject] setCanPush:NO];
	self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	PNRoomManager *roomManager = [PNManager sharedObject].roomManager;
	roomManager.delegate = self;
	
	PNWarn(@"Limited member of local match room. MIN:%d MAX:%d",
		  [[PNSettingManager sharedObject] nearbyMatchMinRoomMember],
		  [[PNSettingManager sharedObject] nearbyMatchMaxRoomMember]);
	[roomManager createLocalRoomWithMinMemberNum:[[PNSettingManager sharedObject] nearbyMatchMinRoomMember]
									maxMemberNum:[[PNSettingManager sharedObject] nearbyMatchMaxRoomMember]
										roomName:roomName lobby:lobby delegate:self];
	isLeave = NO;
	[PNDashboard disableAllButtons];
	
	// この画面ではスリープしないようにする。
	[UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	isLeave = NO;
	PNLogMethod(@"viewDidDisappear");
	if (![PNDashboard sharedObject].isDismissed) {
		[self leaveLocalRoom];
	}
	// スリープ解除
	[UIApplication sharedApplication].idleTimerDisabled = [PNGlobalManager sharedObject].originalIdleTimerDisabled;
}

- (void)backToRoom {
	if ([[PNDashboard getWrappedNavigationController] isIndicatorAnimating]) return;
	
	isLeave = YES;
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:BUTTON:Leave")
										   message:getTextFromTable(@"PNTEXT:UI:leave_info")
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelectedLeave) 
								 cancelButtonTitle:getTextFromTable(@"PNTEXT:CANCEL")
								  onCancelSelected:@selector(onCancelSelected)
										  delegate:self];
}

- (void)onOKSelected {
}	

- (void)onOKSelectedLeave {
	
	[PNDashboard resetAllButtons];
	[[PNManager sharedObject] setCanPush:YES];
	[[PNDashboard getWrappedNavigationController] popViewControllerAnimated:NO];
	[[PNDashboard getWrappedNavigationController] popViewControllerAnimated:YES];
}

- (void)onCancelSelected {
	
}

- (void)leaveLocalRoom {
	[localRoom leave];
}

///////////
// PNRoomManagerDelegate.
//server 
- (void)didCreateRoom:(PNRoom*)room requestId:(int)requestId {
	self.localRoom = (PNLocalRoom*)room;
	self.localRoom.delegate = self;
	self.title = localRoom.roomId;
	[self reloadData];
	PNLog(@"didCreateRoom\n");

	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Create_Local_Room")
										   message:getTextFromTable(@"PNTEXT:UI:Create_local_room_completion.")
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil
								  onCancelSelected:nil
										  delegate:self];
}


///////////
// PNRoomDelegate.
-(void)roomDidJoin:(PNRoom*)room
{
	PNLog(@"roomDidJoin\n");
}

-(void)room:(PNRoom*)room didFailJoinWithError:(PNNetworkError*)error
{
	PNLog(@"didFailJoinWithError\n");
}

-(void)roomDidLeave:(PNRoom*)room
{
	PNLog(@"roomDidLeave\n");
}

-(void)room:(PNRoom*)room didJoinUser:(PNUser*)user
{
	PNLog(@"didJoinUser\n");
}

-(void)room:(PNRoom*)room didLeaveUser:(PNUser*)user
{
	PNLog(@"didLeaveUser\n");
}

-(void)room:(PNRoom*)room didUpdateJoinedUsers:(NSArray*)users
{
	[joinedUsers removeAllObjects];
	for(PNUser* user in users) {
		[joinedUsers addObject:user];
	}
	
	PNLog(@"Counter : %d",[joinedUsers count]);
	
	PNLog(@"%@", NSStringFromClass([self.tableView class]));

	[self reloadData];
}

-(void)room:(PNRoom*)room willBeginGameSession:(PNGameSession*)gameSession
{
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionWillBegin:)]) {
		[PNDashboard showLargeIndicator];
		[PNDashboard updateIndicatorDescription:@"PNTEXT:MATCH:Match_will_start_soon"];
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionWillBegin:gameSession];		
	}
	PNLog(@"willBeginGameSession\n");
}

-(void)room:(PNRoom*)room didBeginGameSession:(PNGameSession*)gameSession
{
	
	[[PNManager sharedObject] setCanPush:NO];
	if([PankiaNet sharedObject].pankiaNetDelegate != nil 
	   && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidBegin:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidBegin:gameSession];
	}
	[PankiaNet dismissDashboard];
	PNLog(@"didBeginGameSession\n");
	
}

-(void)room:(PNRoom*)room didRestartGameSession:(PNGameSession*)gameSession
{
	[[PNManager sharedObject] setCanPush:NO];
	if([PankiaNet sharedObject].pankiaNetDelegate != nil
	   && [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidRestart:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidRestart:gameSession];
	}
	[PankiaNet dismissDashboard];
	PNLog(@"didBeginGameSession\n");
	
}

-(void)room:(PNRoom*)room didEndGameSession:(PNGameSession*)gameSession
{
	[[PNManager sharedObject] setCanPush:YES];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil
		&& [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidEnd:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidEnd:gameSession];
	}
	PNLog(@"didEndGameSession\n");
	//[PankiaNet launchDashboardWithNearbyMatchView];
	[PNDashboard popViewController];
}

-(void)room:(PNRoom*)room didFailWithError:(PNNetworkError*)error
{	
	if ([PNDashboard sharedObject].isDismissed) return;
	
	[[PNManager sharedObject] setCanPush:YES];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil
		&& [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidFailWithError:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidFailWithError:error];
	}
	
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didFailWithError\n");
	
	// try to leave the room, nevertheless it will fail
	if ( room != nil ) {
		[room leave];
		[room.gameSession disconnect];
	}
	
	NSString *errorMessage = getTextFromTable(@"PNTEXT:LOCALMATCH:connection_error");
	if (error.errorType == kPNRoomErrorFailedSync)
		errorMessage = getTextFromTable(@"PNTEXT:MATCH:Synchronous_fail.");
	if ([room.gameSession isStarted]) {
		//すでに開始されている場合はアラートをださない
		return;
	}
	[[PNManager sharedObject] setCanPush:YES];
	[PNDashboard popViewController];
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Nearby_Match")
										   message:errorMessage
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil onCancelSelected:nil
										  delegate:self];
}

-(void)start
{
	[(PNLocalRoom*)localRoom startNotifying];
	PNLog(@"Notify\n");
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark Table view methods

// セクションの数は必ず1に設定しておいて下さい。
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [joinedUsers count] + 1;	// EventCell部分をひとつ追加します。
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	if (0 <= indexPath.row && indexPath.row <= ([joinedUsers count] - 1)) {
		return 50.0f;
	}
	else {
		return 40.0f;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
		NSString* CellIdentifier = [NSString stringWithFormat:@"PNMyLocalRoomActionCell%@",
									([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNMyLocalRoomActionCell *cell = (PNMyLocalRoomActionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:CellIdentifier
										  owner:self
										options:nil];
			cell = myRoomActionCell;
			self.myRoomActionCell = nil;		
		}
		[cell setUserName:[PNUser currentUser].username];

		// ユーザが自分でなおかつオフラインの時はローカルの情報を元に計算します。
		if ([PNManager sharedObject].isLoggedIn == NO) {
			[cell setAchievementPoint:[NSString stringWithFormat:@"%d/%d",
									   [[PNLocalAchievementDB sharedObject] unlockedPointsOfUser:[PNUser currentUserId]],
									   [[PNAchievementManager sharedObject] totalPoints]]];
		}
		// オンラインの時はサーバーの情報を元に計算します。
		else if ([PNManager sharedObject].isLoggedIn == YES) {
			[cell setAchievementPoint:[NSString stringWithFormat:@"%d/%d",
									   [PNUser currentUser].achievementPoint,
									   [PNUser currentUser].achievementTotal]];
		}
				
		[cell setGradeEnabled:[PNUser currentUser].gradeEnabled];
		[cell setGradeName:[PNUser currentUser].gradeName];
		[cell setGradePoint:[NSString stringWithFormat:@"%d",[PNUser currentUser].gradePoint]];
		
		if ([[PNManager sharedObject] loggedinOnce]) {
			[cell setFlagImageForCountryCode:[PNUser currentUser].countryCode];
		}
		else {
			[cell setHiddenFlagImage:YES];
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		[cell setIcon:[UIImage imageNamed:@"PNDefaultSelfIcon.png"]];
		[cell.headIcon loadImageWithUrl:[PNUser currentUser].iconURL];
		[cell setLayout:MATCH_CELL];
		[self setBackgroundImage:cell];
		
		return cell;
	}
	else if (indexPath.row == [joinedUsers count]) {
		NSString* identifier =
		[NSString stringWithFormat:@"PNMyLocalRoomEventCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNMyLocalRoomEventCell* cell = (PNMyLocalRoomEventCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = myRoomEventCell_;
			self.myRoomEventCell_ = nil;
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		cell.selectionStyle	= UITableViewCellSelectionStyleNone;
		cell.backgroundView =
		[[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNCellInfoBackgroundImage]] autorelease];
		cell.delegate = self;
		
		if (((PNLocalRoom*)localRoom).isReady) {
			[cell enableStartLocalMatchButton];
		}
		else {
			[cell disableStartLocalMatchButton];
		}
		return cell;
	}	
	else {
		NSString* CellIdentifier = [NSString stringWithFormat:@"PNJoinedLocalRoomCell%@",
									([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNJoinedLocalRoomCell* cell = (PNJoinedLocalRoomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
			cell = joinedLocalRoomCell;
			self.joinedLocalRoomCell = nil;		
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

		PNUser *user = [joinedUsers objectAtIndex:indexPath.row];
		[cell setUserName:user.username];	// 頭文字とルームIDを取ります。
		[cell setAchievementPoint:[NSString stringWithFormat:@"%d/%d", user.achievementPoint, user.achievementTotal]];
		[cell setGradeEnabled:user.gradeEnabled];
		[cell setGradeName:user.gradeName];
		[cell setGradePoint:[NSString stringWithFormat:@"%d",user.gradePoint]];
		[cell setIcon:[UIImage imageNamed:@"PNDefaultUserIcon.png"]];
		[cell.headIcon loadImageWithUrl:user.iconURL];
		
		if ([user.countryCode isEqualToString:kPNCountryCodeDefault]) {
			[cell setHiddenFlagImage:YES];
		}
		else {
			[cell setFlagImageForCountryCode:user.countryCode];
		}
		[self setBackgroundImage:cell];
		[cell setLayout:MATCH_CELL];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)dealloc {
	self.hostName	= nil;
	self.roomName	= nil;
	self.localRoom	= nil;
	PNSafeDelete(joinedLocalRoomCell);
	PNSafeDelete(myRoomActionCell);
	PNSafeDelete(myRoomEventCell_);
	PNSafeDelete(joinedUsers);
	[super dealloc];
}

@end

