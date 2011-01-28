//
//  PNMerchandise.h
//  PankakuNet
//
//  Created by sota2 on 10/12/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNModel.h"

@class PNItem;
@interface PNMerchandise : PNModel {
	NSString *productIdentifier, *name, *description, *item_id;
	int64_t multiple;
}
@property (nonatomic, retain) NSString *productIdentifier, *name, *description, *item_id;
@property (assign) int64_t multiple;
@property (readonly) PNItem* item;
- (BOOL)isBuyable;
@end
