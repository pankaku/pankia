//
//  PNLobby.h
//  PankakuNet
//
//  Created by pankaku on 10/08/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNModel.h"

@class PNLobbyModel;

@interface PNLobby : PNModel {
	int lobbyId;
	NSString *name;
	NSString *iconUrl;
	int membershipsCount;
	int orderNumber;
}

+ (id)lobbyWithModel:(PNLobbyModel*)model;
- (id)initWithModel:(PNLobbyModel*)model;
- (id)initWithLocalDictionary:(NSDictionary*)dictionary;
- (BOOL)hasIcon;

@property (assign) int lobbyId;
@property (retain) NSString* name;
@property (assign) int membershipsCount;
@property (retain) NSString* iconUrl;
@property (assign) int orderNumber;

@end
