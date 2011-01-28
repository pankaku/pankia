//
//  PNItemOwnershipModel.m
//  PankakuNet
//
//  Created by sota on 10/08/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemOwnershipModel.h"
#import "NSDictionary+GetterExt.h"

@implementation PNItemOwnershipModel
@synthesize quantity, item_id;

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (self = [self init]) {
		self.quantity = [aDictionary longLongValueForKey:@"quantity" defaultValue:0];
		self.item_id = [aDictionary objectForKey:@"item_id"];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}



- (void)dealloc
{
	// begin - lerry modified
	[self setItem_id:nil];
	// end - lerry modified
	[super dealloc];
	//self.item_id = nil;
}
@end
