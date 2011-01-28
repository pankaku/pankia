//
//  PNStoreObserver.m
//  PankakuNet
//
//  Created by sota on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "PNLogger+Package.h"
#import "PNStoreObserver.h"
#import "PNItemHistory.h"
#import "PNStoreManager.h"
#import "PNError.h"

static PNStoreObserver* _sharedStoreObserver = nil;

@interface PNStoreObserver ()
@property (nonatomic, retain) NSMutableArray* callbacksForPayment;
@end
@interface PNStoreObserver (Private)
- (void)completeTransaction:(SKPaymentTransaction*)transaction callback:(NSDictionary*)callback;
- (void)failedTransaction:(SKPaymentTransaction *)transaction callback:(NSDictionary*)callback;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
@end


@implementation PNStoreObserver
@synthesize callbacksForPayment;

- (void)purchase:(NSString*)productIdentifier onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	SKPayment* payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
	
	// Create transaction.
	// Note: Is there more good way to track transactions?
	NSArray* transactionsBefore = [[SKPaymentQueue defaultQueue] transactions];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	NSArray* transactionsAfter = [[SKPaymentQueue defaultQueue] transactions];
	NSMutableArray* transactionsCreated = [NSMutableArray arrayWithArray:transactionsAfter];
	[transactionsCreated removeObjectsInArray:transactionsBefore];
	
	if ([transactionsCreated count] != 1) {
		PNWarn(@"Transaction not created.");
		onFailure([PNError errorWithCode:@"unknown_error" message:@"transaction_not_created."]);
		return;
	}
	
	SKPaymentTransaction* currentTransaction = (SKPaymentTransaction*)[transactionsCreated objectAtIndex:0];
	[callbacksForPayment addObject:[NSDictionary dictionaryWithObjectsAndKeys:Block_copy(onSuccess), @"onSuccess",
									Block_copy(onFailure), @"onFailure", currentTransaction, @"transaction", nil]];	
}
- (NSDictionary*)callbackForTransaction:(SKPaymentTransaction*)transaction
{
	for (NSDictionary* callback in callbacksForPayment) {
		SKPaymentTransaction* savedTransaction = [callback objectForKey:@"transaction"];
		if (savedTransaction == transaction) {
			return callback;
		}
	}
	return nil;
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions) {
		NSDictionary* callback = [self callbackForTransaction:transaction];
		NSLog(@"transaction: %@ - %d", transaction.transactionIdentifier, transaction.transactionState);
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
				NSLog(@"purchasing");
				break;
			case SKPaymentTransactionStatePurchased:
				NSLog(@"purchased");
				[self completeTransaction:transaction callback:callback];
				break;
			case SKPaymentTransactionStateFailed:
				NSLog(@"failed");
				[self failedTransaction:transaction callback:callback];
				break;
			case SKPaymentTransactionStateRestored:
				NSLog(@"restored");
				[self restoreTransaction:transaction];
				break;
			default:
				break;
		}
	}
}



- (void)completeTransaction:(SKPaymentTransaction*)transaction callback:(NSDictionary*)callback
{
	if (callback) {
		void(^onSuccess)() = [callback objectForKey:@"onSuccess"];
		void(^onFailure)(PNError *) = [callback objectForKey:@"onFailure"];
		
		// Register receipt to the Pankia server and update ownership.
		[[PNStoreManager sharedObject] registerProduct:[[PNStoreManager sharedObject] productWithProductIdentifier:transaction.payment.productIdentifier] 
										   withReceipt:transaction.transactionReceipt onSuccess:^() {
											   // Everything is successful. Congraturations!
											   [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
											   onSuccess();
										   } onFailure:onFailure];
		
		Block_release(onSuccess);
		Block_release(onFailure);
		[callbacksForPayment removeObject:callback];
	} else {
		// Unknown transaction. (Maybe pended transaction)
		PNWarn(@"Unknown transaction completed. (Maybe pended)");
		[[PNStoreManager sharedObject] registerTransaction:transaction onSuccess:^() {
			PNWarn(@"Old transaction registered.");
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		} onFailure:^(PNError *error) {
			PNWarn(@"Transaction register error. %@", error);
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		}];
	}
}

// This method will never be called in current version of Pankia.
- (void)restoreTransaction:(SKPaymentTransaction*)transaction
{
	PNCLog(PNLOG_CAT_ITEM, @"restore transaction");
}
- (void) failedTransaction:(SKPaymentTransaction*)transaction callback:(NSDictionary*)callback
{
	if (transaction.error.code == SKErrorPaymentCancelled) {
		NSLog(@"cancelled");
	} else if (transaction.error.code == SKErrorUnknown) {
		NSLog(@"unkwown");
	} else if (transaction.error.code == SKErrorPaymentInvalid) {
		NSLog(@"invalid payment");
	} else if (transaction.error.code == SKErrorPaymentNotAllowed) {
		NSLog(@"payment not allowed");
	} else {
		NSLog(@"cliend invalid");
	}

	if (callback) {
		void(^onSuccess)() = [callback objectForKey:@"onSuccess"];
		void(^onFailure)(PNError *) = [callback objectForKey:@"onFailure"];
		onFailure([PNError errorWithCode:kPNPurchaseErrorPaymentFailed message:@"payment failed."]);
		Block_release(onSuccess);
		Block_release(onFailure);
		[callbacksForPayment removeObject:callback];
	} else {
		NSLog(@"unknown payment: %@", transaction.payment);		
	}
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		PNCLog(PNLOG_CAT_ITEM, @"storeObserver init");
		self.callbacksForPayment = [NSMutableArray array];
		[PNItemHistory sharedObject];
		
		PNCLog(PNLOG_CAT_ITEM, @"storeObserver added to SKPaymentQueue");
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

- (void) dealloc
{
	self.callbacksForPayment = nil;
	[super dealloc];
}

+ (PNStoreObserver *)sharedObject
{
    @synchronized(self) {
        if (_sharedStoreObserver == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedStoreObserver;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedStoreObserver == nil) {
			_sharedStoreObserver = [super allocWithZone:zone];
			return _sharedStoreObserver;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}
@end
