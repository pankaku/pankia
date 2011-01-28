//
//  PNStoreObserver.h
//  PankakuNet
//
//  Created by sota on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class PNError;

@interface PNStoreObserver : NSObject <SKPaymentTransactionObserver> {
	NSMutableArray* callbacksForPayment;
}
+ (PNStoreObserver *)sharedObject;
- (void)purchase:(NSString*)productIdentifier onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
@end
