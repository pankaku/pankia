//
//  PNWItemController.m
//  PankakuNet
//
//  Created by sota2 on 11/01/06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNWItemController.h"
#import "PNAPIHTTPDefinition.h"
#import "PNItemManager.h"

@implementation PNWItemController
- (void)ownerships
{
	if ([request.params objectForKey:@"user"] == nil && [request.params objectForKey:@"game"] == nil) {
		[request setAsOKWithObject:[[PNItemManager sharedObject] itemOwnerships] forKey:@"ownerships"];
	} else {
		[self asyncRequest:kPNHTTPRequestCommandItemOwnerships];
	}	
}
@end
