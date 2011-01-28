#import "PNCreateRoomViewController.h"
#import "PNMyRoomViewController.h"
#import "PNControllerLoader.h"
#import "PNValidation.h"
 
#import "PNDashboard.h"
#import "PankiaNetworkLibrary+Package.h"
#import "UIView+Slide.h"
#import "PNGradeModel.h"

@implementation PNCreateRoomViewController

@synthesize roomNameField;
@synthesize playerSegBtnRight;
@synthesize playerSegBtnCenter;
@synthesize playerSegBtnLeft;
@synthesize numberOfPlayersLabel;
@synthesize gradeFilterLabel;
@synthesize publicOrPrivateLabel;
@synthesize gradeFilterSegBtnLeft;
@synthesize gradeFilterSegBtnCenter;
@synthesize gradeFilterSegBtnRight;
@synthesize publishSegBtnRight;
@synthesize publishSegBtnLeft;
@synthesize lobby;

- (BOOL) shouldShowWrapperFrame {
	return YES;
}

- (void)loadView {

}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	UIBarButtonItem* leftItem =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
												   target:self
												   action:@selector(cancelButtonDidPush)] autorelease];	
	UIBarButtonItem* rightItem =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
												   target:self
												   action:@selector(doneButtonDidPush)] autorelease];
	self.navigationItem.leftBarButtonItem  = leftItem;	
	self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{	
	NSString* selfName = [PNUser currentUser].username;
	self.roomNameField.text = [NSString stringWithFormat:@"%@'s room",selfName];
	
	
	
	int minMember = [[PNSettingManager sharedObject] internetMatchMinRoomMember];
	int maxMember = [[PNSettingManager sharedObject] internetMatchMaxRoomMember];
	
	// minMember == maxMemberの場合にはNumberOfPlayersを非表示にします。
	BOOL shouldHideNumberOfPlayersSelector = (minMember == maxMember);
	[self.playerSegBtnLeft setHidden:shouldHideNumberOfPlayersSelector];
	[self.playerSegBtnCenter setHidden:shouldHideNumberOfPlayersSelector];
	[self.playerSegBtnRight setHidden:shouldHideNumberOfPlayersSelector];
	[self.numberOfPlayersLabel setHidden:shouldHideNumberOfPlayersSelector];
	
	//　NumberOfPlayersが非表示の時はグレードフィルター等のUIを上につめます。
	if (shouldHideNumberOfPlayersSelector) {
		float yToSlide = numberOfPlayersLabel.frame.origin.y - gradeFilterLabel.frame.origin.y;
		
		NSArray *componentsToSlide = [NSArray arrayWithObjects:gradeFilterLabel, publicOrPrivateLabel, 
									  gradeFilterSegBtnLeft, gradeFilterSegBtnCenter, gradeFilterSegBtnRight,
									  publishSegBtnLeft, publishSegBtnRight, nil];
		for (UIView* component in componentsToSlide) {
			[component slideX:0.0f y:yToSlide];
		}
	}
	// NumberOfPlayersが表示されてるときは、対応人数にあわせてUIを変更します。
	else {
		int range = maxMember - minMember;
		// 2-3人 or 3-4人のとき
		if (range == 1) {
			// セグメントを二つにします。
			[playerSegBtnCenter setHidden:YES];
			[playerSegBtnRight slideX:(playerSegBtnCenter.frame.origin.x - playerSegBtnRight.frame.origin.x)
									y:0.0f];
		}
		// 2-4人のとき
		else if (range == 2) {
			// 特に何もしません。
		}
		else {
		}
	}
	
	self.playerSegBtnLeft.selected   = YES;
	self.playerSegBtnCenter.selected = NO;
	self.playerSegBtnRight.selected  = NO;
	
	playerNum = minMember;
	
	
	
	self.gradeFilterSegBtnLeft.selected   = YES;
	self.gradeFilterSegBtnCenter.selected = NO;
	self.gradeFilterSegBtnRight.selected  = NO;
	gradeFilter = kPNGradeAll;
	
	self.publishSegBtnLeft.selected  = YES;
	self.publishSegBtnRight.selected = NO;
	isPublish = YES;
	
	NSArray* numberNames = [NSArray arrayWithObjects:@"PNTEXT:MATCHUP:Two", @"PNTEXT:MATCHUP:Three", @"PNTEXT:MATCHUP:Four", nil];
	
	[playerSegBtnLeft setTitle:getTextFromTable([numberNames objectAtIndex:minMember-2]) forState:UIControlStateNormal];
	if (minMember < maxMember)
		[playerSegBtnCenter setTitle:getTextFromTable([numberNames objectAtIndex:maxMember-3]) forState:UIControlStateNormal];
	[playerSegBtnRight setTitle:getTextFromTable([numberNames objectAtIndex:maxMember-2]) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
	[PNDashboard hideIndicator];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[roomNameField resignFirstResponder];	
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (IBAction)endEditing:(id)sender {	
	[roomNameField resignFirstResponder];
}

- (void)doneButtonDidPush {
	if ([PNValidation isEmpty:roomNameField.text]) {
		
		/*
		PNAlertView* alert = [[[PNAlertView alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Create_Room")
														message:getTextFromTable(@"PNTEXT:UI:Validation_check_Empty.")
													   delegate:self
													buttonTitle:getTextFromTable(@"PNTEXT:OK")] autorelease];
		[alert show];
		 */
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Create_Room")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_Empty.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	
	PNMyRoomViewController * controller = (PNMyRoomViewController *)[PNControllerLoader load:@"PNMyRoomViewController" 
																				  filesOwner:self];
	controller.roomName		= self.roomNameField.text;
	controller.gradeFilter		= gradeFilter;
	controller.maxMemberNum		= playerNum;
	controller.isPublish		= isPublish;
	controller.isCreateRoom		= YES;
	controller.lobby = lobby;
	
	[PNDashboard pushViewController:controller];
}

- (void)onOKSelected {
	
}

- (IBAction)pressedPlayerSegBtn:(id)sender
{
	self.playerSegBtnLeft.selected   = NO;
	self.playerSegBtnCenter.selected = NO;
	self.playerSegBtnRight.selected  = NO;
	
	int minMember = [[PNSettingManager sharedObject] internetMatchMinRoomMember];
	int maxMember = [[PNSettingManager sharedObject] internetMatchMaxRoomMember];
	
	if (sender == self.playerSegBtnLeft){
        self.playerSegBtnLeft.selected   = YES;
		playerNum = minMember;
	}
	else if (sender == self.playerSegBtnCenter){
		self.playerSegBtnCenter.selected = YES;
		playerNum = maxMember-1;
	}
	else if (sender == self.playerSegBtnRight){
		self.playerSegBtnRight.selected  = YES;
		playerNum = maxMember;
	}
}

- (IBAction)pressedGradeFilterSegBtn:(id)sender
{
	self.gradeFilterSegBtnLeft.selected   = NO;
	self.gradeFilterSegBtnCenter.selected = NO;
	self.gradeFilterSegBtnRight.selected  = NO;
	if (sender == self.gradeFilterSegBtnLeft) {
		self.gradeFilterSegBtnLeft.selected   = YES;
		gradeFilter = kPNGradeAll;
	}
	else if (sender == self.gradeFilterSegBtnCenter) {
		self.gradeFilterSegBtnCenter.selected = YES;
		gradeFilter = kPNGradeSame;
	}
	else if (sender == self.gradeFilterSegBtnRight) {
		self.gradeFilterSegBtnRight.selected  = YES;
		gradeFilter = kPNGradeGrater;
	}
}

- (IBAction)pressedPublishSegBtn:(id)sender
{
	self.publishSegBtnLeft.selected  = NO;
	self.publishSegBtnRight.selected = NO;
	if (sender == self.publishSegBtnLeft){
		self.publishSegBtnLeft.selected = YES;
		isPublish = YES;
	}
	else if (sender == self.publishSegBtnRight){
		self.publishSegBtnRight.selected = YES;
		isPublish = NO;
	}
}

- (void)cancelButtonDidPush {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
	self.roomNameField				= nil;
	self.playerSegBtnLeft			= nil;
	self.playerSegBtnRight			= nil;
	self.playerSegBtnCenter			= nil;
	self.publishSegBtnRight			= nil;
	self.publishSegBtnLeft			= nil;
	self.gradeFilterSegBtnRight		= nil;
	self.gradeFilterSegBtnLeft		= nil;
	self.gradeFilterSegBtnCenter	= nil;
	self.numberOfPlayersLabel		= nil;
	self.gradeFilterLabel			= nil;
	self.publicOrPrivateLabel		= nil;
	
	[super dealloc];
}

@end
