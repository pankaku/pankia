//
//  PNItemCategoryModel.h
//  PankakuNet
//
//  Created by sota2 on 10/11/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

@interface PNItemCategoryModel : PNDataModel {
	NSString* _id;
	NSString* name;
}
@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* name;
@end
