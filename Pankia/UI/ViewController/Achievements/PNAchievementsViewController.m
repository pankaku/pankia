#import "PNAchievementsViewController.h"
#import "PankiaNetworkLibrary+Package.h"
 
#import "PNDashboard.h"
#import "PankiaNet+Package.h"
#import "PNGlobal.h"
#import "PNGameDetailViewController.h"
#import "NSString+VersionString.h"
#import "PNTableViewHelper.h"
#import "PNGameManager.h"
#import "PNAchievementsCell.h"
#import "PNAchievementsTotalCell.h"
#import "PNAchievementDescriptionCell.h"

@implementation PNAchievementsViewController
@synthesize availableAchievements;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	PNLogMethodName;
    [super viewDidLoad];
	self.tableView.separatorColor = [UIColor cyanColor];
	
	NSMutableArray* availableAchievements_ = [NSMutableArray array];
	for (PNAchievement* achievement in [[PNGameManager sharedObject] achievements]) {
		if (!achievement.isSecret || [[PNAchievementManager sharedObject] isAchievementUnlocked:achievement.id]) {
			[availableAchievements_ addObject:achievement];
		}
	}
	self.availableAchievements = availableAchievements_;
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

- (void)viewDidAppear:(BOOL)animated
{
	[PNDashboard hideIndicator];
}

- (void)dealloc {
	self.availableAchievements = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	PNLogMethodName;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.availableAchievements count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
		return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	
	if (indexPath.row == 0) {
		NSString *CellIdentifier = [NSString stringWithFormat:@"PNAchievementTotalCell"];
		PNAchievementsTotalCell *cell = (PNAchievementsTotalCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[PNAchievementsTotalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier forUser:[PNUser currentUser]] autorelease];
		}
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		return cell;
	} else {
		PNAchievement *achievement = [self.availableAchievements objectAtIndex:indexPath.row-1];
		achievement.isUnlocked = [[PNAchievementManager sharedObject] isAchievementUnlocked:achievement.id];
		NSString *CellIdentifier = [NSString stringWithFormat:@"PNAchievementCell"];
		PNAchievementsCell *cell = (PNAchievementsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[PNAchievementsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		[cell setAchivementText:achievement];
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		return cell;
	}
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	PNLogMethodName;
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}


@end
		
