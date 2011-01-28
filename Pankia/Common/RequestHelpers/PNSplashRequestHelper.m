//
//  PNSplashRequestHelper.m
//  PankiaLite
//
//  Created by sota2 on 10/10/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSplashRequestHelper.h"
#import "PNAPIHTTPDefinition.h"
#import "PNGlobalManager.h"

@implementation PNSplashRequestHelper
+ (void) sendAckToServerForSplashId:(int)splashId delegate:(id)delegate selector:(SEL)selector key:(NSString*)key
{
	NSString *session = [PNGlobalManager sharedObject].sessionId;
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:session, @"session",
							[NSString stringWithFormat:@"%d", splashId], @"id", nil];
	[[self class] requestWithCommand:kPNHTTPRequestCommandSplashAck
						 requestType:@"GET"
						   isMutable:NO
						  parameters:params 
							delegate:delegate
							selector:selector 
						 callBackKey:key];
}
+ (void) sendPingToServerForSplashId:(int)splashId targets:(NSArray*)targets 
							delegate:(id)delegate selector:(SEL)selector key:(NSString*)key
{
//33  	NSString *session = [PNGlobalManager sharedObject].sessionId;
//	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:session, @"session",
//							[NSString stringWithFormat:@"%d", splashId], @"id",
//							[targets componentsJoinedByString:@","], @"targets", nil];
	
//	[[PNHTTPRequestManager sharedObject] newRequestWithURL:kPNHTTPRequestCommandSplashPing 
//												  delegate:delegate onSucceeded:onSucceededSelector onFailed:onFailedSelector 
//													object:key];
//	[[self class] requestWithCommand:kPNHTTPRequestCommandSplashPing
//						  parameters:params delegate:delegate selector:selector callBackKey:key];
}
@end
