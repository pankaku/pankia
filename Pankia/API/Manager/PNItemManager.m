//
//  PNItemManager.m
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemManager.h"
#import "PNRequestKeyManager.h"
#import "PNItemRequestHelper.h"
#import "PNLogger+Package.h"
#import "Helpers.h"
#import "PNError.h"
#import "PNItemOwnershipModel.h"
#import "PNItemHistory.h"
#import "PNManager.h"
#import "PNItem.h"
#import "PNStoreManager.h"
#import "PNSettingManager.h"
#import "PNItemCategory.h"
#import "PNGameManager.h"
#import "PNUser.h"
#import "PNUser+Package.h"

static PNItemManager* _sharedInstance;

@interface PNItemManager ()
@property (nonatomic, retain) NSMutableDictionary* itemDictionary;
@property (nonatomic, retain) NSMutableDictionary* categoryDictionary;
@end

@interface PNItemManager (Private)
- (void)loadItemDetailsFromPlist;
- (void)updateItemOwnerships:(NSArray*)ownerships;
@end

@implementation PNItemManager
@synthesize itemArray, itemDictionary;
@synthesize categoryArray, categoryDictionary;

- (void)loadItemDetailsFromPlist
{
	NSMutableArray *items = [NSMutableArray array];
	self.itemDictionary = [NSMutableDictionary dictionary];
	
	NSArray* itemDictionaries = [[[PNSettingManager sharedObject] offlineSettings] objectForKey:@"items"];
	for (NSDictionary* dictionary in itemDictionaries) {
		PNItem* item = [[[PNItem alloc] initWithLocalDictionary:dictionary] autorelease];
		if (item != nil) {
			[items addObject:item];
			[itemDictionary setObject:item forKey:[item stringId]];
		}
	}
	PNCLog(PNLOG_CAT_ITEM, @"Items loaded from plist. %@ %@",itemDictionaries, items);
	self.itemArray = items;
}
- (void)loadCategoryDetailsFromPlist
{
	NSMutableArray *categories = [NSMutableArray array];
	self.categoryDictionary = [NSMutableDictionary dictionary];
	
	NSArray* categoryDictionaries = [[[PNSettingManager sharedObject] offlineSettings] objectForKey:@"categories"];
	for (NSDictionary* dictionary in categoryDictionaries) {
		PNItemCategory* category = [[[PNItemCategory alloc] initWithLocalDictionary:dictionary] autorelease];
		if (category != nil) {
			[categories addObject:category];
			[categoryDictionary setObject:category forKey:category.id];
		}
	}
	
	self.categoryArray = categories;
}

- (PNItem*)itemWithIdentifier:(NSString*)identifier
{
	for (PNItem* item in [[PNGameManager sharedObject] items]) {
		if ([identifier isEqualToString:[item stringId]]){
			return item;
		}
	}
	return nil;
}

- (void)updateItemFieldsFromServerDictionary:(NSDictionary*)dictionary
{
	NSString* identifier = [dictionary objectForKey:@"id"];
	PNItem* itemToUpdate = [PNItem itemWithId:[identifier intValue]];
	
	if (itemToUpdate == nil) {
		PNWarn(@"Error. Tried to update item with id (%@) but not found in PNOfflineSettings.plist", identifier);
		return;
	}
	
	[itemToUpdate updateFieldsFromDictionary:dictionary];
}

#pragma mark -
- (void)acquireItem:(NSString*)itemId quantity:(int)quantity delegate:(id)delegate
		onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	[self acquireItems:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:quantity], itemId, nil]
			  delegate:delegate onSucceeded:onSucceededSelector onFailed:onFailedSelector];
}
- (void)acquireItems:(NSDictionary*)items delegate:(id)delegate
		 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSMutableArray *itemIdArray = [NSMutableArray array];
	NSMutableArray *quantityArray = [NSMutableArray array];
	
	for (NSString* itemId in [items allKeys]) {
		[itemIdArray addObject:itemId];
		[quantityArray addObject:[items objectForKey:itemId]];
	}
	
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNItemRequestHelper acquireItems:itemIdArray quantities:quantityArray 
							 delegate:self selector:@selector(acquireItemResponse:) requestKey:requestKey];
}
- (void)acquireItemResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSDictionary*	json = [response jsonDictionary];
	NSString*		resp = [response jsonString];
	
	PNCLog(PNLOG_CAT_ITEM, @"PNItemManager.acquireItemResponse(): requestKey=", requestKey);
	
	if(response.isValidAndSuccessful) {
		NSArray* ownerships = [PNItemOwnershipModel dataModelsFromArray:[json objectForKey:J_OWNERSHIPS]];
		[self updateItemOwnerships:ownerships];
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:ownerships];
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		[PNRequestKeyManager callOnFailedSelectorAndRemove:requestKey withObject:error];
	}	
}

#pragma mark -
- (void)consumeItem:(NSString*)itemId quantity:(int)quantity delegate:(id)delegate
		onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	[self consumeItems:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:quantity], itemId, nil]
			  delegate:delegate onSucceeded:onSucceededSelector onFailed:onFailedSelector];
}
- (void)consumeItems:(NSDictionary*)items delegate:(id)delegate
		 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSMutableArray *itemIdArray = [NSMutableArray array];
	NSMutableArray *quantityArray = [NSMutableArray array];
	
	for (NSString* itemId in [items allKeys]) {
		[itemIdArray addObject:itemId];
		[quantityArray addObject:[items objectForKey:itemId]];
	}
	
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNItemRequestHelper consumeItems:itemIdArray quantities:quantityArray 
							 delegate:self selector:@selector(consumeItemResponse:) requestKey:requestKey];
}

- (void)consumeItemResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSDictionary*	json = [response jsonDictionary];
	NSString* resp		 = [response jsonString];
	
	if(response.isValidAndSuccessful) {
		NSArray* ownerships = [PNItemOwnershipModel dataModelsFromArray:[json objectForKey:J_OWNERSHIPS]];
		[self updateItemOwnerships:ownerships];
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:ownerships];
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		[PNRequestKeyManager callOnFailedSelectorAndRemove:requestKey withObject:error];
	}	
}

#pragma mark -

- (void)getItemOwnershipsFromServerWithOnSuccess:(void (^)(NSDictionary* ownerships))onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandItemOwnerships onSuccess:^(PNHTTPResponse* response) {
		if ([response isValidAndSuccessful]) {
			  // Parse json string -> PNItemOwnershipModels in an NSDictionary;
			  NSMutableDictionary *ownerships_ = [NSMutableDictionary dictionary];
			  for (NSDictionary* ownershipDictionary in [response.jsonDictionary objectForKey:J_OWNERSHIPS]) {
				  PNItemOwnershipModel* ownership = [PNItemOwnershipModel dataModelWithDictionary:ownershipDictionary];
				  if (ownership != nil) {
					  [ownerships_ setObject:ownership forKey:ownership.item_id];
				  }
			  }
			  onSuccess(ownerships_);
		  } else {
			  onFailure([PNError errorFromResponse:response.jsonString]);
		  }
	  } onFailure:onFailure];
}

- (NSArray*)itemOwnerships
{
	NSMutableArray* ownerships = [NSMutableArray array];
	for (PNItem* item in [[PNGameManager sharedObject] items]) {
		NSString* itemId = [NSString stringWithFormat:@"%d", item.id];
		int quantity = [[PNItemHistory sharedObject] currentQuantityForItemId:itemId];
		if (quantity > 0) {
			[ownerships addObject:[NSDictionary dictionaryWithObjectsAndKeys:itemId, @"item_id", [NSNumber numberWithInt:quantity], @"quantity", nil]];
		}
	}
	return ownerships;
}

#pragma mark -

- (void)updateItemOwnerships:(NSArray*)ownerships
{
	PNCLog(PNLOG_CAT_ITEM, @"update ownerships: %@", ownerships);
	for (PNItemOwnershipModel* ownership in ownerships) {
		PNCLog(PNLOG_CAT_ITEM, @" %@ -> %d", ownership.item_id, ownership.quantity);
	}
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		[self loadItemDetailsFromPlist];
		[self loadCategoryDetailsFromPlist];
	}
	return self;
}

- (void) dealloc
{
	self.itemDictionary = nil;
	self.itemArray = nil;
	self.categoryDictionary = nil;
	self.categoryArray = nil;
	[super dealloc];
}

+ (PNItemManager *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
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
