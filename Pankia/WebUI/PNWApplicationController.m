//
//  PNWApplicationController.m
//  PankakuNet
//
//  Created by あんのたん on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWApplicationController.h"
#import "PNSessionManager.h"

@implementation PNWApplicationController

- (void)version
{
	request.response = [self getVersion];
}

- (void)information
{
	request.response = [[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]] objectForKey:[request.params objectForKey:@"plist_key"]] description];
}

- (void)basicInformation {
	request.response = [NSString stringWithFormat:@"{\"session\":\"%@\", \"version\":\"%@\"}", [PNSessionManager sharedObject].latestSessionId, [self getVersion]];
}

- (NSString *)getVersion {
	return [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]] objectForKey:@"CFBundleVersion"];
}

@end
