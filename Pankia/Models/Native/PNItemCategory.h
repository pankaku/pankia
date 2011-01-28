//
//  PNItemCategory.h
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNModel.h"

@class PNItem;
@class PNItemCategoryModel;
@interface PNItemCategory : PNModel {
	NSString* _id;
	NSString* name;
}
@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* name;
- (id)initWithLocalDictionary:(NSDictionary*)aDictionary;
- (id)initWithItemCategoryModel:(PNItemCategoryModel*)model;
+ (PNItemCategory*)categoryWithId:(NSString*)categoryId;
- (NSArray*)items;
- (PNItem*)firstItem;
- (BOOL)isCoinCategory;
- (int)merchandiseCount;
@end
