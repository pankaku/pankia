#import "PNSecureAccountViewController.h"
#import "PNUser.h"
#import "PNValidation.h"
#import "PNControllerLoader.h"
#import "UILabel+textWidth.h"
#import "PNUserManager.h"
#import "PNDashboard.h"
#import "PNNavigationController.h"
#import "PankiaNetworkLibrary+Package.h"

@implementation PNSecureAccountViewController

@synthesize emailField, passwordField, confirmField, informationLabel, submitBtn,
			email, password, confirm;
- (BOOL) shouldShowWrapperFrame{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		//
	
		CGRect frame = email.frame;
		frame.origin.x = (passwordField.frame.origin.x - [email textWidth]);
		email.frame = frame;
	
		frame = password.frame;
		frame.origin.x = (passwordField.frame.origin.x - [password textWidth]);
		password.frame = frame;
	
		frame = confirm.frame;
		frame.origin.x = (confirmField.frame.origin.x - [confirm textWidth]);
		confirm.frame = frame;
	} else {
		//
	}	
		
	if ([PNUser currentUser].isSecured) {
		[informationLabel setText:getTextFromTable(@"PNTEXT:EDIT_ACCOUNT:edit_account_info")];
	} else {
		[informationLabel setText:getTextFromTable(@"PNTEXT:UI:Secure_account_information.")];
	}
	[emailField    setDelegate:self];
	[passwordField setDelegate:self];
	[confirmField  setDelegate:self];
}
- (void)secureOrUpdate{
	submitBtn.enabled = NO; 
	[PNDashboard showIndicator];
	PNUser *currentUser = [PNUser currentUser];
	[[PNUserManager sharedObject] secureOrUpdateUser:currentUser name:currentUser.username 
											   email:emailField.text password:passwordField.text 
											delegate:self 
										 onSucceeded:@selector(securedOrUpdatedUser:isSecureOrUpdate:) 
											onFailed:@selector(secureOrUpdateFailed:)];
}
- (void)securedOrUpdatedUser:(PNUser*)user isSecureOrUpdate:(NSNumber*)isSecureOrUpdate{
	submitBtn.enabled = YES;
	[PNDashboard hideIndicator];
	[[PNDashboard getWrappedNavigationController] pushViewController:[PNControllerLoader load:@"PNSettingsViewController" filesOwner:nil] animated:NO];	
	if ([isSecureOrUpdate boolValue]){	//SECURE ACCOUNT
		[PNDashboard showInformationView:self withInformationMessage:getTextFromTable(@"PNTEXT:UI:Registration_completion_Info.")];
	}else{	//UPDATE ACCOUNT
		[PNDashboard showInformationView:self withInformationMessage:getTextFromTable(@"PNTEXT:UI:Edit_account_completion_Info.")];
	}
}
- (void)secureOrUpdateFailed:(PNError*)error{
	submitBtn.enabled = YES;
	[PNDashboard hideIndicator];
	
	//メールアドレスが無効か、登録済みの場合
	if([error.errorCode isEqualToString:@"already_exists"]) {
		
		/*
		PNAlertView* alert = [[PNAlertView alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
														message:getTextFromTable(@"PNTEXT:UI:Validation_check_secure_email.")
													   delegate:nil
													buttonTitle:getTextFromTable(@"PNTEXT:OK")];
		[alert show];
		[alert release];
		 */ 
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_secure_email.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelectedNil) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
	} else if ([error.errorCode isEqualToString:@"not_allowed"]) {//すでにセキュア済みの場合
		
		/*
		PNAlertView* alert = [[PNAlertView alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
														message:getTextFromTable(@"PNTEXT:UI:Validation_check_secure_email.")
													   delegate:nil
													buttonTitle:getTextFromTable(@"PNTEXT:OK")];
		[alert show];
		[alert release];
		 */
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_secure_email.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelectedNil) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		[[PNUser currentUser] setIsSecured:YES];
		[PNDashboard popViewController];
	} else {
		[PNDashboard showErrorView:self withError:error];
	}
}

- (void)onOKSelectedNil{

}

- (IBAction)pressedSubmitBtn
{	
	//既にセキュア済みだったら、仮登録状態になることの確認メッセージを表示します
	if ([PNUser currentUser].isSecured){
		[[PNDashboard sharedObject] showAlertWithTitle:@"PNTEXT:UI:Confirmation" 
											   message:@"PNTEXT:UI:Edit_account_confirmation." 
										 okButtonTitle:@"PNTEXT:OK" 
										  onOKSelected:@selector(secureOrUpdate)
									 cancelButtonTitle:@"PNTEXT:CANCEL" 
									  onCancelSelected:nil delegate:self];
		return;
	}
	
	if ([PNValidation isEmpty:emailField.text]
		|| [PNValidation isEmpty:passwordField.text]
		|| [PNValidation isEmpty:confirmField.text]) {
		
		/*
		PNAlertView* alert = [[PNAlertView alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
														message:getTextFromTable(@"PNTEXT:UI:Validation_check_Empty.")
													   delegate:nil
													buttonTitle:getTextFromTable(@"PNTEXT:OK")];
		[alert show];
		[alert release];
		 */
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_Empty.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelectedNil) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	if (![PNValidation isLegalUserName:passwordField.text]) {
		
		/*
		PNAlertView* alert = [[PNAlertView alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
														message:getTextFromTable(@"PNTEXT:UI:Validation_check_illegal_characters.")
													   delegate:nil
													buttonTitle:getTextFromTable(@"PNTEXT:OK")];
		[alert show];
		[alert release];
		 */
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_illegal_characters.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelectedNil) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	if ([PNValidation isMaxLength:passwordField.text maxLength:15]) {
		
		/*
		PNAlertView* alert = [[PNAlertView alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
														message:getTextFromTable(@"PNTEXT:UI:Validation_check_handle_maxLength.")
													   delegate:nil
													buttonTitle:getTextFromTable(@"PNTEXT:OK")];
		[alert show];
		[alert release];
		 */
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_handle_maxLength.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelectedNil) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	if (![PNValidation isEqualToStrings:passwordField.text :confirmField.text]) {

		/*
		PNAlertView* alert = [[PNAlertView alloc] initWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
														message:getTextFromTable(@"PNTEXT:UI:Validation_check_confirm.")
													   delegate:nil
													buttonTitle:getTextFromTable(@"PNTEXT:OK")];
		[alert show];
		[alert release];
		 */
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Secure_Account")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_confirm.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelectedNil) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		return;
	}
	[self secureOrUpdate];
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
	
	//space can not insert.
	if ([string isEqualToString:@" "]) {
		return NO;
	}
	return YES;
}

- (IBAction)endEditing:(id)sender
{
	if (sender == emailField){
		[passwordField becomeFirstResponder];
	}else if(sender == passwordField){
		[confirmField becomeFirstResponder];
	}else{
		[sender resignFirstResponder];
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if ([[PNDashboard sharedObject] isIPad]) {
		CGRect r = self.view.frame;
		r.origin.y = -14;
		self.view.frame = r;
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}

@end
