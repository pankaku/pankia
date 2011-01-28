//
//  PNSplash.m
//  PankakuNet
//
//  Created by sota2 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSplash.h"
#import "PNSplashModel.h"
#import "PNParseUtil.h"

@implementation PNSplash
@synthesize startAt, endAt, imageURL, linkURL, text, id = _id, isDebug, hasAppeared;

+ (PNSplash*)splashFromModel:(PNSplashModel*)model
{
	if (model == nil) return nil;
	
	PNSplash* anInstance = [[[PNSplash alloc] init] autorelease];
	anInstance.startAt = [PNParseUtil dateFromString:model.start_at];
	anInstance.endAt = [PNParseUtil dateFromString:model.end_at];
	anInstance.imageURL = model.image_url;
	anInstance.linkURL = model.link_url;
	anInstance.text = model.text;
	anInstance.id = model.id;
	anInstance.isDebug = model.is_debug;
	anInstance.hasAppeared = NO;
	
	return anInstance;
}

- (void)dealloc
{
	self.startAt = nil;
	self.endAt = nil;
	self.imageURL = nil;
	self.linkURL = nil;
	self.text = nil;
	[super dealloc];
}

- (BOOL)isValid
{
	if (imageURL != nil && ![imageURL isKindOfClass:[NSNull class]] &&
		linkURL != nil && ![linkURL isKindOfClass:[NSNull class]]) {
		return YES;
	} else {
		return NO;
	}

}

- (BOOL)isEqual:(id)object
{
	PNSplashModel* target = (PNSplashModel*)object;
	return (self.id == target.id);
}

#pragma mark NSCoding protocol

#pragma mark -

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:startAt forKey:kPNFieldNameForStartAt];
	[coder encodeObject:endAt forKey:kPNFieldNameForEndAt];
	[coder encodeObject:imageURL forKey:kPNFieldNameForImageURL];
	[coder encodeObject:linkURL forKey:kPNFieldNameForLinkURL];
	[coder encodeObject:text forKey:kPNFieldNameForText];
	[coder encodeObject:[NSNumber numberWithInt:_id] forKey:kPNFieldNameForId];
	[coder encodeObject:[NSNumber numberWithBool:isDebug] forKey:kPNFieldNameForIsDebug];
	[coder encodeObject:[NSNumber numberWithBool:hasAppeared] forKey:kPNFieldNameForHasAppeared];
}
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
	self.startAt = [decoder decodeObjectForKey:kPNFieldNameForStartAt];
	self.endAt = [decoder decodeObjectForKey:kPNFieldNameForEndAt];
	self.imageURL = [decoder decodeObjectForKey:kPNFieldNameForImageURL];
	self.linkURL = [decoder decodeObjectForKey:kPNFieldNameForLinkURL];
	self.text = [decoder decodeObjectForKey:kPNFieldNameForText];
	self.id = [[decoder decodeObjectForKey:kPNFieldNameForId] intValue];
	self.isDebug = [[decoder decodeObjectForKey:kPNFieldNameForIsDebug] boolValue];
	self.hasAppeared = [[decoder decodeObjectForKey:kPNFieldNameForHasAppeared] boolValue];
    return self;
}

@end
