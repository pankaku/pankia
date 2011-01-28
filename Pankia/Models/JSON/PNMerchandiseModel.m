//
//  PNMerchandisesModel.m
//  PankakuNet
//
//  Created by sota on 10/09/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMerchandiseModel.h"
#import "NSDictionary+GetterExt.h"
#import "PNItem.h"
#import "PNItemHistory.h"

@implementation PNMerchandiseModel
@synthesize id = _id, name, item_id, description, itemDictionary, multiple;

#pragma mark NSCoding protocols

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_id forKey:@"id"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:item_id forKey:@"item_id"];
	[coder encodeObject:description forKey:@"description"];
	[coder encodeInt64:multiple forKey:@"multiple"];
}
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
	self.id = [decoder decodeObjectForKey:@"id"];
	self.name = [decoder decodeObjectForKey:@"name"];
	self.item_id = [decoder decodeObjectForKey:@"item_id"];
	self.description = [decoder decodeObjectForKey:@"description"];
	self.multiple = [decoder decodeInt64ForKey:@"multiple"];
    return self;
}

#pragma mark -

- (PNItem*)item
{
	return [PNItem itemWithId:[self.item_id intValue]];
}

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (self = [super initWithDictionary:aDictionary]) {
		self.id = [aDictionary objectForKey:@"id"];
		self.name = [aDictionary objectForKey:@"name"];
		self.description = [aDictionary objectForKey:@"description"];
		
		if ([aDictionary hasObjectForKey:@"item"]) {
			self.itemDictionary = [aDictionary objectForKey:@"item"];
			self.item_id = [[aDictionary objectForKey:@"item"] objectForKey:@"id"];
		}
		
		self.multiple = [aDictionary intValueForKey:@"multiple" defaultValue:1];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	self.id = nil;
	self.name = nil;
	self.item_id = nil;
	self.itemDictionary = nil;
	[super dealloc];
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
