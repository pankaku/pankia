//
//  PNItemCategoryModel.m
//  PankakuNet
//
//  Created by sota2 on 10/11/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemCategoryModel.h"


@implementation PNItemCategoryModel
@synthesize id = _id, name;

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		self.id = [aDictionary stringValueForKey:@"id" defaultValue:@"-1"];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:@""];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc{
	self.id = nil;
	self.name = nil;
	[super dealloc];
}
@end
