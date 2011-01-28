//
//  PNFacebookAccountModel.m
//  PankakuNet
//
//  Created by pankaku on 10/08/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNFacebookAccountModel.h"
#import "PNLogger.h"

@implementation PNFacebookAccountModel
@synthesize id = _id, name;

- (id) init{
	if (self = [super init]){
		self.id = -1;
		self.name = @"";
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.id = [aDictionary longLongValueForKey:@"id" defaultValue:-1];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:@""];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc{
	self.name = nil;
	[super dealloc];
}

@end
