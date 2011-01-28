//
//  PNGameRequestHelper.m
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGameRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNAPIHTTPDefinition.h"

@implementation PNGameRequestHelper
+ (void)getDetailsOfGame:(NSString*)gameId delegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:gameId forKey:@"game"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandGameShow
							 requestType:@"POST"
							   isMutable:YES
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];	
		
	}
}

+ (void)getCategoriesWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandGameCategories
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params 
								delegate:delegate
								selector:selector 
							 callBackKey:key];
	}
}
+ (void)getGradesWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandGameGrades
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params 
								delegate:delegate
								selector:selector 
							 callBackKey:key];
	}
}
+ (void)getItemsWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandGameItems 
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params 
								delegate:delegate
								selector:selector 
							 callBackKey:key];
	}
}
+ (void)getVersionsWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandGameVersions
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];
	}
}
@end
