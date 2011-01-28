//
//  PNIntrospectionRequestHelper.m
//  PankakuNet
//
//  Created by sota2 on 10/10/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNIntrospectionRequestHelper.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNAPIHTTPDefinition.h"

@implementation PNIntrospectionRequestHelper
+(void)sendReport:(NSString*)text level:(NSString*)level delegate:(id)delegate 
		 selector:(SEL)selector requestKey:(NSString*)key
{
	NSString* session = [PNUser currentUser].sessionId;
	if (session) {
		
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		[params setObject:session forKey:@"session"];
		[params setObject:text forKey:@"text"];
		[params setObject:level forKey:@"level"];
		
		[[self class] requestWithCommand:kPNHTTPRequestCommandIntrospectionReport
							 requestType:@"POST"
							   isMutable:YES
							  parameters:params
								delegate:delegate
								selector:selector
							 callBackKey:key];	
		
	}
}
@end
