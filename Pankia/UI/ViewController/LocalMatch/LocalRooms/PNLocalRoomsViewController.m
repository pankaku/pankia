#import "PNLocalRoomsViewController.h"
#import "PNJoinedLocalRoomViewController.h"
#import "PNManager.h"
#import "PNControllerLoader.h"
#import "PNUser.h"
 
#import "PNDashboard.h"
#import "PankiaNetworkLibrary.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNCreateLocalRoomViewController.h"
#import "PNMyLocalRoomViewController.h"
#import "PNGlobal.h"

#define kPNSelectionOfTheLocalRoomUse YES	// ローカル対戦で部屋の選択のUIを使うかどうかの設定です。
#define kPNNearbyMatchJoinTimeout	60.0f	// ローカルマッチで部屋の検索時間がタイムアウトになるまでの時間。

@implementation PNLocalRoomsViewController

@synthesize lobby;
@synthesize activeRooms;


// Static Fields.
static int transactionCounter = 0;

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	PNCLog(PNLOG_CAT_LOCALMATCH, @"PNLocalRoomsViewController::viewDidAppear:%d\n",
		   [[NSThread mainThread] isEqual:[NSThread currentThread]]);
    [super viewDidLoad];
	
	if(self.activeRooms) {
		self.activeRooms = nil;
	}
	
	self.activeRooms = [NSMutableArray array];
	[self reloadData];
	
	PNRoomManager* roomManager = [PNManager roomManager];
	roomManager.delegate = self;
	[roomManager findLocalRoomsWithLobby:lobby];
	[PNDashboard showIndicator];
	transactionCounter++;
	[self performSelector:@selector(searchTimeout:)
			   withObject:[NSNumber numberWithInt:transactionCounter]
			   afterDelay:kPNNearbyMatchJoinTimeout];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	PNLog(@"viewDidDisappear\n");
	transactionCounter++;
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
    return [self.activeRooms count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString* identifier = @"Standard";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:identifier];
		[cell autorelease];
	}
	
	[self setBackgroundImage:cell];
	cell.textLabel.textColor	= [UIColor whiteColor];
	cell.textLabel.shadowColor  = [UIColor blackColor];
	cell.textLabel.shadowOffset = CGSizeMake(0, 1);	
	
	cell.imageView.image	 = [UIImage imageNamed:@"PNDefaultUserIcon.png"];
	cell.selectionStyle		 = UITableViewCellSelectionStyleNone;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	UIView *accessoryContainer = [[[UIView alloc] init] autorelease];
	UIImageView *arrowImage	   = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNCellArrowImage.png"]] autorelease];
	[accessoryContainer addSubview:arrowImage];
	[accessoryContainer setFrame:CGRectMake(3.0f, 0.0f, 24.0f, 17.0f)];
	
	PNRoom* room = [self.activeRooms objectAtIndex:indexPath.row];
	cell.textLabel.font	= [UIFont fontWithName:kPNDefaultFontName
										  size:14.0f];
	cell.textLabel.text	= [NSString stringWithFormat:@"%@", room.roomName];
	cell.accessoryView  = accessoryContainer;	

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	PNRoom* room = [self.activeRooms objectAtIndex:indexPath.row];	
	
	PNJoinedLocalRoomViewController* controller = 
	(PNJoinedLocalRoomViewController*)[PNControllerLoader load:@"PNJoinedLocalRoomViewController"
													filesOwner:self];
	room.delegate = controller;
	PNRoomManager* roomManager = [PNManager roomManager];
	roomManager.delegate = controller;
	controller.localRoom = (PNLocalRoom*)room;
	room.lobby = lobby;
	[room join];
	
	[PNDashboard pushViewController:controller];
}



#pragma mark PNRoomManagerDelegate Call back methods

///////////
// PNRoomManagerDelegate.

//サーバーの場合はこちらに通知される。
-(void)didCreateRoom:(PNRoom*)room requestId:(int)requestId {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didCreateRoom\n");
}

//クライアントの場合はこちらに通知される。
-(void)didFindActiveRooms:(NSArray*)rooms requestId:(int)requestId {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"didFindActiveRoom! \n");
	transactionCounter++;
	
	[self.activeRooms removeAllObjects];
	[self.activeRooms addObjectsFromArray:rooms];
	
	[self reloadData];
	[PNDashboard hideIndicator];
}

- (void)addButtonDidPush {
	PNCLog(PNLOG_CAT_LOCALMATCH, @"Create Local Room!!!");
	if(kPNSelectionOfTheLocalRoomUse) {
		PNCreateLocalRoomViewController* controller =
		(PNCreateLocalRoomViewController*)[PNControllerLoader load:@"PNCreateLocalRoomViewController"
														filesOwner:nil];
		controller.lobby_ = lobby;
		[PNDashboard pushViewController:controller];
	}
	else {
		PNMyLocalRoomViewController *controller =
		(PNMyLocalRoomViewController *)[PNControllerLoader load:@"PNMyLocalRoomViewController"
													 filesOwner:self];
		PNUser* user = [PNUser currentUser];
		
		if ([PNUser currentUser].username == nil || [[PNUser currentUser].username isEqualToString:@""]) {
			controller.roomName	= @"Player's Room";
		}
		else {
			controller.roomName	= [NSString stringWithFormat:@"%@'s Room",user.username];
		}
		controller.lobby = lobby;
		
		[PNDashboard pushViewController:controller];
	}
}



#pragma mark Timeout methods.

- (void)searchTimeout:(NSNumber *)counter {
	PNLog(@"Search timeout.");
	if ([counter intValue] == transactionCounter && ![activeRooms count]) {
		PNLog(@"Fire. Search timeout.");
		//TODO:タイムアウト用の文言が必要であれば考える
		[PNDashboard popViewController];
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Nearby_Match")
											   message:getTextFromTable(@"PNTEXT:LOCALMATCH:connection_error")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil
									  onCancelSelected:nil
											  delegate:self];
	}
}

- (void)onOKSelected {
	
}

- (void)dealloc {
	self.activeRooms = nil;
    [super dealloc];
}


@end

