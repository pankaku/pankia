#import <UIKit/UIKit.h>
#import "PankiaNetworkLibrary.h"

@class PNRegistrationViewController;

@interface PNStartUpTwitter : UIView {
	UITextField *accountNameField, *passwordField;
	PNRegistrationViewController *controller;
	UIButton *submitBtn;
	
}
@property (nonatomic, retain) IBOutlet UITextField *accountNameField, *passwordField;
@property (nonatomic, retain) PNRegistrationViewController *controller;
@property (nonatomic, retain) IBOutlet UIButton *submitBtn;

- (IBAction)backToRegistrationView;
- (IBAction)tryLogin;
- (IBAction)endEditing:(id)sender;

- (void)onOKSelected;

@end
