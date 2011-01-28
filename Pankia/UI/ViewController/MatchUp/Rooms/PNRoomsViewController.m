#import "PNRoomsViewController.h"
#import "PNCreateRoomViewController.h"
#import "PNJoinedRoomViewController.h"
#import "PNRoomCell.h"
 
#import "PNImageUtil.h"
#import "PNControllerLoader.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNDashboard.h"
#import "PNGlobal.h"
#import "PNLobby.h"

#define kPNFetchRoomsNum 100

@implementation PNRoomsViewController

@synthesize matchUpRoomCell;
@synthesize reloadCell;
@synthesize noneCell;
@synthesize lobby;
@synthesize headerCell_;

- (void)awakeFromNib {
	[super awakeFromNib];
	UIBarButtonItem* rightItem =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
												   target:self
												   action:@selector(addButtonDidPush)] autorelease];
	self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	hasAppeared = YES;
	
	if(!activeRooms) {
		activeRooms = [[NSMutableArray array] retain];
	}
	else {
		[activeRooms removeAllObjects];
	}
	
	PNRoomManager* roomManager = [PNManager roomManager];
	roomManager.delegate = self;
	int lobbyId = (lobby != nil) ? lobby.lobbyId : -1;
	[roomManager findRooms:kPNFetchRoomsNum
				   inLobby:lobbyId
				  delegate:self
			   onSucceeded:@selector(findRoomsSucceeded:)
				  onFailed:@selector(findRoomsFailed:)];
	[PNDashboard showIndicator];
}

- (id)retain {
	if (hasAppeared) {
	//	NSLog(@"%d", [super retainCount]);
	}
	return [super retain];
}

- (void)release
{
	[super release];
}

- (void)findRoomsSucceeded:(NSArray*)rooms {
	[activeRooms removeAllObjects];
	
	for(PNRoom *room in rooms) {
		if (room.isPublished) {
			[activeRooms addObject:room];
			PNCLog(PNLOG_CAT_INTERNET_MATCH,@"Room [%@]", room.roomName);
			
			for (PNPeer *roomMember in room.roomMembers) {
				PNCLog(PNLOG_CAT_INTERNET_MATCH,@" Member:%@", roomMember.user.username);
			}
			room.delegate = self;
			room.lobby = lobby;
			[room roundTripTimeMeasurement:room.roomMembers];
		}
	}
	[PNDashboard hideIndicator];
	[self reloadData];
}

- (void)findRoomsFailed:(PNError*)error {
	
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 /*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[self class] cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(reloadThread)
												 object:nil];
	[PNManager roomManager].delegate = nil;
	for (PNRoom* room in activeRooms) {
	// room.delegate = nil;
	}
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	if (indexPath.row == 0) {
		return 40.0f;
	}
	else {
		return 50.0f;
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (![activeRooms count] && 
		[PNDashboard isIndicatorAnimating]) { // finding room
		return 1;
	}
	else if (![activeRooms count]) { // no room found
		return 2;
	}
	else { // room(s) found
		return [activeRooms count] + 1;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%s", __FUNCTION__);
	
	if (indexPath.row == 0) {
		NSString* identifier =
		[NSString stringWithFormat:@"PNRoomsHeaderCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
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
	else if (![activeRooms count]) {
		//ルームがないセル
		NSString* identifier =
		[NSString stringWithFormat:@"PNRoomNoneCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNRoomNoneCell* cell = (PNRoomNoneCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
		
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = noneCell;
			self.noneCell;
		}
		
		[self setBackgroundImage:cell];
		return cell;
	}
	else {
		NSString* identifier =
		[NSString stringWithFormat:@"PNRoomCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNRoomCell *cell = (PNRoomCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
		
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:identifier
										  owner:self
										options:nil];
			cell = matchUpRoomCell;
			self.matchUpRoomCell = nil;		
		}

		PNRoom* room = [activeRooms objectAtIndex:indexPath.row - 1];
		
		[self setBackgroundImage:cell];
		[cell setRoomName:room.roomName];
		[cell setIcon:[UIImage imageNamed:@"PNDefaultUserIcon.png"]];
		for (PNPeer* peer in room.roomMembers) {
			if ([room.hostName isEqualToString:peer.user.username]) {
				[cell.headIcon loadImageWithUrl:peer.user.iconURL];
			}
		}
		[cell setRoomMemberNum:[room.roomMembers count] maxMemberNum:room.maxMemberNum];
		[cell setSignalImageWithSpeedLevel:[room speedLevel]];
		
		if (room.isLocked) {
			[cell lock];
		}
		else {
			[cell unlock];
		}
		[cell setLayout:MATCH_CELL];
		
		return cell;
	}
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0 || ![activeRooms count]) return;
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	PNRoom* room = [activeRooms objectAtIndex:indexPath.row - 1];	
	
	if (!room.isLocked) {
		PNJoinedRoomViewController* controller =
		(PNJoinedRoomViewController*)[PNControllerLoader load:@"PNJoinedRoomViewController"
												   filesOwner:self];
		room.delegate = controller;
		controller.myRoom = (PNRoom*)room;
		[controller setTitle:room.roomName];
		
		[PNDashboard pushViewController:controller];
	}
}

- (void)setBackgroundImage:(UITableViewCell *)cell {
	UIImage* backgroundImage = [UIImage imageNamed:kPNCellBackgroundImage];
	UIView* cellBackgroundView = [[[UIView alloc] init] autorelease];
	cellBackgroundView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
	cell.backgroundView = cellBackgroundView;
}

- (void)addButtonDidPush {
	PNLog(@"Start Create Room View Controller!!!");
	PNCreateRoomViewController* controller =
	(PNCreateRoomViewController*)[PNControllerLoader load:@"PNCreateRoomViewController"
											   filesOwner:nil];
	controller.lobby = self.lobby;
	[PNDashboard pushViewController:controller];	
}

- (void)reload {
	PNRoomManager* roomManager = [PNManager roomManager];
	roomManager.delegate = self;
	int lobbyId = (lobby != nil) ? lobby.lobbyId : -1;
	[roomManager findRooms:kPNFetchRoomsNum
				   inLobby:lobbyId
				  delegate:self
			   onSucceeded:@selector(findRoomsSucceeded:)
				  onFailed:@selector(findRoomsFailed:)];
	[PNDashboard showIndicator];
}

- (void)dealloc {
	PNSafeDelete(matchUpRoomCell);	
	PNSafeDelete(activeRooms);
	[super dealloc];
}


#pragma mark PNRoomManagerDelegate Call back methods

///////////
// PNRoomManagerDelegate.

//サーバーの場合はこちらに通知される。
-(void)didCreateRoom:(PNRoom*)room requestId:(int)requestId {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didCreateRoom\n");
	[room roundTripTimeMeasurement:room.roomMembers];
}

//クライアントの場合はこちらに通知される。
-(void)didFindActiveRoom:(PNRoom*)room requestId:(int)requestId {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"didFindActiveRoom.\n");
	
	room.delegate = self;
	[room roundTripTimeMeasurement:room.roomMembers];
}

-(void)didFindActiveRooms:(NSArray*)rooms requestId:(int)requestId
{

}

-(void)room:(PNRoom*)room finishGetSpeedLevelForPeer:(PNPeer*)peer {
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"finishGetSpeedLevelForPeer\n");
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%d", room.speedLevel);
	[self reloadData];
}

// PNRoomDelegate
-(void)roomDidJoin:(PNRoom*)room {}
-(void)room:(PNRoom*)room didFailJoinWithError:(PNNetworkError*)error {}
-(void)room:(PNRoom*)room didBeginGameSession:(PNGameSession*)gameSession {}
-(void)room:(PNRoom*)room willBeginGameSession:(PNGameSession*)gameSession {}
-(void)room:(PNRoom*)room didEndGameSession:(PNGameSession*)gameSession {}

@end
