//
//  UIWebView+PankiaDashboardExtension.m
//  PankakuNet
//
//  Created by sota on 11/01/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIWebView+PankiaDashboardExtension.h"
#import "PNLocalResourceUtil.h"
#import "PNNativeRequest.h"

static BOOL useLocalFile = NO;

@implementation UIWebView(PankiaDashboardExtension)
- (void)loadDashboardURL:(NSURL*)url
{
	if (useLocalFile && [PNLocalResourceUtil isLocalResourceAvailableForURL:url]) {
		PNNativeRequest* request = [PNNativeRequest requestWithURL:url webView:nil];
		NSString* pathForHTMLFileForURL = [PNLocalResourceUtil pathForHTMLResourceForSelectorName:request.selectorName];
		[self loadDashboardURL:[NSURL fileURLWithPath:pathForHTMLFileForURL]];
	} else {
		if ([[url absoluteString] hasPrefix:@"file://"]) {
			[self loadHTMLStringForURL:url];
		} else {
			[self loadRequest:[NSURLRequest requestWithURL:url]];
		}
	}
}
- (void)loadHTMLStringForURL:(NSURL*)url
{
	[self loadHTMLString:[PNLocalResourceUtil HTMLStringValueForURL:url] 
				 baseURL:[NSURL fileURLWithPath:[kPNDashboardDefaultUIResourcesBaseDirectoryPath stringByAppendingPathComponent:@"html"]]];
}

@end
