#import "PNAppMainViewController.h"
#import "PNDashboard.h"
#import "PankiaNet+Package.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNControllerLoader.h"
#import "PNMyProfileViewController.h"

@implementation PNAppMainViewController

@synthesize networkMatchBtn;
@synthesize achievementsBtn;
@synthesize leaderboardsBtn;
@synthesize itemsBtn;
@synthesize storeBtn;

@synthesize menuButtons;
@synthesize menuButtonNames;
@synthesize offlineEnableButtons;

#pragma mark -
#pragma mark View lifecycle

- (void)awakeFromNib {
	[super awakeFromNib];
	menuButtons = [NSArray arrayWithObjects:networkMatchBtn, leaderboardsBtn, achievementsBtn, itemsBtn, storeBtn, nil];
	// Load button positions from xib.
	int buttonIndex = 0;
	for (UIButton* button in menuButtons) {
		buttonFrames[buttonIndex++] = button.frame;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [PNDashboard sharedObject].appTitle;
	
	// Profile Area
	profileAreaView = (PNProfileAreaView*)[PNControllerLoader loadUIViewFromNib:@"PNProfileAreaView" filesOwner:self];
	profileAreaView.delegate = self;
	[self.view addSubview:profileAreaView];
}

- (void)viewWillAppear:(BOOL)animated {
	[self relocateMenuButtons];	
}

- (void)viewDidAppear:(BOOL)animated {
	[self updateProfileArea];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark button action

- (IBAction)onNetworkMatchBtnPressed {
	[PNDashboard pushViewControllerNamed:@"PNNetworkMatchViewController"];
}
- (IBAction)onLeaderboardsBtnPressed {
	[PNDashboard pushViewControllerNamed:@"PNLeaderboardsViewController"];
}
- (IBAction)onAchievementsBtnPressed {
	[PNDashboard pushViewControllerNamed:@"PNAchievementsViewController"];
}
- (IBAction)onItemsBtnPressed {
	[PNDashboard pushViewControllerNamed:@"PNMyItemsViewController"];
}
- (IBAction)onStoreBtnPressed {
	[PNDashboard pushViewControllerNamed:@"PNItemCategoryListViewController"];
}

#pragma mark -

// Relocate & hide top menu buttons.
- (void)relocateMenuButtons {
	menuButtons = [NSArray arrayWithObjects:networkMatchBtn, leaderboardsBtn, achievementsBtn, itemsBtn, storeBtn, nil];
	menuButtonNames = [NSArray arrayWithObjects:@"NetworkMatch", @"Leaderboards", @"Achievements", @"Items", @"Friends", nil];
	offlineEnableButtons = [NSArray arrayWithObjects:networkMatchBtn, achievementsBtn, itemsBtn, nil];
	PNSettingManager *settingManager = [PNSettingManager sharedObject];
	
	int menuIndex = 0;
	int enabledButtonIndex = 0;
	
	// Relocate each button.
	for(NSString *menuButtonName in menuButtonNames) {
		NSString *menuButtonSettingName = [menuButtonName stringByAppendingString:@"Enabled"];
		PNMainMenuButton *menuButton = [menuButtons objectAtIndex:menuIndex];
		
		CGRect newFrame;
		if (![settingManager boolValueForKey:menuButtonSettingName]) {
			newFrame = buttonFrames[[menuButtons count] - 1 - (menuIndex - enabledButtonIndex)];
			
			// Dismiss the button
			[menuButton dismiss];
		}
		else {
			newFrame = buttonFrames[enabledButtonIndex];
			enabledButtonIndex++;
			if ([PankiaNet isLoggedIn] || [offlineEnableButtons containsObject:menuButton]) {
				[menuButton setEnabled:YES];
				[menuButton setAlpha:1.00f];
			}
			else {
				[menuButton setEnabled:NO];
				[menuButton setAlpha:0.50f];
			}
		}	
		
		//Relocate the button
		[menuButton setFrame:newFrame];
		menuIndex++;
	}	
}

- (void)updateProfileArea {
	[profileAreaView updateStats];
}

- (void)loadIconWithUrl:(NSString*)url {
	[profileAreaView loadImageWithUrl:url];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	[networkMatchBtn release];
	[itemsBtn release];
	[leaderboardsBtn release];
	[achievementsBtn release];
	[storeBtn release];
	
	[menuButtons release];
	[menuButtonNames release];
	[offlineEnableButtons release];
}

- (void)dealloc {	
    [super dealloc];
}

#pragma mark -
#pragma mark PNProfileAreaViewDelegate Protocol

- (void)profileAreaTapped {
	PNLogMethodName;
	//PNMyProfileViewController *myProfileViewController = [[PNMyProfileViewController alloc] init];
	//[self.navigationController pushViewController:myProfileViewController animated:YES];
	//[myProfileViewController release];
	[PNDashboard pushViewControllerNamed:@"PNMyProfileViewController"];
}

@end

