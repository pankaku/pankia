//
//  PNWUserController.m
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWUserController.h"
#import "PNAPIHTTPDefinition.h"
#import "PNRequestKeyManager.h"
#import "PNSocialServiceConnector.h"

@implementation PNWUserController
- (void)block
{
	[self asyncRequest:kPNHTTPRequestCommandUserBlock];
}
- (void)find
{
	[self asyncRequest:kPNHTTPRequestCommandUserFind];
}
- (void)follow
{
	[self asyncRequest:kPNHTTPRequestCommandUserFollow];
}
- (void)followees
{
	[self asyncRequest:kPNHTTPRequestCommandUserFollowees];
}
- (void)followers
{
	[self asyncRequest:kPNHTTPRequestCommandUserFollowers];
}
- (void)secure
{
	[self asyncRequest:kPNHTTPRequestCommandUserSecure];
}
- (void)show
{
	[self asyncRequest:kPNHTTPRequestCommandUserShow];
}
- (void)unblock
{
	[self asyncRequest:kPNHTTPRequestCommandUserUnblock];
}
- (void)unfollow
{
	[self asyncRequest:kPNHTTPRequestCommandUserUnfollow];
}
- (void)update
{
	[self asyncRequest:kPNHTTPRequestCommandUserUpdate];
}
- (void)twitterIconUrl
{
	[request waitForServerResponse];
	[request retain];
	
	PNSocialServiceConnector* twitterConnector = [[[PNSocialServiceConnector alloc] init] autorelease];
	twitterConnector.delegate = self;
	[twitterConnector getIconURLFromTwitterWithId:[request.params objectForKey:@"user_id"]];
}
- (void)socialServiceConnectorDidReceiveTwitterIconURL:(NSString*)url
{
	//request.response = [NSString stringWithFormat:@"{\"url\" : \"", url, "\"}"];
	[request setAsOKWithObject:url forKey:@"url"];
	[request performCallback];
	[request release];
}

- (void)push {
	[self asyncRequest:kPNHTTPRequestCommandUserPush];
}

@end
