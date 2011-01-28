#import "PNInviteFriendsViewController.h"
#import "PNInviteFriendCell.h"
#import "PNInviteFriendActionCell.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNInvitationManager.h"
#import "PNInvitationManagerDelegate.h"
#import "PNUserManager.h"
#import "PNDashboard.h"
#import "PNGlobal.h"

@implementation PNInviteFriendsViewController

@synthesize myInviteFriendCell, myInviteFriendActionCell, loadMoreCell, _rowCount, isLoadMore;

- (void)viewDidLoad {
    [super viewDidLoad];
	[PNDashboard hideIndicator];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)findFollowees {
	[PNDashboard showIndicator];
	[[PNUserManager sharedObject] getFolloweesInCurrentGameOfUser:[PNUser currentUser].username 
											  offset:friendsOffset 
											   limit:10 
											delegate:self 
										 onSucceeded:@selector(gotFollowees:) 
											onFailed:nil];
	isCheckAll = NO;
}

- (void)gotFollowees:(NSArray*)_followees {
	
	if ([_followees count] && !([_followees count]%10)) {
		isLoadMore = YES;
	}
	else {
		isLoadMore = NO;
	}
	
	[friends addObjectsFromArray:_followees];
	[self reloadData];
	[PNDashboard hideIndicator];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if(!friends) {
		friends = [[NSMutableArray alloc] init];//Do not autorelease!
	}
	else {
		[friends removeAllObjects];
	}
	
	if(!inviteFriends){
		inviteFriends = [[NSMutableArray alloc] init];//Do not autorelease!
	}
	else {
		[inviteFriends removeAllObjects];
	}
	
	friendsOffset = 0;
	[self findFollowees];

	[PNDashboard showIndicator];
	[PNDashboard disableAllButtons];
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
	_rowCount = 0;
	int cellCount = [friends count] + 1;
	if (isLoadMore && [friends count]) {
		_rowCount = cellCount;
		cellCount++;
	}
    return cellCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
		NSString* CellIdentifier = [NSString stringWithFormat:@"PNInviteFriendActionCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNInviteFriendActionCell *cell = (PNInviteFriendActionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
			cell = myInviteFriendActionCell;
			self.myInviteFriendActionCell = nil;		
		}
		
		if (isCheckAll) {
			[cell checkAllOn];
		}
		else {
			[cell checkAllOff];
		}
		cell.delegate		= self;
		cell.selectionStyle	= UITableViewCellSelectionStyleNone;
		return cell;			
	}
	else if (_rowCount && _rowCount == indexPath.row) {
		NSString *CellIdentifier = [NSString stringWithFormat:@"PNInviteFriendsLoadMoreCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNInviteFriendsLoadMoreCell *cell = (PNInviteFriendsLoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
			cell = loadMoreCell;
			self.loadMoreCell = nil;		
		}

		return cell;
	}
	else {
		NSString* CellIdentifier = [NSString stringWithFormat:@"PNInviteFriendCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
		PNInviteFriendCell *cell = (PNInviteFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
			cell = myInviteFriendCell;
			self.myInviteFriendCell = nil;		
		}
		
		int rowIndex = indexPath.row -1;
		PNLog(@"cellName:%@", [friends objectAtIndex:rowIndex]);
		PNFriend* fData = [friends objectAtIndex:rowIndex];

		[cell setUserName:fData.userName];
		[cell setIconUrl:fData.iconUrl];
		[cell setIcon:[UIImage imageNamed:@"PNDefaultUserIcon.png"]];
		[cell.headIcon loadImageWithUrl:fData.iconUrl];
		[cell setFlagImageForCountryCode:fData.countryCode];
		[cell setAchievementPoint:fData.achievementPoint];
		[cell setGradeName:fData.gradeName];
		[cell setGradePoint:fData.gradePoint];
		[cell setGradeEnabled:fData.gradeEnabled];

		
		cell.cellRowIndex = rowIndex;
		cell.delegate = self;

		[cell checkOff];
		NSString* rowIndexStr = [NSString stringWithFormat:@"%d",rowIndex];
		for (NSString* index in inviteFriends) {
			if ([index isEqualToString:rowIndexStr]) {
				[cell checkOn];
			}
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
	
	if(indexPath.row > 0){
		//load more
		if (_rowCount && _rowCount == indexPath.row) {
			friendsOffset += 10;
			[self findFollowees];
			return;
		}
		
		//other
		int rowIndex = indexPath.row -1;
		NSString* rowIndexStr = [NSString stringWithFormat:@"%d",rowIndex];
		if ([inviteFriends containsObject:rowIndexStr]) {
			[inviteFriends removeObject:rowIndexStr];
		}
		else {
			[inviteFriends addObject:rowIndexStr];
		}

		[self reloadData];
	}
}

- (void)dealloc {
	self.myInviteFriendCell			= nil;
	self.myInviteFriendActionCell	= nil;
	
	PNSafeDelete(friends);
	PNSafeDelete(inviteFriends);

    [super dealloc];
}

- (void)pressedInviteBtn
{	
	[PNDashboard showIndicator];
	
	PNInvitationManager* imanager = [PNManager sharedObject].invitationManager;
	if (isCheckAll) {
		[imanager postInvitationForAllUsersWithDelegate:self onSucceededSelector:@selector(didPostInvitation:) onFailedSelector:@selector(didFailInvitationWithError:requestKey:)];
	}
	else {
		NSMutableArray* userArray = [NSMutableArray array];
		for(NSString* indexStr in inviteFriends) {
			PNFriend* fData = [friends objectAtIndex:[indexStr intValue]];
			[userArray addObject:fData.userName];
		}
		[imanager postInvitationForUsers:userArray delegate:self onSucceededSelector:@selector(didPostInvitation:) onFailedSelector:@selector(didFailInvitationWithError:requestKey:)];
	}
}

- (void)didPostInvitation:(NSString*)key
{
	[myInviteFriendActionCell enableInviteBtn];
	[PNDashboard hideIndicator];
	[PNDashboard popViewController];
}

- (void)didFailInvitationWithError:(PNError*)error requestKey:(NSString*)key
{
	[myInviteFriendActionCell enableInviteBtn];
	[PNDashboard hideIndicator];
	[PNDashboard popViewController];
}

- (void)pressedCheckAllBtn
{
	PNSafeDelete(inviteFriends);
	inviteFriends = [[NSMutableArray alloc] init];

	if (isCheckAll) {
		isCheckAll = NO;
	}
	else {
		isCheckAll = YES;

		int friendCount = [friends count];
		for (int i = 0; i < friendCount; i++) {
			NSString* str = [NSString stringWithFormat:@"%d",i];
			[inviteFriends addObject:str];
		}		
	}
	
	[self reloadData];
}

- (void)addFriend:(int)cellRowIndex
{
	if ([inviteFriends count] == [friends count]-1) {
		[self pressedCheckAllBtn];
	} else {
		NSString* str = [NSString stringWithFormat:@"%d",cellRowIndex];
		[inviteFriends addObject:str];
	}
}

- (void)removeFriend:(int)cellRowIndex
{	
	NSString* str = [NSString stringWithFormat:@"%d",cellRowIndex];

	for (int i = 0; i < [inviteFriends count]; i++) {
		if ([str isEqualToString:[inviteFriends objectAtIndex:i]]) {
			[inviteFriends removeObjectAtIndex:i];
		}
	}
	
	if (isCheckAll) {
		isCheckAll = NO;
		[self reloadData];
	}
}

- (void)pressedCancelBtn
{
	[PNDashboard popViewController];
}

- (BOOL)isCheckAll
{
	return isCheckAll;
}

@end

