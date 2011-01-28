//
//  PNAlertHelper.m
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLocalizedString.h"
#import "PNDashboard.h"
#import "PNAlertHelper.h"
 
#import "PNManager.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNNotificationService.h"
  
@implementation PNAlertHelper
+ (void)showAlertForCoinPurchaseWithDelegate:(id)delegate
								  onPurchase:(SEL)onPurchaseSelector onCancel:(SEL)onCancelSelector
{
	[[PNDashboard sharedObject] showAlertWithTitle:@"PNTEXT:INTERNET_MATCH:Coins"
										   message:@"PNTEXT:INTERNET_MATCH:Would_you_buy_coins" 
									 okButtonTitle:@"PNTEXT:UI:Yes" onOKSelected:onPurchaseSelector
								 cancelButtonTitle:@"PNTEXT:UI:No" onCancelSelected:onCancelSelector
										  delegate:delegate];
	[PNUser currentUser].coins = 0;
	[PNDashboard updateDashboard];
	
}

+ (void)showAlertForCoinBonus:(id)delegate aquiredCoins:(int64_t)addCoins currentCoins:(int64_t)currentCoins 
{
	[PNNotificationService showTextNotice:[NSString stringWithFormat:getTextFromTable(@"PNTEXT:MATCH:Earned_coins") , addCoins]
							  description:getTextFromTable(@"PNTEXT:MATCH:Play_internet_matches_with_the_coins") 
								iconImage:[UIImage imageNamed:@"PNNotificationPankiaIcon.png"]];
}


// begin - lerry added code
+ (void)showAlertForGameCenterLoginRequest:(id)delegate 
								   onLogin:(SEL)onLoginSelector onCancel:(SEL)onCancelSelector
{
	[[PNDashboard sharedObject] showAlertWithTitle:@"Request to log into Game Center"
										   message:@"Do you want log into Game Center as well?" 
									 okButtonTitle:@"PNTEXT:UI:Yes" onOKSelected:onLoginSelector
								 cancelButtonTitle:@"PNTEXT:UI:No" onCancelSelected:onCancelSelector
										  delegate:delegate];
	[PNDashboard updateDashboard];
}

+ (void)showAlertForGameCenterLoginRequestRejected:(id)delegate
{
	[[PNDashboard sharedObject] showAlertWithTitle:@"About Game Center Setting" 
										   message:@"You can log into Game Center later by going to Settings." 
									 okButtonTitle:@"PNTEXT:UI:Yes" onOKSelected:nil
								 cancelButtonTitle:nil onCancelSelected:nil
										  delegate:delegate];
}
// end - lerry added code

+ (void)showAlertForPurchaseFail:(PNError*)error
{
	if (error == nil) return;
	
	// Ignore if error is not critical.
	if ([error.errorCode isEqualToString:kPNPurchaseErrorTransactionNotRestored]) {
		PNWarn(@"transaction failed but non-critical. %@", error.errorCode);
		return;
	}
	
	NSString* errorMessage = @"Unknown error.";
	NSString* errorMessageToReport;
	if (error.errorCode != nil) {
		if (error.message != nil) {
			errorMessage = [NSString stringWithFormat:@"[%@]\n%@", error.errorCode, error.message];
		} else {
			errorMessage = [NSString stringWithFormat:@"[%@]", error.errorCode];
		}
		errorMessageToReport = [NSString stringWithString:errorMessage];
		
		if ([error.errorCode isEqualToString:@"already_exists"] || [error.errorCode isEqualToString:@"timeout"]) {
			errorMessage = getTextFromTable(@"PNTEXT:ITEMS:Reset_app_and_retry.");
		}
		if ([error.errorCode isEqualToString:@"has_pending_transaction"]) {
			errorMessage = getTextFromTable(@"PNTEXT:ITEMS:Has_pending_transaction");
		}
		if ([error.errorCode isEqualToString:@"cannot_make_payments"]) {
			errorMessage = getTextFromTable(@"PNTEXT:ITEMS:Cannot_make_payments");
		}
	} else {
		if (error.message != nil) {
			errorMessage = error.message;
		}
	}
	
	[[PNManager sharedObject] sendReport:[NSString stringWithFormat:@"purchase failed. details:\n%@", errorMessageToReport]];
	PNWarn(@"[ERROR]purchase failure! details:\n%@", errorMessage);
	[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:SERVERERROR:unknown_title")
										   message:errorMessage
									 okButtonTitle:@"PNTEXT:OK" onOKSelected:nil
								 cancelButtonTitle:nil onCancelSelected:nil
										  delegate:nil];
}
@end
