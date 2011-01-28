//
//  PNItemModel.h
//  PankakuNet
//
//  Created by sota2 on 10/11/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

@interface PNItemModel : PNDataModel {
	NSString* _id;
	NSString* name;
	NSString* categoryId;
	NSString* description;
	NSString* icon_url;
	int64_t max_quantity;
	NSArray* screenshot_urls;
}
@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString *categoryId, *description, *icon_url;
@property (nonatomic, assign) int64_t max_quantity;
@property (nonatomic, retain) NSArray* screenshot_urls;
@end
