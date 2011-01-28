#import "PNRegistrationViewController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNControllerLoader.h"
 
#import "PNValidation.h"
#import "PNStartUpTwitter.h"
#import "PNDashboard.h"
#import "PNNavigationController.h"
#import "PankiaNet+Package.h"
#import "PNNotificationNames.h"

@implementation PNRegistrationViewController

@synthesize controllerName,pushControllers,isLaunchDashboard,usernameField,submitButton, agreeButton, disagreeButton;
@synthesize pankiaDescriptionLabel, useTwitterButton, useTwitterDescription, titleLabel, usernameLabel;


//同意画面を表示させます
- (void)showAgreeScreen{
	[useTwitterButton setHidden:YES];
	[useTwitterDescription setHidden:YES];
	[titleLabel setHidden:YES];
	[submitButton setHidden:YES];
	[usernameField setHidden:YES];
	[usernameLabel setHidden:YES];
}
- (IBAction)agree
{
	[agreeButton setHidden:YES];
	[pankiaDescriptionLabel setHidden:YES];
	[useTwitterButton setHidden:NO];
	[useTwitterDescription setHidden:NO];
	[titleLabel setHidden:NO];
	[submitButton setHidden:NO];
	[usernameField setHidden:NO];
	[usernameLabel setHidden:NO];
	usernameField.text = [[PNUser currentUser].username stringByReplacingOccurrencesOfString:@"guest" withString:@"Player"];
}
- (IBAction)disagree
{
	[[PNDashboard sharedObject] showAlertWithTitle:@"PNTEXT:UI:Regist_Handle"
										   message:@"PNTEXT:UI:Do_you_really_want_to_disable_PANKIA"
									 okButtonTitle:@"PNTEXT:UI:Yes" onOKSelected:@selector(disablePankia) 
								 cancelButtonTitle:@"PNTEXT:UI:No" onCancelSelected:nil
										  delegate:self];
}
- (void)disablePankia
{
	// PANKIAをDisableにしたことを保存しておき、次回以降登録画面が起動時に表示されないようにします
	[PNSettingManager storeBoolValue:YES forKey:@"PNPankiaDisabled"];
	[PNDashboard hideRegistrationView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	[self showAgreeScreen];
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


- (void)dealloc {
	self.titleLabel						= nil;
	self.submitButton					= nil;
	self.usernameField					= nil;
	self.usernameLabel					= nil;
	self.controllerName					= nil;
	self.pushControllers				= nil;
	self.pankiaDescriptionLabel			= nil;
	self.useTwitterButton				= nil;
	self.useTwitterDescription			= nil;
	self.agreeButton					= nil;
	self.disagreeButton					= nil;
    [super dealloc];
}

/*!
 * キーボード使用時に呼び出されます。
 * 入力チェックを行い、入力を制限します。
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	//Done
	if (![string isEqualToString:@" "] && !range.length) {
		return YES;
	}
	
	//max Length is 15.
	if (textField == usernameField && range.location >= 15) {
		return NO;
	}
	//space can not insert.
	if ([string isEqualToString:@" "]) {
		return NO;
	}
	return YES;
}

- (IBAction) endEditing:(id)sender {
	[usernameField resignFirstResponder];
}

- (IBAction)submit
{
	if ([PNValidation isEmpty:usernameField.text]) {
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Regist_Handle")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_Empty.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	
	if (![PNValidation isLegalUserName:usernameField.text]) {
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Regist_Handle")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_illegal_characters.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	
	if ([PNValidation isMaxLength:usernameField.text maxLength:15]) {
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Regist_Handle")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_handle_maxLength.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	[usernameField resignFirstResponder];
	
	[PNDashboard showIndicator];	
	[[PNUserManager sharedObject] changeName:usernameField.text onSuccess:^() {
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPNNotificationUserStateUpdate object:nil]];
		[[PNDashboard sharedObject] updateUser:[PNUser currentUser]];
		[PNDashboard updateDashboard];
		[self hide];
	} onFailure:^(PNError *error) {
		[PNDashboard hideIndicator];
		if ([error.errorCode isEqualToString:@"invalid_parameter"]) {
			[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Regist_Handle")
												   message:getTextFromTable(@"PNTEXT:UI:Validation_check_handle.")
											 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
										 cancelButtonTitle:nil onCancelSelected:nil
												  delegate:self];
		} else {
			[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Regist_Handle")
												   message:getTextFromTable(@"PNTEXT:CHANGE_NAME:Already_used")
											 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
										 cancelButtonTitle:nil onCancelSelected:nil
												  delegate:self];
		}
	}];
	
}

- (IBAction)pressedTwitterRegisterBtn{

	PNStartUpTwitter* twitterRegister = (PNStartUpTwitter*)[PNControllerLoader loadUIViewFromNib:@"PNStartUpTwitter" filesOwner:self];
	twitterRegister.controller = self;
	[self.view addSubview:twitterRegister];

}

- (void)hide{
	if (isLaunchDashboard) {
		[PNDashboard hideRegistrationViewWithLaunchDashboardPushControllers:pushControllers];		
	}
	else {
		[PNDashboard hideRegistrationView];
	}
}

-(void)didUpdateUser:(PNUser*)user requestKey:(NSString*)key
{
	PNLog(@"updateUser!!!");

	user.isGuest		= NO;
	[user saveToCacheAsCurrentUser];
	//[[PankiaNet sharedObject] didUpdateUser:user];
	[[PNDashboard sharedObject] updateUser:user];
	[PNDashboard updateDashboard];

	[self hide];

}

-(void)didFailWithError:(PNError*)error requestKey:(NSString*)key
{
	[PNDashboard hideIndicator];
	if ([error.errorCode isEqualToString:@"invalid_parameter"]) {
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Regist_Handle")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_handle.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
	} else {
		[PNDashboard showErrorView:self withError:error];
	}
}

- (void)onOKSelected{
	
}

@end
