//
//  PNLobby.m
//  PankakuNet
//
//  Created by pankaku on 10/08/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLobby.h"
#import "PNLobbyModel.h"
#import "PNParseUtil.h"
#import "NSString+VersionString.h"

@implementation PNLobby
@synthesize lobbyId;
@synthesize name;
@synthesize membershipsCount;
@synthesize iconUrl;
@synthesize orderNumber;

+ (id)lobbyWithModel:(PNLobbyModel*)model {
	return [[[self alloc] initWithModel:model] autorelease];
}

- (id)initWithDataModel:(PNDataModel *)dataModel {
	if (self = [super initWithDataModel:dataModel]) {
		PNLobbyModel* model = (PNLobbyModel*)dataModel;
		self.lobbyId = model.id;
		self.name = model.name;
		self.membershipsCount = model.memberships_count;
		self.iconUrl = model.icon_url;
	}
	return self;
}

- (id)initWithModel:(PNLobbyModel*)model {
	return [self initWithDataModel:model];
}

- (id)initWithLocalDictionary:(NSDictionary *)aDictionary {
	if (self = [super init]) {
		self.lobbyId = [aDictionary intValueForKey:@"id" defaultValue:-1];
		NSDictionary* translations = [aDictionary objectForKey:@"translations"];
		self.name = [PNParseUtil localizedStringForKey:@"name" inDictionary:translations defaultValue:@"-"];
	}
	return self;
}

- (NSComparisonResult)compareOrderNumber:(PNLobby *)target {
	if (self.orderNumber > target.orderNumber ){
		return NSOrderedDescending;
	} else if (self.orderNumber < target.orderNumber){
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

- (void)dealloc {
	self.name = nil;
	self.iconUrl = nil;
	[super dealloc];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<PNLobby id=%d order=%d name=%@>", self.lobbyId, self.orderNumber, self.name];
}

- (NSComparisonResult)compareOrderId:(PNLobby *)target {
	if (self.orderNumber > target.orderNumber ){
		return NSOrderedDescending;
	} else if (self.orderNumber < target.orderNumber){
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

- (BOOL)hasIcon {
	return self.iconUrl != nil && [self.iconUrl length] > 0;
}

@end
