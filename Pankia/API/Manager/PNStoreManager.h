//
//  PNStoreManager.h
//  PankakuNet
//
//  Created by sota on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNStoreObserver.h"

@class PNSKProduct;
@class PNMerchandise;
@class PNError;
@interface PNStoreManager : NSObject <SKProductsRequestDelegate> {
	NSString* currentRequestKey;
	SKProduct* currentProduct;
	
	NSMutableDictionary* productDetails;
	NSMutableDictionary* merchadiseDetails;
	BOOL	isPaymentCompleted;	// トランザクションが、以前のトランザクション復元のために失敗したかどうかを
								// 判別するためのフラグです。
	NSDate* initializedDate;
}
@property (nonatomic, retain) NSMutableDictionary* productDetails;
+ (PNStoreManager*)sharedObject;
- (PNMerchandise*)merchandiseWithProductIdentifier:(NSString*)productIdentifier;
- (PNSKProduct*)productWithProductIdentifier:(NSString*)identifier;

- (void)createCache;
- (NSString*)transactionStoreKeyWithProductIdentifier:(NSString*)productIdentifier;
- (void)saveTransactionWasCleared;

- (void)purchaseWithProductIdentifier:(NSString*)productIdentifier onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)registerProduct:(PNSKProduct*)product withReceipt:(NSData*)receipt onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)registerTransaction:(SKPaymentTransaction*)transaction onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
#pragma mark Deprecateds
- (BOOL)getDetailOfProducts:(NSArray*)productIdentifiers delegate:(id)delegate 
				onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getPurchaseHistoryWithDelegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
							  onFailed:(SEL)onFailedSelector;

@end
