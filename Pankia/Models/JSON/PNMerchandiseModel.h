//
//  PNMerchandisesModel.h
//  PankakuNet
//
//  Created by sota on 10/09/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

@class PNItem;
@interface PNMerchandiseModel : PNDataModel <NSCoding> {
	NSString* _id;	
	NSString* name;
	NSString* item_id;
	NSString* description;
	NSDictionary* itemDictionary;
	int64_t multiple;
}
@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* item_id;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSDictionary* itemDictionary;
@property (nonatomic, assign) int64_t multiple;
@property (readonly) PNItem* item;
- (BOOL)isBuyable;
@end
