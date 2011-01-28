//
//  PNItem.m
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItem.h"
#import "NSDictionary+GetterExt.h"
#import "PNParseUtil.h"
#import "PNStoreManager.h"
#import "PNItemCategory.h"
#import "PNItemManager.h"
#import "PNMerchandise.h"
#import "PNFormatUtil.h"
#import "PNItemModel.h"
#import "NSString+VersionString.h"
#import "PNGameManager.h"

@implementation PNItem
@synthesize id = _id, iconUrl, categoryId, quantity, name, description, type, maxQuantity, screenshotUrls;

#pragma mark -
- (PNItemCategory*)category
{
	return [PNItemCategory categoryWithId:self.categoryId];
}
- (NSArray*)merchandises
{
	NSMutableArray* merchandises = [NSMutableArray array];
	for (PNMerchandise* merchandise in [[PNGameManager sharedObject] merchandises]) {
		if ([[self stringId] isEqualToString:[merchandise.item stringId]]) {
			[merchandises addObject:merchandise];
		}
	}
	return merchandises;
}

#pragma mark -
- (void)setDescription:(NSString *)value
{
	if (description != nil) {
		[description release];
		description = nil;
	}
	description = [[PNFormatUtil trimSpaces:value] retain];
}

- (NSString*)stringId
{
	return [NSString stringWithFormat:@"%d", self.id];
}

- (NSString*)excerpt
{
	return [[description componentsSeparatedByString:@"\n"] objectAtIndex:0];
}

- (BOOL)isCoin
{
	return [[self category] isCoinCategory];
}

#pragma mark Life cycle
- (id)init
{
	if (self = [super init]) {
		self.screenshotUrls = [NSArray array];
	}
	return self;
}
- (id) initWithDataModel:(PNDataModel *)dataModel
{
	if (self = [super initWithDataModel:dataModel]) {
		PNItemModel* model = (PNItemModel*)dataModel;
		self.id = [model.id intValue];
		self.name = model.name;
		self.description = model.description;
		self.iconUrl = model.icon_url;
		self.maxQuantity = model.max_quantity;
		self.screenshotUrls = model.screenshot_urls;
		self.categoryId = model.categoryId;
		
		if (self.maxQuantity <= 0) self.maxQuantity = LLONG_MAX;
	}
	return self;
}
- (id)initWithLocalDictionary:(NSDictionary*)dictionary
{
	if (self = [self init]) {
		self.id = [dictionary intValueForKey:@"id" defaultValue:0];
		self.iconUrl = [dictionary objectForKey:@"icon_url"];
		
		if ([dictionary hasObjectForKey:@"category_id"]) {
			self.categoryId = [dictionary objectForKey:@"category_id"];
		}
		
		self.name = [PNParseUtil localizedStringForKey:@"name" inDictionary:[dictionary objectForKey:@"translations"] 
																						defaultValue:@"-"];
		self.description = [PNParseUtil localizedStringForKey:@"description" inDictionary:[dictionary objectForKey:@"translations"] 
												 defaultValue:@""];
		if ([dictionary hasObjectForKey:@"max_quantity"]) {
			self.maxQuantity = [dictionary intValueForKey:@"max_quantity" defaultValue:0];
		}
		
		// begin - lerry added code
		if (self.maxQuantity <= 0) self.maxQuantity = LLONG_MAX;
		// end - lerry added code
	}
	return self;
}
- (id)initWithItemModel:(PNItemModel *)model
{
	return [self initWithDataModel:model];
}
- (void)updateFieldsFromDictionary:(NSDictionary*)aDictionary
{
	self.iconUrl = [aDictionary objectForKey:@"icon_url"];
	self.name = [aDictionary objectForKey:@"name"];
	self.description = [aDictionary objectForKey:@"description"];

	if ([aDictionary hasObjectForKey:@"max_quantity"]) {
		self.maxQuantity = [aDictionary intValueForKey:@"max_quantity" defaultValue:0];
	}
	if (self.maxQuantity <= 0) self.maxQuantity = LLONG_MAX;
	
	if ([aDictionary hasObjectForKey:@"screenshot_urls"]) {
		self.screenshotUrls = [aDictionary objectForKey:@"screenshot_urls"];
	}
}

+ (id)itemWithId:(int)identifier
{
	PNItem* item = [[PNItemManager sharedObject] itemWithIdentifier:[NSString stringWithFormat:@"%d", identifier]];
	return item;
}
- (void) dealloc
{
	self.iconUrl = nil;
	self.categoryId = nil;
	self.screenshotUrls = nil;
	[super dealloc];
}
@end
