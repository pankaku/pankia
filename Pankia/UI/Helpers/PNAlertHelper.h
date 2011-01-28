//
//  PNAlertHelper.h
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNError;
@interface PNAlertHelper : NSObject {

}
+ (void)showAlertForCoinPurchaseWithDelegate:(id)delegate
								  onPurchase:(SEL)onPurchaseSelector onCancel:(SEL)onCancelSelector;
+ (void)showAlertForCoinBonus:(id)delegate
                  aquiredCoins:(int64_t)addCoins currentCoins:(int64_t)currentCoins;
+ (void)showAlertForPurchaseFail:(PNError*)error;

// begin - lerry added code
+(void)showAlertForGameCenterLoginRequest:(id)delegate onLogin:(SEL)onLoginSelector onCancel:(SEL)onCancelSelector;
+(void)showAlertForGameCenterLoginRequestRejected:(id)delegate; 
// end - lerry added code
@end
