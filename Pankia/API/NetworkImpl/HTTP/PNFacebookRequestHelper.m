//
//  PNFacebookRequestHelper.m
//  PankakuNet
//
//  Created by pankaku on 10/08/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNFacebookRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"

@implementation PNFacebookRequestHelper
+ (void)linkWithUid:(unsigned long long)uid sessionKey:(NSString*)sessionKey sessionSecret:(NSString*)sessionSecret delegate:(id)delegate selector:(SEL)selector key:(NSString*)key
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params setObject:sessionKey forKey:@"session_key"];
	[params setObject:sessionSecret forKey:@"session_secret"];
	[params setObject:[NSString stringWithFormat:@"%llu", uid] forKey:@"uid"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandFacebookLink
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];
}
+ (void)unlinkWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandFacebookUnlink
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];
}
+ (void)importGraphWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];	

	[[self class] requestWithCommand:kPNHTTPRequestCommandFacebookImport
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];
}
+ (void)verifyWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key
{
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	
	[[self class] requestWithCommand:kPNHTTPRequestCommandFacebookVerify
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params
							delegate:delegate
							selector:selector
						 callBackKey:key];
}
@end
