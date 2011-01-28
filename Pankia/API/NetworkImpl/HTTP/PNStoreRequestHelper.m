//
//  PNStoreRequestHelper.m
//  PankakuNet
//
//  Created by sota on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNStoreRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNManager.h"
#import "PNHTTPRequestHelper.h"
#import "Helpers.h"
#import "PNLogger+Package.h"
#import "PNAPIHTTPDefinition.h"
#import "PNGlobalManager.h"

@implementation PNStoreRequestHelper
+(void)registerReceipt:(NSString*)receipt
				 price:(float)price
				locale:(NSString*)locale
			  delegate:(id)delegate
			  selector:(SEL)selector
			requestKey:(NSString*)key
{
	PNCLog(PNLOG_CAT_ITEM, @"registerReceipt");
	
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:receipt forKey:@"receipt"];
		[params setObject:[NSString stringWithFormat:@"%.2f", price] forKey:@"price"];
		[params setObject:locale forKey:@"locale"];
		
		int dedupCounter = [PNUser countUpDedupCounter];
		[params setObject:[NSString stringWithFormat:@"%d",dedupCounter] forKey:@"dedup_counter"];

		[params setObject:[[PNUser currentUser] verifierStringWithGameSecret:[PNGlobalManager sharedObject].gameSecret]
				   forKey:@"verifier"];
		
		[[self class] requestWithCommand:kPNHTTPRequestCommandPurchaseRegister
							 requestType:@"POST"
							   isMutable:YES
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];	
		
	}
}
+(void)getMerchandisesWithDelegate:(id)delegate
						  selector:(SEL)selector
						requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandGameMerchandises
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];
		
	}
}
+(void)getPurchaseHistoryWithOffset:(int)offset
							  limit:(int)limit
						   delegate:(id)delegate
						   selector:(SEL)selector
						 requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
		[params setObject:[NSString stringWithFormat:@"%d", limit] forKey:@"limit"];
		[[self class] requestWithCommand:kPNHTTPRequestCommandPurchaseHistory
							 requestType:@"GET"
							   isMutable:NO
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];
		
	}
}
@end
