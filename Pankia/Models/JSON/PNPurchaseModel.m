//
//  PNPurchaseModel.m
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNPurchaseModel.h"
#import "NSDictionary+GetterExt.h"

@implementation PNPurchaseModel
@synthesize merchandise_id, locale, purchase_date, price;

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (self = [self init]) {
		self.merchandise_id = [aDictionary objectForKey:@"merchandise_id"];
		self.locale = [aDictionary objectForKey:@"locale"];
		self.purchase_date = [aDictionary objectForKey:@"purchase_date"];
		self.price = [aDictionary floatValueForKey:@"price" defaultValue:0.0f];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	self.merchandise_id = nil;
	self.locale = nil;
	self.purchase_date = nil;
	[super dealloc];
}

@end
