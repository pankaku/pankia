//
//  PNLobbyModel.h
//  PankakuNet
//
//  Created by pankaku on 10/08/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

@interface PNLobbyModel : PNDataModel {
	int _id;
	NSString* name;
	NSString* icon_url;
	int memberships_count;
}

@property (assign) NSInteger id;
@property (retain) NSString* name;
@property (retain) NSString* icon_url;
@property (assign) NSInteger memberships_count;

+ (NSArray*)dataModelsWithArray:(NSArray*)rawDataArray;
@end
