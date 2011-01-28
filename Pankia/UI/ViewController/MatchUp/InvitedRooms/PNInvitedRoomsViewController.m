#import "PNInvitedRoomsViewController.h"
#import "PNControllerLoader.h"
#import "PNRoom.h"
#import "PNInvitationRequestHelper.h"
#import "PNTableCell.h"
#import "PNJoinedRoomViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNInvitationManager.h"
#import "PNDashboard.h"
#import "PNGlobal.h"

@implementation PNInvitedRoomsViewController
@synthesize matchUpRoomCell;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didFindInvitedRooms:(NSArray*)roomArray requestKey:(NSString*)key {
	[invitedRooms removeAllObjects];
	
	for (PNRoom* room in roomArray) {
		[invitedRooms addObject:room];
	}
	[self reloadData];
	[PNDashboard hideIndicator];
}

- (void)didFailWithError:(PNError*)errro requestKey:(NSString*)key
{
	PNWarn(@"find invited room error.");
	[PNDashboard hideIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[PNDashboard showIndicator];
	
	invitedRooms = [[NSMutableArray alloc] init];//Do not autorelease!
	PNInvitationManager* invitationManager = [PNManager sharedObject].invitationManager;
	[invitationManager findInvitedRoomsWithDelegate:self
								onSucceededSelector:@selector(didFindInvitedRooms:requestKey:)
								   onFailedSelector:@selector(didFailWithError:requestKey:)];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [invitedRooms count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* CellIdentifier = [NSString stringWithFormat:@"PNRoomCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
	PNRoomCell *cell = (PNRoomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		cell = matchUpRoomCell;
		self.matchUpRoomCell = nil;		
	}
	
	PNRoom* room = [invitedRooms objectAtIndex:indexPath.row]; 
	[cell setRoomName:room.roomName];
	[cell setRoomMemberNum:[room.roomMembers count] maxMemberNum:room.maxMemberNum];
	[cell hideSignalImage];
	
	if (room.isLocked) {
		[cell lock];
	}
	else {
		[cell unlock];
	}
	
	[cell setLayout:MATCH_CELL];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

	
	PNRoom* room = [invitedRooms objectAtIndex:indexPath.row];
	
	PNJoinedRoomViewController* controller = (PNJoinedRoomViewController*)[PNControllerLoader load:@"PNJoinedRoomViewController" filesOwner:self];
	room.delegate = controller;
	controller.myRoom = room;	
	[PNDashboard pushViewController:controller];
	
}


- (void)dealloc {
	self.matchUpRoomCell = nil;

	//private member variable.
	PNSafeDelete(invitedRooms);
	
    [super dealloc];
}
@end

