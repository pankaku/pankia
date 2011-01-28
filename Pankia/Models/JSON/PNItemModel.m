//
//  PNItemModel.m
//  PankakuNet
//
//  Created by sota2 on 10/11/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemModel.h"


@implementation PNItemModel
@synthesize id = _id, name;
@synthesize categoryId, description, icon_url, max_quantity, screenshot_urls;

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		self.id = [aDictionary stringValueForKey:@"id" defaultValue:@"-1"];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:@""];
		self.description = [aDictionary stringValueForKey:@"description" defaultValue:@""];
		self.icon_url = [aDictionary stringValueForKey:@"icon_url" defaultValue:@""];
		self.max_quantity = [aDictionary longLongValueForKey:@"max_quantity" defaultValue:-1];
		self.screenshot_urls = [aDictionary objectForKey:@"screenshot_urls"];
		self.categoryId = [aDictionary objectForKey:@"category_id"];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc{
	self.id = nil;
	self.name = nil;
	self.description = nil;
	self.icon_url = nil;
	self.categoryId = nil;
	self.screenshot_urls = nil;
	[super dealloc];
}
@end
