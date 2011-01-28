//
//  PNWNativeController.m
//  PankakuNet
//
//  Created by sota2 on 10/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWNativeController.h"
#import "PNNativeRequest.h"
#import "NSURL+NativeConnection.h"
#import "PNRequestKeyManager.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNHTTPRequestHelper.h"
#import "PNNativeRequestManager.h"

@implementation PNWNativeController
+ (Class)classFromControllerPath:(NSString*)path
{
	return NSClassFromString([self classNameFromControllerPath:path]);
}
+ (NSString*)classNameFromControllerPath:(NSString*)path
{
	return [NSString stringWithFormat:@"PNW%@%@Controller",
			[[path substringToIndex:1] capitalizedString],
			[path substringFromIndex:1]];
}
- (void)performRequest:(PNNativeRequest*)aRequest
{
	SEL selector = NSSelectorFromString(aRequest.selectorName);
	if ([self respondsToSelector:selector]) {
		request = aRequest;
		[self performSelector:selector];
		return;
	} else {
		aRequest.error = [[[PNError alloc] initWithCode:@"unrecognized_selector" message:[NSString stringWithFormat:@"Unrecognized selector. %@", aRequest.selectorName]] autorelease];
	}

}
- (void)defaultHTTPResponse:(PNHTTPResponse*)response
{
	request.response = response.jsonString;
	[[PNNativeRequestManager sharedObject] pullRequest:request];
	[request performCallback];
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:response.requestKey];	
}
- (void)asyncRequest:(NSString*)baseURL
{
	[[PNNativeRequestManager sharedObject] pushRequest:request];
	[request waitForServerResponse];
	
	// Merge parameters
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:request.params];
	if ([PNUser currentUser].sessionId)
		[params setObject:[PNUser currentUser].sessionId forKey:@"session"];
	[params removeObjectForKey:@"guid"];
	
	NSString* requestKey = [PNRequestKeyManager registerDelegate:self onSucceededSelector:nil onFailedSelector:nil withObject:request];
	[PNHTTPRequestHelper requestWithCommand:baseURL requestType:@"GET" isMutable:NO
								 parameters:params delegate:self selector:@selector(defaultHTTPResponse:) callBackKey:requestKey];
}
@end
