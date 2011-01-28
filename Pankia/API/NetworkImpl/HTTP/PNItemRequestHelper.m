//
//  PNItemRequestHelper.m
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNManager.h"
#import "PNHTTPRequestHelper.h"
#import "Helpers.h"
#import "PNAPIHTTPDefinition.h"
#import "PNGlobalManager.h"

@implementation PNItemRequestHelper

+(void)acquireItems:(NSArray*)itemIdArray quantities:(NSArray*)quantities
		   delegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:[itemIdArray componentsJoinedByString:@","] forKey:@"items"];
		
		NSMutableArray* quantityStrings = [NSMutableArray array];
		for (NSNumber* quantity in quantities) {
			[quantityStrings addObject:[NSString stringWithFormat:@"%lld", [quantity longLongValue]]];
		}
		NSString* quantitiesString = [quantityStrings componentsJoinedByString:@","];
		
		[params setObject:quantitiesString forKey:@"quantities"];
		
		int dedupCounter = [PNUser countUpDedupCounter];
		[params setObject:[NSString stringWithFormat:@"%d",dedupCounter] forKey:@"dedup_counter"];
		
		[params setObject:[[PNUser currentUser] verifierStringWithGameSecret:[PNGlobalManager sharedObject].gameSecret]
				   forKey:@"verifier"];
		
		[[self class] requestWithCommand:kPNHTTPRequestCommandItemAcquire
							 requestType:@"POST"
							   isMutable:YES
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];	
		
	}
}
+(void)consumeItems:(NSArray*)itemIdArray quantities:(NSArray*)quantities
		   delegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:[itemIdArray componentsJoinedByString:@","] forKey:@"items"];
		
		NSMutableArray* quantityStrings = [NSMutableArray array];
		for (NSNumber* quantity in quantities) {
			[quantityStrings addObject:[NSString stringWithFormat:@"%lld", [quantity longLongValue]]];
		}
		NSString* quantitiesString = [quantityStrings componentsJoinedByString:@","];
		
		[params setObject:quantitiesString forKey:@"quantities"];
		
		int dedupCounter = [PNUser countUpDedupCounter];
		[params setObject:[NSString stringWithFormat:@"%d",dedupCounter] forKey:@"dedup_counter"];
		
		[params setObject:[[PNUser currentUser] verifierStringWithGameSecret:[PNGlobalManager sharedObject].gameSecret]
				   forKey:@"verifier"];
		
		[[self class] requestWithCommand:kPNHTTPRequestCommandItemConsume
							 requestType:@"POST"
							   isMutable:YES
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];	
		
	}
}

+(void)getItemOwnershipsWithDelegate:(id)delegate
							selector:(SEL)selector
						  requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandItemOwnerships
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];
		
	}
}
@end
