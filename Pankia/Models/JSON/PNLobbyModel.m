//
//  PNLobbyModel.m
//  PankakuNet
//
//  Created by pankaku on 10/08/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLobbyModel.h"

@implementation PNLobbyModel
@synthesize id = _id;
@synthesize name, icon_url, memberships_count;

- (id) init{
	if (self = [super init]){
		self.id = -1;
		self.name = @"";
		self.icon_url = @"";
		self.memberships_count = 0;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		self.id = [aDictionary intValueForKey:@"id" defaultValue:-1];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:@""];
		self.icon_url = [aDictionary stringValueForKey:@"icon_url" defaultValue:@""];
		self.memberships_count = [aDictionary intValueForKey:@"memberships_count" defaultValue:0];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

+ (NSArray*)dataModelsWithArray:(NSArray*)rawDataArray
{
	NSMutableArray *parsedModelsArray = [NSMutableArray array];
	for (NSDictionary* dictionary in rawDataArray) {
		[parsedModelsArray addObject:[self dataModelWithDictionary:dictionary]];
	}
	return parsedModelsArray;
}

- (void)dealloc{
	self.name = nil;
	self.icon_url = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n id:%d\n name:%@",
			NSStringFromClass([self class]),self,_id, name];
}
@end
