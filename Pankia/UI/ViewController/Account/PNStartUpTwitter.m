#import "PNStartUpTwitter.h"
#import "PNValidation.h"
 
#import "PNDashboard.h"
#import "PNRegistrationViewController.h"
#import "PankiaNet+Package.h"
#import "PankiaNetworkLibrary+Package.h"

@interface PNStartUpTwitter()
- (void)useCurrentUserAndTryLinkWithTwitterAccount;
- (void)userNameChanged:(PNUser*)user;
@end

@implementation PNStartUpTwitter
@synthesize accountNameField, passwordField, controller, submitBtn;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

/*!
 * 22.StartUp 初回登録画面　に戻ります。
 */
- (IBAction)backToRegistrationView{
	[self removeFromSuperview];
}
/*!
 * ログインを試みます
 */
- (IBAction)tryLogin{
	if ([PNValidation isEmpty:accountNameField.text] || [PNValidation isEmpty:passwordField.text]) {
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:SignIn_With_Twitter")
											   message:getTextFromTable(@"PNTEXT:UI:Validation_check_Empty.")
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		return;
	}
	
	submitBtn.enabled = NO;
	[PNDashboard showIndicator];
	
	[[PNUserManager sharedObject] switchAccountByTwitterID:accountNameField.text password:passwordField.text onSuccess:^() {
		[[PNDashboard sharedObject] updateUser:[PNUser currentUser]];
		[[PNUser currentUser] saveToCacheAsCurrentUser];
		[PNDashboard hideIndicator];
		[controller hide];
	} onFailure:^(PNError *error) {
		NSString* errorCode = error.errorCode;
		
		if ([errorCode isEqualToString:@"not_found"]){	// Valid credentials but not linked to any account.
			[self useCurrentUserAndTryLinkWithTwitterAccount];
			return;
		}
		
		NSString* errorMessage = getTextFromTable(@"PNTEXT:UI:Link_twitter_failure.");
		
		//ID,パスワードが間違っている場合
		if ([errorCode isEqualToString:@"invalid_credentials"]){
			errorMessage = getTextFromTable(@"PNTEXT:UI:Link_twitter_invalid_credentials.");
		}
		
		[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:SignIn_With_Twitter")
											   message:errorMessage
										 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
									 cancelButtonTitle:nil onCancelSelected:nil
											  delegate:self];
		
		submitBtn.enabled = YES;
		[PNDashboard hideIndicator];
	}];
}

- (void)useCurrentUserAndTryLinkWithTwitterAccount
{
	[[PNTwitterManager sharedObject] linkWithAccountName:accountNameField.text password:passwordField.text onSuccess:^(void) {
		[[PNDashboard sharedObject] updateUser:[PNUser currentUser]];
		[PNUser currentUser].isLinkTwitter = YES;
		[[PNUser currentUser] saveToCacheAsCurrentUser];
		
		// Automatically change name using twitter id
		[[PNUserManager sharedObject] changeName:accountNameField.text onSuccess:^() {
			[self userNameChanged:[PNUser currentUser]];
		} onFailure:^(PNError *error) {
			NSString* alternativeName = [[PNUser currentUser].username stringByReplacingOccurrencesOfString:@"guest" withString:@"Player"];
			[[PNUserManager sharedObject] changeName:alternativeName onSuccess:^() {
				[self userNameChanged:[PNUser currentUser]];
			} onFailure:^(PNError *error) {
				PNWarn(@"Change name error. %@", error);
			}];
		}];
	} onFailure:^(PNError *error) {
		PNWarn(@"Twitter link error. valid credential but unable to link. %@", error);
	}];
}
- (void)switchAccountSucceeded:(PNUser*)user
{
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:SignIn_With_Twitter")
										   message:getTextFromTable(@"PNTEXT:UI:Switch_Twitter_account_completion.")
									 okButtonTitle:getTextFromTable(@"PNTEXT:OK") onOKSelected:@selector(onOKSelected) 
								 cancelButtonTitle:nil onCancelSelected:nil
										  delegate:self];
	
	
	//	//PankiaにUserデータのアップデートがあったことを通知。
	//	[[PankiaNet sharedObject] didUpdateUser:[PNUser currentUser]];
	[[PNDashboard sharedObject] updateUser:[PNUser currentUser]];
	[[PNUser currentUser] saveToCacheAsCurrentUser];
	[controller hide];
}
- (void)onOKSelected{
	
}

- (void)userNameChanged:(PNUser*)user
{
	[[PNDashboard sharedObject] updateUser:[PNUser currentUser]];
	[[PNUser currentUser] saveToCacheAsCurrentUser];
	[controller hide];
}

- (IBAction)endEditing:(id)sender
{
	if (sender == accountNameField){
		[passwordField becomeFirstResponder];
	}else{
		[sender resignFirstResponder];
	}
}

- (void)dealloc {
	self.passwordField			= nil;
	self.controller				= nil;
	self.submitBtn              = nil;
    [super dealloc];
}


@end
