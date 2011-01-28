//
//  PNMerchandise.m
//  PankakuNet
//
//  Created by sota2 on 10/12/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMerchandise.h"
#import "PNMerchandiseModel.h"
#import "PNItem.h"
#import "PNItemHistory.h"

@implementation PNMerchandise
@synthesize productIdentifier, name, description, item_id, multiple;
- (id)initWithDataModel:(PNDataModel *)dataModel
{
	if (self = [super initWithDataModel:dataModel]) {
		PNMerchandiseModel* model = (PNMerchandiseModel*)dataModel;
		self.productIdentifier = model.id;
		self.name = model.name;
		self.description = model.description;
		self.item_id = model.item_id;
		self.multiple = model.multiple;
	}
	return self;
}

- (void)dealloc
{
	self.productIdentifier = nil;
	self.name = nil;
	self.description = nil;
	self.item_id = nil;
	[super dealloc];
}
#pragma mark -
- (PNItem*)item
{
	return [PNItem itemWithId:[self.item_id intValue]];
}
- (BOOL)isBuyable
{
	PNItem* item = self.item;
	
	//maxQuantity = 無限のものは無条件で購入可能
	if (item.maxQuantity < 0) return YES;
	
	int64_t currentQuantity = [[PNItemHistory sharedObject] currentQuantityForItemId:[item stringId]];
	return (currentQuantity + self.multiple <= item.maxQuantity);
}
@end
