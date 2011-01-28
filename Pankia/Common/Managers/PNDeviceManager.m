//
//  PNDeviceManager.m
//  PankiaLite
//
//  Created by sota2 on 10/10/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNDeviceManager.h"
#import "PNGlobalManager.h"
#import "PNHTTPRequestHelper.h"
#import "PNAPIHTTPDefinition.h"
#import "NSData+Utils.h"

@implementation PNDeviceManager

- (void)registerDeviceToken:(NSData*)token
{	
	[self retain];	//automatically released when response received.
	
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:[PNGlobalManager sharedObject].sessionId forKey:@"session"];
	[params setObject:[token stringWithHexBytes] forKey:@"push_token"];
	
#if kPNPushToken == kPNPushTokenDevelopment
	[params setObject:@"true" forKey:@"is_debug"];
#else
	[params setObject:@"false" forKey:@"is_debug"];
#endif
	
	NSString* key = @"PNRegisterPushToken";	// This method doesn't call back, so we don't create new request key.
	[PNHTTPRequestHelper requestWithCommand:kPNHttpRequestCommandDeviceRegisterPushToken
								requestType:@"GET"
								  isMutable:NO
								 parameters:params 
								   delegate:self
								   selector:@selector(registerDeviceTokenResponse:) 
								callBackKey:key];
}
- (void)registerDeviceTokenResponse:(NSNotification*)n
{
	[self release];
}

- (void)dealloc
{
	[super dealloc];
}
@end
