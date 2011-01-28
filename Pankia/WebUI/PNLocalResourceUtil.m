//
//  PNLocalResourceUtil.m
//  PankakuNet
//
//  Created by sota on 11/01/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNLocalResourceUtil.h"
#import "PNGlobal.h"
#import "PNNativeRequest.h"

@interface PNLocalResourceUtil()
+ (NSArray*)linkTagsIncludedInHTMLString:(NSString*)htmlString;
+ (NSArray*)scriptTagsIncludedInHTMLString:(NSString*)htmlString;
+ (NSString*)pathForCSSNamed:(NSString*)name;
+ (NSString*)pathForJavaScriptNamed:(NSString*)name;
@end

@implementation PNLocalResourceUtil

+ (BOOL)isLocalResourceAvailableForURL:(NSURL*)url
{
	NSLog(@"Url: %@", url);
	NSLog(@"pref: %@", kPNDashboardDefaultUIResourcesBaseDirectoryPath);
	if ([[url absoluteString] hasPrefix:kPNHomeScreenURL]) {
		PNNativeRequest* request = [PNNativeRequest requestWithURL:url webView:nil];
		if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathForHTMLResourceForSelectorName:request.selectorName]]) {
			return YES;
		} else {
			return NO;
		}
	} else if ([[url absoluteString] rangeOfString:kPNDashboardDefaultUIResourcesBaseDirectoryPath].length > 0) {
		NSLog(@"ooo");
		return NO;
	} else {
		return NO;
	}
}

+ (NSString*)pathForHTMLResourceForSelectorName:(NSString*)selectorName
{
	NSString* htmlDirectoryPath = [kPNDashboardDefaultUIResourcesBaseDirectoryPath stringByAppendingPathComponent:@"html"];
	return [htmlDirectoryPath stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.html", selectorName]];
}
+ (NSString*)pathForCSSNamed:(NSString*)name
{
	// ignore [?]
	NSString *fileName = [NSString stringWithString:name];
	if ([[fileName componentsSeparatedByString:@"?"] count] > 0) {
		fileName = [[fileName componentsSeparatedByString:@"?"] objectAtIndex:0];
	}
	
	// TODO: If custom ui theme is available, use it instead.
	
	NSString *cssDirectoryPath = kPNDashboardDefaultUIResourcesBaseDirectoryPath;
	return [[NSURL fileURLWithPath:[cssDirectoryPath stringByAppendingPathComponent:fileName]] absoluteString];
}
+ (NSString*)pathForJavaScriptNamed:(NSString*)name
{
	// ignore [?]
	NSString *fileName = [NSString stringWithString:name];
	if ([[fileName componentsSeparatedByString:@"?"] count] > 0) {
		fileName = [[fileName componentsSeparatedByString:@"?"] objectAtIndex:0];
	}
	
	// TODO: If custom ui theme is available, use it instead.
	
	NSString *jsDirectoryPath = kPNDashboardDefaultUIResourcesBaseDirectoryPath;
	return [[NSURL fileURLWithPath:[jsDirectoryPath stringByAppendingPathComponent:fileName]] absoluteString];
}

+ (NSString*)HTMLStringWithCSSImportTagAdjusted:(NSString*)source
{
	NSString* adjustedHTMLString = [NSString stringWithString:source];
	NSArray* linkTags = [self linkTagsIncludedInHTMLString:source];
	for (NSString* linkTag in linkTags) {
		NSString* src = [[[[linkTag componentsSeparatedByString:@"href=\""] objectAtIndex:1]
						  componentsSeparatedByString:@"\""] objectAtIndex:0];
		NSString* filePathInLocal = [self pathForCSSNamed:src];
		NSString* linkTagToReplace = [linkTag stringByReplacingOccurrencesOfString:src withString:filePathInLocal];
		adjustedHTMLString = [adjustedHTMLString stringByReplacingOccurrencesOfString:linkTag withString:linkTagToReplace];
	}
	return adjustedHTMLString;
}
+ (NSString*)HTMLStringWithJSImportTagAdjusted:(NSString*)source
{
	NSString* adjustedHTMLString = [NSString stringWithString:source];
	NSArray* scriptTags = [self scriptTagsIncludedInHTMLString:source];
	for (NSString* scriptTag in scriptTags) {
		NSString* src = [[[[scriptTag componentsSeparatedByString:@"src=\""] objectAtIndex:1]
						  componentsSeparatedByString:@"\""] objectAtIndex:0];
		NSString* filePathInLocal = [self pathForJavaScriptNamed:src];
		NSString* scriptTagToReplace = [scriptTag stringByReplacingOccurrencesOfString:src withString:filePathInLocal];
		adjustedHTMLString = [adjustedHTMLString stringByReplacingOccurrencesOfString:scriptTag withString:scriptTagToReplace];
	}
	return adjustedHTMLString;
}

+ (NSString*)HTMLStringValueForURL:(NSURL*)url
{
	NSString* rawHTMLString;
	if ([[url absoluteString] hasPrefix:@"file://"]) {
		rawHTMLString = [[[NSString alloc] initWithContentsOfURL:url] autorelease];
	} else {
		PNNativeRequest* request = [PNNativeRequest requestWithURL:url webView:nil];
		rawHTMLString = [[[NSString alloc] initWithContentsOfFile:[self pathForHTMLResourceForSelectorName:request.selectorName]] autorelease];
	}
	
	NSString* HTMLStringWithJSImportTagAdjusted = [self HTMLStringWithJSImportTagAdjusted:rawHTMLString];
	NSString* HTMLStringWithCSSImportTagAdjusted = [self HTMLStringWithCSSImportTagAdjusted:HTMLStringWithJSImportTagAdjusted];

	return HTMLStringWithCSSImportTagAdjusted;
}

#pragma mark -
+ (NSArray*)linkTagsIncludedInHTMLString:(NSString*)htmlString
{
	NSMutableArray* linkTags = [NSMutableArray array];
	
	static NSString* const prefix = @"<link href=\"/stylesheets/";
	static NSString* const suffix = @"type=\"text/css\" />";
	
	NSRange searchRange = NSMakeRange(1, [htmlString length] -1);
	while (1) {
		NSRange tagFoundAt = [htmlString rangeOfString:prefix options:NSCaseInsensitiveSearch range:searchRange];
		
		if (tagFoundAt.length > 0) {
			NSRange rangeToSearchSuffix;
			rangeToSearchSuffix.location = tagFoundAt.location + [prefix length];
			rangeToSearchSuffix.length  = [htmlString length] - rangeToSearchSuffix.location;
			
			NSRange rangeForSuffix = [htmlString rangeOfString:suffix options:NSCaseInsensitiveSearch range:rangeToSearchSuffix];
			NSRange rangeForTag = NSMakeRange(tagFoundAt.location, NSMaxRange(rangeForSuffix) - tagFoundAt.location);
			
			NSString* tagString = [htmlString substringWithRange:rangeForTag];
			[linkTags addObject:tagString];
			
			searchRange.location = tagFoundAt.location + 1;
			searchRange.length = [htmlString length] - searchRange.location;
		} else {
			break;
		}
	}
	
	return linkTags;
}
+ (NSArray*)scriptTagsIncludedInHTMLString:(NSString*)htmlString
{
	NSMutableArray* scriptTags = [NSMutableArray array];
	
	static NSString* const prefix = @"<script src=\"/javascripts/";
	static NSString* const suffix = @"</script>";
	
	NSRange searchRange = NSMakeRange(1, [htmlString length] -1);
	while (1) {
		NSRange tagFoundAt = [htmlString rangeOfString:prefix options:NSCaseInsensitiveSearch range:searchRange];
		
		if (tagFoundAt.length > 0) {
			NSRange rangeToSearchSuffix;
			rangeToSearchSuffix.location = tagFoundAt.location + [prefix length];
			rangeToSearchSuffix.length  = [htmlString length] - rangeToSearchSuffix.location;
			
			NSRange rangeForSuffix = [htmlString rangeOfString:suffix options:NSCaseInsensitiveSearch range:rangeToSearchSuffix];
			NSRange rangeForTag = NSMakeRange(tagFoundAt.location, NSMaxRange(rangeForSuffix) - tagFoundAt.location);
			
			NSString* tagString = [htmlString substringWithRange:rangeForTag];
			[scriptTags addObject:tagString];
			
			searchRange.location = tagFoundAt.location + 1;
			searchRange.length = [htmlString length] - searchRange.location;
		} else {
			break;
		}
	}
	
	return scriptTags;
}
@end
