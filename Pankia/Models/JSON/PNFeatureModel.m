//
//  PNFeatureModel.m
//  PankakuNet
//
//  Created by sota2 on 10/10/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNFeatureModel.h"


@implementation PNFeatureModel
- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		if (aDictionary == nil) {
			return nil;
		}
		
		NSLog(@"%@", aDictionary);
	}
	return self;
}
@end
