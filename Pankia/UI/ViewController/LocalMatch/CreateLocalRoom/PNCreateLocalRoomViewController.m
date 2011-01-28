#import "PNCreateLocalRoomViewController.h"
#import "PNMyLocalRoomViewController.h"
#import "PNControllerLoader.h"
#import "PNValidation.h"
 
#import "PNDashboard.h"
#import "PankiaNetworkLibrary+Package.h"

@implementation PNCreateLocalRoomViewController

@synthesize roomNameField_;
@synthesize lobby_;

- (BOOL)shouldShowWrapperFrame {
	return YES;
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
	roomNameField_.text = [NSString stringWithFormat:@"%@'s Room",[PNUser currentUser].username];
}

- (void)viewDidAppear:(BOOL)animated {
	[PNDashboard hideIndicator];
    [super viewDidAppear:animated];
	PNRoomManager* roomMan = [PNManager roomManager];
	[roomMan stopFindActiveRooms];	
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}

- (void)viewWillDisappear:(BOOL)animated {
	[roomNameField_ resignFirstResponder];
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

- (IBAction)endEditing:(id)sender {
	PNLog(@"text editing is end! input text is %@",roomNameField_.text);
	[roomNameField_ resignFirstResponder];
}

- (void)doneButtonDidPush {
	if ([PNValidation isEmpty:roomNameField_.text]) {
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Create_Local_Room")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_Empty.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
										  onOKSelected:nil
									 cancelButtonTitle:nil
									  onCancelSelected:nil
											  delegate:self];
		return;
	}
	PNLog(@"pressed CreateLocalRoomBtn! input text is %@",roomNameField_.text);
	PNMyLocalRoomViewController *controller =
		(PNMyLocalRoomViewController *)[PNControllerLoader load:@"PNMyLocalRoomViewController"
													 filesOwner:self];
	controller.roomName = roomNameField_.text;
	controller.lobby = lobby_;
	[PNDashboard pushViewController:controller];
}

- (void)cancelButtonDidPush {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
	[roomNameField_ release];
    [super dealloc];
}

@end
