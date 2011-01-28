//
//  PNItemHistory.h
//  PankakuNet
//
//  Created by sota on 10/09/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class PNItemOwnershipModel;
@interface PNItemHistory : NSObject {
	BOOL synchronizingWithServer;
	NSMutableDictionary* synchronozingRecordId;
	int retryDelay;
}
+ (PNItemHistory*) sharedObject;
- (void)sync;
- (int64_t)currentQuantityForItemId:(NSString*)itemId;
- (int64_t)increaseOrDecreaseQuantityForItemId:(NSString*)itemId delta:(int64_t)delta;
- (void)updateOwnership:(PNItemOwnershipModel*)ownership;
@end
