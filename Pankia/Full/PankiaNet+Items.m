//
//  PankiaNet+Items.m
//  PankakuNet
//
//  Created by sota2 on 10/10/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PankiaNet.h"
#import "PNItem.h"
#import "PNItemCategory.h"
#import "PNItemHistory.h"

@implementation PankiaNet(Items)
#pragma mark private method for Items
+ (int64_t)acquireOrConsumeItem:(int)itemId quantity:(int64_t)quantity error:(PNError**)error
{
	NSString* itemIdString = [NSString stringWithFormat:@"%d", itemId];
	
	//アイテムがない場合は取得／消費できません
	PNItem* item = [PNItem itemWithId:itemId];
	if (item == nil) {
		*error = [[[PNError alloc] init] autorelease];
		(*error).errorCode = @"item_not_found";
		return -1;
	}
	
	//アイテムがコインの場合は取得／消費できません
	PNItemCategory* category = [item category];
	if (category == nil) {
		*error = [[[PNError alloc] init] autorelease];
		(*error).errorCode = @"not_found";
		return -1;
	}
	
	if ([category isCoinCategory]) {
		*error = [[[PNError alloc] init] autorelease];
		(*error).errorCode = @"cannot_acquire_coins";
		return -1;
	}
	
	return [[PNItemHistory sharedObject] increaseOrDecreaseQuantityForItemId:itemIdString
																	   delta:quantity];
}
#pragma mark public methods for Items
+ (int64_t)acquireItem:(int)itemId quantity:(int64_t)quantity error:(PNError**)error
{
	return [self acquireOrConsumeItem:itemId quantity:quantity error:error];
}
+ (int64_t)consumeItem:(int)itemId quantity:(int64_t)quantity error:(PNError**)error
{
	return [self acquireOrConsumeItem:itemId quantity:-quantity error:error];
}
+ (int64_t)quantityOfItem:(int)itemId
{
	return [[PNItemHistory sharedObject] currentQuantityForItemId:[NSString stringWithFormat:@"%d",itemId]];
}
@end
