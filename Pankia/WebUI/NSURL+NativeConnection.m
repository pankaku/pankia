//
//  NSURL+NativeConnection.m
//  PankakuNet
//
//  Created by あんのたん on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSURL+NativeConnection.h"
#import "NSDictionary+GetterExt.h"
#import "PNGameManager.h"
#import "PNSessionManager.h"
#import "PNLoggingConfig.h"
#import "PNLogger.h"
#import "PNWNativeController.h"
#import "PNNativeRequest.h"

NSString* const kPNPankiaProtocol = @"pankia://";
NSString* const kPankiaNativeConnectionWindowCloseNotification = @"PankiaNativeConnectionWindowCloseNotification";
NSString* const kPankiaNativeConnectionHideIndicatorNotification = @"PankiaNativeConnectionHideIndicatorNotification";
NSString* const kPankiaNativeConnectionShowIndicatorNotification = @"PankiaNativeConnectionShowIndicatorNotification";

@implementation NSURL (NativeConnection)

- (NSDictionary*)params
{
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	for (NSString* param in [[self query] componentsSeparatedByString:@"&"]) {
		NSArray* paramComponents = [param componentsSeparatedByString:@"="];
		if ([paramComponents count] >= 2) {
			NSString* paramName = [paramComponents objectAtIndex:0];
			NSString* paramValue = [paramComponents objectAtIndex:1];

			[params setObject:paramValue forKey:paramName];
		}
	}
	return params;
}

- (NSString*)navigationBarTitle
{
	NSDictionary* params = [self params];
	if ([params hasObjectForKey:@"nav_bar_title"]) {
		return [[params objectForKey:@"nav_bar_title"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	} else {
		return @" ";
	}
}

- (BOOL)isNativeRequest
{
	NSString* URLString = [self absoluteString];
	if ([URLString hasPrefix:kPNPankiaProtocol]) {
		return YES;
	}
	return NO;
}

- (BOOL)nativeActionWithWebView:(UIWebView *)aWebView {

	NSString* URLString = [self absoluteString];
	if ([URLString hasPrefix:kPNPankiaProtocol]) {
		PNNativeRequest* nativeRequest = [PNNativeRequest requestWithURL:self webView:aWebView];
		[nativeRequest run];
		return YES;
	}
	
	PNCLog(PNLOG_CAT_UI, @"Not supported URL");
	return NO;
}

@end
