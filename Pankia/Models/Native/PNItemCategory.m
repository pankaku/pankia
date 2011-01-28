//
//  PNItemCategory.m
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemCategory.h"
#import "PNParseUtil.h"
#import "PNItem.h"
#import "PNStoreManager.h"
#import "PNItemManager.h"
#import "PNItemCategoryModel.h"
#import "NSString+VersionString.h"
#import "PNGameManager.h"
#import "PNGlobalManager.h"

@implementation PNItemCategory
@synthesize id = _id, name;
- (id)initWithLocalDictionary:(NSDictionary*)aDictionary
{
	if (self = [super init]) {
		self.id = [aDictionary objectForKey:@"id"];
		self.name = [PNParseUtil localizedStringForKey:@"name" inDictionary:[aDictionary objectForKey:@"translations"] defaultValue:@" "];
	}
	return self;
}
- (id)initWithDataModel:(PNDataModel *)dataModel
{
	if (self = [super initWithDataModel:dataModel]) {
		PNItemCategoryModel* model = (PNItemCategoryModel*)dataModel;
		self.id = model.id;
		self.name = model.name;
	}
	return self;
}
- (id)initWithItemCategoryModel:(PNItemCategoryModel *)model
{
	return [self initWithDataModel:model];
}
+ (PNItemCategory*)categoryWithId:(NSString*)categoryId
{
	for (PNItemCategory* category in [[PNGameManager sharedObject] categories]) {
		if ([category.id isEqualToString:categoryId]) {
			return category;
		}
	}
	return nil;
}
- (BOOL)isCoinCategory
{
	// TODO: coin feature がオフの時の処理が必要です
	if(![[PNGlobalManager sharedObject] coinsEnabled]) return NO;
	
	PNItemCategory* coinCategory = [[[PNGameManager sharedObject] categories] objectAtIndex:0];
	return (self == coinCategory);
}
- (int)merchandiseCount
{
	int total = 0;
	for (PNItem* item in self.items) {
		total += [item.merchandises count];
	}
	return total;
}
- (NSArray*)items
{
	NSMutableArray* itemsInThisCategory = [NSMutableArray array];
	for (PNItem* item in [[PNGameManager sharedObject] items]) {	
		if ([item.categoryId isEqualToString:self.id]) {
			[itemsInThisCategory addObject:item];
		}
	}
	return itemsInThisCategory;
}
- (PNItem*)firstItem
{
	return ([[self items] count] > 0) ? [[self items] objectAtIndex:0] : nil;
}
- (void)dealloc
{
	self.id = nil;
	self.name = nil;
	[super dealloc];
}
@end
