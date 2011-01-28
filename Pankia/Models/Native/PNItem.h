//
//  PNItem.h
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNModel.h"

typedef enum {
	PNConsumable,
	PNSubscription
} PNItemType;

@class PNItemCategory;
@class PNItemModel;
@interface PNItem : PNModel {
	int _id;
	NSString* iconUrl;
	NSString* categoryId;
	NSString* name;
	NSString* description;
	int64_t quantity;
	PNItemType type;
	int64_t maxQuantity;
	NSArray* screenshotUrls;
}
@property (nonatomic, assign) int id;
@property (nonatomic, retain) NSString* iconUrl;
@property (nonatomic, retain) NSString* categoryId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, assign) int64_t quantity;
@property (nonatomic, assign) int64_t maxQuantity;
@property (nonatomic, assign) PNItemType type;
@property (nonatomic, retain) NSArray* screenshotUrls;

@property (nonatomic, readonly) NSArray* merchandises;
@property (nonatomic, readonly) PNItemCategory* category;
@property (nonatomic, readonly) NSString* excerpt;

- (id)initWithLocalDictionary:(NSDictionary*)aDictionary;
- (id)initWithItemModel:(PNItemModel*)model;
+ (id)itemWithId:(int)identifier;
- (NSString*)stringId;
- (void)updateFieldsFromDictionary:(NSDictionary*)aDictionary;
- (BOOL)isCoin;
@end
