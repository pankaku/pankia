//
//  PNItemOwnershipModel.h
//  PankakuNet
//
//  Created by sota on 10/08/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

@interface PNItemOwnershipModel : PNDataModel {
	int64_t quantity;
	NSString* item_id;
}
@property (nonatomic, assign) int64_t quantity;
@property (nonatomic, retain) NSString* item_id;
@end
