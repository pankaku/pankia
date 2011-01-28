#import "PNHighScoreViewController.h"
#import "PNLeaderboardRequestHelper.h"
#import "PNHighScoreCell.h"
#import "PNLoadMoreHighScoreCell.h"
#import "PNLoadOtherDateHighScoreCell.h"
#import "PNLeaderboardManager.h"
#import "PankiaNetworkLibrary.h"
#import "PNControllerLoader.h"
 
#import "PNDashboard.h"
#import "PankiaNetworkLibrary.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"
#import "PNTableViewHelper.h"

#import "PNRootNavigationController.h"

#import "PNFormatUtil.h"

#define WORLE_RANK_MODE		0
#define FRIENDS_RANK_MODE	1

#define PNWorldAndFriendsControlBarRect CGRectMake(0, 236, 480, 32)


@interface PNHighScoreViewController ()

- (NSInteger)countRank:(PNRank *)rank highScoresIndex:(NSInteger)rowIndex;

@end




@implementation PNHighScoreViewController;

@synthesize leaderboardId;
@synthesize scope;
@synthesize myRank;
@synthesize leaderboardType;
@synthesize highScores;
@synthesize targetDate;
@synthesize viewTitle;
@synthesize addScoreCount;

					 

#pragma mark -
#pragma mark Class extensions
					 
- (NSInteger)countRank:(PNRank *)rank highScoresIndex:(NSInteger)rowIndex {
	if (rowIndex == 0) {
		rank.rank = 1;
	} else {
		PNRank* _rank = (PNRank*)[highScores objectAtIndex:rowIndex-1];
		if ((rank.score && rank.score == _rank.score) || (rank.user.gradePoint && rank.user.gradePoint == _rank.user.gradePoint)) {
			rank.rank = _rank.rank;
		} else {
			rank.rank = rowIndex+1;
		}
	}
	
	return rank.rank;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
	PNLogMethodName;
    [super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.leaderboardId = kPNDefaultLeaderboardID;
	self.leaderboardType = kPNLeaderboardTypeGrade;
	rankMode = WORLE_RANK_MODE;
}

- (void)viewWillAppear:(BOOL)animated {
	PNLogMethodName;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	PNLogMethodName;
    [super viewDidAppear:animated];
	
	rowCounter = 0;
	showLoadMoreHighScores = YES;
	self.highScores = [[[NSMutableArray alloc] init] autorelease];
	self.targetDate = [NSDate date];
	[self sendQueries];

	// Display tool bar
	NSArray *segmentedControlItems = [[[NSArray alloc] initWithObjects:@"World", @"Friends", nil] autorelease];
	UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentedControlItems] autorelease];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.tintColor = [UIColor grayColor];
	UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
	UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	NSArray *toolBarItems = [[[NSArray alloc] initWithObjects:flexibleSpace, buttonItem, flexibleSpace, nil] autorelease];
	PNRootNavigationController *rootNavigationController = (PNRootNavigationController *)[PNDashboard getWrappedNavigationController];
	rootNavigationController.toolbarHidden = NO;
	rootNavigationController.toolbar.items = toolBarItems;
}

- (void)resetScore {
	PNLogMethodName;	
	rowCounter = 0;
	[highScores removeAllObjects];
}

- (void)getRankOfCurrentUserDone:(NSArray*)ranks {
	PNLogMethodName;
	if ([ranks count] > 0) {
		self.myRank = [ranks objectAtIndex:0];
	}
	[self reloadData];
}

- (void)getScoresDone:(NSArray*)resultArray {
	PNLogMethodName;
	addScoreCount = [resultArray count];
	if (!showLoadMoreHighScores) {
		[highScores removeAllObjects];		
	}
	
	for (PNRank* rank in resultArray) {
		rank.leaderboardId = leaderboardId;
		[highScores addObject:rank];
	}
	loadingFlag = NO;
	[self reloadData];
	[PNDashboard hideIndicator];
}

- (void)getRankOfCurrentUserFailed:(PNError*)error {
	PNLogMethodName;
	PNWarn(@"failed");
}

- (void)sendQueries {
	PNLogMethodName;
	//タブを無効にします
	loadingFlag = YES;
	[self reloadData];
	
	PNLeaderboardManager* lbManager = [PNLeaderboardManager sharedObject];
	int offset = [highScores count];
	
	NSString* period;
	switch (scope) {
		case kPNLeaderboardPeriodOverall:
			period = @"forever";
			break;
		case kPNLeaderboardPeriodMonthly: {
			NSDateFormatter*	dateFormatter	= [[[NSDateFormatter alloc] init] autorelease];
			NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
			[dateFormatter setTimeZone:timeZone];
			dateFormatter.dateFormat = @"yyyyMM";
			period = [dateFormatter stringFromDate:self.targetDate];
			break;
		}
		case kPNLeaderboardPeriodDaily: {
			NSDateFormatter*	dateFormatter	= [[[NSDateFormatter alloc] init] autorelease];
			NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
			[dateFormatter setTimeZone:timeZone];
			dateFormatter.dateFormat = @"yyyyMMdd";
			period = [dateFormatter stringFromDate:self.targetDate];
			break;
		}
		default:
			break;
	}

	if (rankMode == WORLE_RANK_MODE) {
		[lbManager getRankOnLeaderboard:leaderboardId username:[PNUser currentUser].username period:period delegate:self 
					onSucceededSelector:@selector(getRankOfCurrentUserDone:) onFailedSelector:@selector(getRankOfCurrentUserFailed:)];
		[lbManager getScoresOnLeaderboard:leaderboardId among:nil period:period offset:offset onSuccess:^(NSArray *arg1) {
			[self getScoresDone:arg1];
		} onFailure:^(PNError *arg1) {}];
	}
	else {
		[lbManager getScoresOnLeaderboard:leaderboardId among:@"friends" period:period offset:offset onSuccess:^(NSArray *arg1) {
			[self getScoresDone:arg1];
		} onFailure:^(PNError *arg1) {}];
		[lbManager getRankAmongFriendsOnLeaderboard:leaderboardId username:[PNUser currentUser].username period:period delegate:self 
					onSucceededSelector:@selector(getRankOfCurrentUserDone:) onFailedSelector:@selector(getRankOfCurrentUserFailed:)];
	}
	
	
	[PNDashboard showIndicator];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	PNLogMethodName;
	[super viewWillDisappear:animated];
	PNRootNavigationController *rootNavigationController = (PNRootNavigationController *)[PNDashboard getWrappedNavigationController];
	rootNavigationController.toolbarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	PNLogMethodName;
	[super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
	PNLogMethodName;
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	PNLogMethodName;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)setViewTitle:(NSString *)title {
	PNLogMethodName;
	viewTitle = title;
	[self setTitle:viewTitle];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	PNLogMethodName;
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	PNLogMethodName;
	int rowCount = [highScores count] + 1;
	if (scope == kPNLeaderboardPeriodMonthly || scope == kPNLeaderboardPeriodDaily) {
		rowCount++;	
	}
	
	if (addScoreCount && [highScores count] && !([highScores count]%10)) {
		showLoadMoreHighScores = YES;
		rowCounter = rowCount;
		rowCount++;
	}
	else {
		showLoadMoreHighScores = NO;
	}

	return rowCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	
    int targetCellIndex = 0;
	
	if (scope == kPNLeaderboardPeriodMonthly || scope == kPNLeaderboardPeriodDaily) {
		targetCellIndex++;
	}
	
	if (indexPath.row == 0 && targetCellIndex == 1) {
		NSString *CellIdentifier = @"PNLoadOtherDateHighScoreCellLandscape";		
		PNLoadOtherDateHighScoreCell *cell = (PNLoadOtherDateHighScoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
		}
		
		cell.delegate	= self;
		cell.scope		= scope;
		cell.targetDate	= self.targetDate;
		NSString*	dateString;
		if (scope == kPNLeaderboardPeriodMonthly) {
			NSDateFormatter*	dateFormatter	= [[[NSDateFormatter alloc] init] autorelease];
			NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
			[dateFormatter setTimeZone:timeZone];
			//[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			dateFormatter.dateFormat = @"MMMM yyyy";
			dateString = [dateFormatter stringFromDate:self.targetDate];
			//PNLog(@"presentMonth::%@",presentMonth);
		}
		else if(scope == kPNLeaderboardPeriodDaily) {
			NSDateFormatter*	dateFormatter	= [[[NSDateFormatter alloc] init] autorelease];
			NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
			[dateFormatter setTimeZone:timeZone];
			//[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			dateFormatter.dateFormat = @"MMMM d yyyy";
			dateString = [dateFormatter stringFromDate:self.targetDate];
		}
		if ([self.targetDate compare:[NSDate date]] == NSOrderedSame) {
			[cell disableNextBtn];
		}
		cell.dateLabel.text = dateString;

		[cell setLayout:LEADERBOARD_CELL];
		
		return cell;
	}
	else if (indexPath.row == targetCellIndex) {
		NSString *CellIdentifier = @"PNHighScoreTargetCellLandscape";
		PNHighScoreCell *cell = (PNHighScoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[PNHighScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		PNUser *myUser = [PNUser currentUser];
	
		[cell setRank:myRank.rank];
		[cell setUserName:myUser.username];
		[cell setStatus:myUser.status];//rank.user.status;
		[cell setScore:myRank.score];
		[cell setUserIconImage:myUser];
		[cell setCountry:myUser.countryCode];
		[cell setAchievementPoint:30 total:230];
		[cell setGrade:myUser];
		[cell setArrowIconImage:nil];

		return cell;
	}
	else if (rowCounter && rowCounter == indexPath.row && !([highScores count]%10)) {
		NSString *CellIdentifier = @"PNLoadMoreHighScoreCellLandscape";
		PNLoadMoreHighScoreCell *cell = (PNLoadMoreHighScoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
		}

		return cell;
	}
	else {
		NSString *CellIdentifier = [NSString stringWithFormat:@"PNHighScoreCellLandscape"];
		PNHighScoreCell *cell = (PNHighScoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[PNHighScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		int highScoresIndex = indexPath.row - targetCellIndex - 1;		
		if ([highScores count] > highScoresIndex) {
			PNRank *rank = (PNRank*)[highScores objectAtIndex:highScoresIndex];

			[cell setRank:[self countRank:rank highScoresIndex:highScoresIndex]];
			[cell setUserName:rank.user.username];
			[cell setStatus:@"I'm so happy!!"];//rank.user.status;
			[cell setScore:rank.score];
			[cell setUserIconImage:rank.user];
			[cell setCountry:rank.user.countryCode];
			[cell setAchievementPoint:30 total:230];
			[cell setGrade:rank.user];			
		}

		return cell;
	}
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];  

	int actionCellIndex = 0;
	if (scope == kPNLeaderboardPeriodMonthly || scope == kPNLeaderboardPeriodDaily) {
		actionCellIndex += 1;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];	
	
	int targetCellIndex = 0;
	if (scope == kPNLeaderboardPeriodMonthly || scope == kPNLeaderboardPeriodDaily) {
		targetCellIndex += 1;
	}
		
	if (indexPath.row == 0 && targetCellIndex == 1) {
		
								
	}else if (rowCounter && indexPath.row == rowCounter) {
		showLoadMoreHighScores = YES;
		[self sendQueries];
	}
}


- (void)showWorldRank {
	PNLogMethodName;
	rankMode = WORLE_RANK_MODE;	
	[self resetScore];
	[self sendQueries];	
}

- (void)showFriendsRank {
	PNLogMethodName;
	rankMode = FRIENDS_RANK_MODE;
	[self resetScore];
	[self sendQueries];	
}

- (void)dealloc {
	PNLogMethodName;
	self.highScores	= nil;
	self.myRank	= nil;
	self.leaderboardType = nil;
	self.targetDate	= nil;
	self.viewTitle = nil;

    [super dealloc];
}

#pragma mark PNLeaderboardDelegate methods


// PNLeaderboardManagerDelegate


- (void)manager:(PNLeaderboardManager*)manager didFailWithError:(PNError*)error requestKey:(NSString*)key {
	PNLogMethodName;
	[PNDashboard hideIndicator];
	[PNDashboard showErrorView:self withError:error];
	
}
@end

