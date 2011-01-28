//
//  PNSplashModel.m
//  PankakuNet
//
//  Created by sota2 on 10/10/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSplashModel.h"

@implementation PNSplashModel
@synthesize start_at, end_at, image_url, link_url, text, id = _id, is_debug;

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		if (aDictionary == nil) {
			return nil;
		}
		
		self.start_at = [aDictionary objectForKey:kPNFieldNameForStartAt];
		self.end_at = [aDictionary objectForKey:kPNFieldNameForEndAt];
		self.image_url = [aDictionary objectForKey:kPNFieldNameForImageURL];
		self.link_url = [aDictionary objectForKey:kPNFieldNameForLinkURL];
		self.text = [aDictionary objectForKey:kPNFieldNameForText];
		self.id = [aDictionary intValueForKey:kPNFieldNameForId defaultValue:0];
		self.is_debug = [aDictionary boolValueForKey:kPNFieldNameForIsDebug defaultValue:NO];
	}
	return self;
}

- (void)dealloc
{
	self.start_at = nil;
	self.end_at = nil;
	self.image_url = nil;
	self.link_url = nil;
	self.text = nil;	
	[super dealloc];
}

@end
