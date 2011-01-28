#import "PNJoinedLocalRoomViewController.h"
#import "PNJoinedLocalRoomCell.h"
#import "PNGameSession.h"
#import "PNUser.h"
#import "PNManager.h"
#import "PNRoomManager.h"
#import "PNLocalMatchViewController.h"
 
#import "PNControllerLoader.h"
#import "PNDashboard.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PankiaNet+Package.h"
#import "PNGlobal.h"
#import "PNGlobalManager.h"



@implementation PNJoinedLocalRoomViewController

@synthesize joinedLocalRoomEventCell_;
@synthesize joinedLocalRoomCell;
@synthesize localRoom;
@synthesize joinedUsers;
@synthesize backButton;


- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	isFlag_ = NO;
	
	// Configure the table view.
	self.tableView.separatorColor = [UIColor cyanColor];
	self.joinedUsers = [NSMutableArray array];
	
	// customize back navigation button
	UIBarButtonItem *leaveButton = [[[UIBarButtonItem alloc] init] autorelease];
	leaveButton.title  = getTextFromTable(@"PNTEXT:BUTTON:Leave");
	leaveButton.target = self;
	leaveButton.action = @selector(backToRoom);
	
	[[PNManager sharedObject] setCanPush:NO];
	self.navigationItem.leftBarButtonItem = leaveButton;
	[self reloadData];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if (![PNDashboard sharedObject].isDismissed) {
		[localRoom leave];
	}
	[PNDashboard showIndicator];
	
	// 閉じるときはスリープを有効化。
	[UIApplication sharedApplication].idleTimerDisabled = [PNGlobalManager sharedObject].originalIdleTimerDisabled;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [super viewDidLoad];
	
	[PNDashboard disableAllButtons];
	
	if(!kPNSelectionOfTheLocalRoomUse) {
		[PNDashboard showIndicator];
	}
	// この画面ではスリープを無効化します。
	[UIApplication sharedApplication].idleTimerDisabled = YES;
}

//ローカルメニュー画面に戻る
- (void)backToRoom {
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:BUTTON:Leave")
										   message:getTextFromTable(@"PNTEXT:UI:leave_info")
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:getTextFromTable(@"PNTEXT:CANCEL")
								  onCancelSelected:@selector(onCancelSelected) 
										  delegate:self];
}

- (void)onOKSelected {
	[PNDashboard resetAllButtons];
	[[PNManager sharedObject] setCanPush:YES];
	[PNDashboard popViewController];
}

- (void)onCancelSelected {
	
}



#pragma mark -
#pragma mark PNRoomManagerDelegate

- (void)didFindActiveRooms:(NSArray*)rooms requestId:(int)requestId {
	for(PNRoom* room in rooms) {
		room.delegate = self;
		[room join];
	}
}


#pragma mark -
#pragma mark PNRoomDelegate

- (void)roomDidJoin:(PNRoom*)room {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"roomDidJoin\n");
}

- (void)room:(PNRoom*)room didFailJoinWithError:(PNNetworkError*)error {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didFailJoinWithError\n");
	
	[PNDashboard hideIndicator];
	[PNDashboard resetAllButtons];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidFailWithError:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidFailWithError:error];
	}

	[PNDashboard popViewController];
	
	if ([room.gameSession isStarted]) {
		//すでに開始されている場合はアラートをださない
		return;
	}
	
	[[PNManager sharedObject] setCanPush:YES];
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Nearby_Match")
										   message:getTextFromTable(@"PNTEXT:LOCALMATCH:connection_error")
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil
								  onCancelSelected:nil
										  delegate:self];
}

- (void)room:(PNRoom*)room didFailWithError:(PNNetworkError*)error {
	
	if ([PNDashboard sharedObject].isDismissed) return;
	
	[PNDashboard hideIndicator];
	[PNDashboard resetAllButtons];
	[[PNManager sharedObject] setCanPush:YES];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidFailWithError:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidFailWithError:error];
	}
	
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didFailWithError\n");
	
	// try to leave the room, nevertheless it will fail
	if (room != nil) {
		[room leave];
		[room.gameSession disconnect];
	}
	
	NSString *errorMessage = getTextFromTable(@"PNTEXT:LOCALMATCH:connection_error");
	if (error.errorType == kPNRoomErrorFailedSync)
		errorMessage = getTextFromTable(@"PNTEXT:MATCH:Synchronous_fail.");
	[PNDashboard popViewController];
	
	if ([room.gameSession isStarted]) {
		//すでに開始されている場合はアラートをださない
		return;
	}

	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Nearby_Match")
										   message:errorMessage
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
									  onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil
								  onCancelSelected:nil
										  delegate:self];
}

- (void)roomDidLeave:(PNRoom*)room {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"roomDidLeave\n");
	[[PNManager sharedObject] setCanPush:YES];
	[PNDashboard popViewController];
}

- (void)room:(PNRoom*)room didJoinUser:(PNUser*)user {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didJoinUser\n");
}

- (void)room:(PNRoom*)room didLeaveUser:(PNUser*)user {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didLeaveUser\n");
}

- (void)room:(PNRoom*)room didUpdateJoinedUsers:(NSArray*)users {
	[joinedUsers removeAllObjects];
	
	for (PNUser* user in users) {
		[joinedUsers addObject:user];
		PNCLog(PNLOG_CAT_LOCALMATCH, @"User : %@",user.username);
	}
	
	if([users count]) {
		[PNDashboard hideIndicator];
	}
	else {
		[PNDashboard showIndicator];
	}

	self.title = localRoom.roomName;
	[self reloadData];
	isFlag_ = YES;
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didUpdateJoinedUser\n");
}

- (void)room:(PNRoom*)room willBeginGameSession:(PNGameSession*)gameSession {
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionWillBegin:)]) {
		[PNDashboard showLargeIndicator];
		[PNDashboard updateIndicatorDescription:@"PNTEXT:MATCH:Match_will_start_soon"];
		backButton.enabled = NO;
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionWillBegin:gameSession];
	}	
	PNCLog(PNLOG_CAT_LOCALMATCH, @"willBeginGameSession\n");
}

- (void)room:(PNRoom*)room didBeginGameSession:(PNGameSession*)gameSession {
	
	[[PNManager sharedObject] setCanPush:NO];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidBegin:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidBegin:gameSession];
	}
	
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didBeginGameSession\n");
	[PankiaNet dismissDashboard];
	[PNDashboard hideIndicator];
	backButton.enabled = YES;
}

- (void)room:(PNRoom*)aRoom didRestartGameSession:(PNGameSession*)gameSession {
	
	[[PNManager sharedObject] setCanPush:NO];
	
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
	   [[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidRestart:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidRestart:gameSession];
	}
	
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didRestartGameSession\n");
	[PankiaNet dismissDashboard];
	[PNDashboard hideIndicator];
	backButton.enabled = YES;
}


- (void)room:(PNRoom*)room didEndGameSession:(PNGameSession*)gameSession {
	
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didEndGameSession\n");
	[[PNManager sharedObject] setCanPush:YES];
	if ([PankiaNet sharedObject].pankiaNetDelegate != nil &&
		[[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(gameSessionDidEnd:)]) {
		[[PankiaNet sharedObject].pankiaNetDelegate gameSessionDidEnd:gameSession];
	}
	//[PankiaNet launchDashboardWithNearbyMatchView];
	[PNDashboard popViewController];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	PNCLog(PNLOG_CAT_LOCALMATCH, @"View did unload!");
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [joinedUsers count] + 1;	// EventCell部分をひとつ追加します。
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (0 <= indexPath.row && indexPath.row <= [joinedUsers count] - 1) {
		return 50.0f;
	}
	else {
		return 40.0f;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row  == [joinedUsers count]) {
		NSString* identifier =
		[NSString stringWithFormat:@"PNJoinedLocalRoomEventCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNJoinedLocalRoomEventCell* cell = (PNJoinedLocalRoomEventCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
		
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = joinedLocalRoomEventCell_;
			self.joinedLocalRoomEventCell_ = nil;
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		cell.backgroundView =
		[[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNCellInfoBackgroundImage]] autorelease];
		
		if (isFlag_) {
			[cell showNotHostText];
		}
		else {
			[cell hideNotHostText];
		}
		return cell;
	}
	else {
		NSString* identifier = [NSString stringWithFormat:@"PNJoinedLocalRoomCell%@",
									([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNJoinedLocalRoomCell *cell = (PNJoinedLocalRoomCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
		
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = joinedLocalRoomCell;
			self.joinedLocalRoomCell = nil;		
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		
		// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
		cell.useDarkBackground = (indexPath.row % 2 == 0);
		PNUser *user = [joinedUsers objectAtIndex:indexPath.row];
		
		[cell setUserName:user.username];	// 頭文字とルームIDを取ります。	
		if ([user.username isEqualToString:[PNUser currentUser].username]) {
			[cell setIcon:[UIImage imageNamed:@"PNDefaultSelfIcon.png"]];
		}
		else {
			[cell setIcon:[UIImage imageNamed:@"PNDefaultUserIcon.png"]];
		}
		[cell.headIcon loadImageWithUrl:user.iconURL];
		
		if ([user.username isEqualToString:[PNUser currentUser].username]) {
			if ([[PNManager sharedObject] loggedinOnce]) {
				[cell setFlagImageForCountryCode:user.countryCode];
			}
			else {
				[cell setHiddenFlagImage:YES];
			}
		}
		else {
			[cell setFlagImageForCountryCode:user.countryCode];
		}
		[self setBackgroundImage:cell];
		[cell setAchievementPoint:[NSString stringWithFormat:@"%d/%d",user.achievementPoint, user.achievementTotal]];
		[cell setGradeEnabled:user.gradeEnabled];
		[cell setGradeName:user.gradeName];	
		[cell setGradePoint:[NSString stringWithFormat:@"%d",user.gradePoint]];
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

-(void)didLeaveRoom:(PNRoom *)room  {
	// Nothing to do.
}

- (void)dealloc {
	self.localRoom	= nil;
	PNSafeDelete(joinedLocalRoomEventCell_);
	PNSafeDelete(joinedLocalRoomCell);
	PNSafeDelete(joinedUsers);
	[super dealloc];
}

@end

