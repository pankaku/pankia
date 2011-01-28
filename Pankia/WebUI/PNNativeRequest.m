//
//  PNNativeRequest.m
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNNativeRequest.h"
#import "PNWNativeController.h"
#import "NSURL+NativeConnection.h"
#import "PNError.h"
#import "PNLogger.h"
#import "PNLoggingConfig.h"
#import "NSObject+SBJSON.h"
#import "PNGlobal.h"

#define kPNNativeConnectionJSONForStatusOK @"{'status':'ok'}"
#define kPNNativeConnectionJSONForStatusNG @"{'status':'ng'}"

#define kPNNativeConnectionWaitingForServerResponse @"wait_for_server_response"

@interface PNNativeRequest()
@property (nonatomic, retain) NSString* callbackMethodName;
@property (nonatomic, retain) PNWNativeController* controller;
- (void)parseURL;
@end

@implementation PNNativeRequest
@synthesize url = url_, webView = webView_, callbackMethodName, controller, selectorName, error, response;

- (id)initWithURL:(NSURL*)url webView:(UIWebView*)webView
{
	if (self = [super init]) {
		self.url = url;
		self.webView = webView;
		[self parseURL];
	}
	return self;
}

- (void)dealloc
{
	self.url = nil;
	self.callbackMethodName = nil;
	self.webView = nil;
	self.controller = nil;
	self.selectorName = nil;
	[super dealloc];
}

+ (id)requestWithURL:(NSURL *)url webView:(UIWebView *)webView
{
	return [[[self alloc] initWithURL:url webView:webView] autorelease];
}



#pragma mark -

- (void)parseURL
{
	NSArray* pathComponents = [[self.url path] componentsSeparatedByString:@"/"];
	NSString* controllerPath = [pathComponents objectAtIndex:1];
	if ([pathComponents count] > 2) {
		self.selectorName = [pathComponents objectAtIndex:2];
	} else {
		self.selectorName = @"index";
	}

	
	Class controllerClass = [PNWNativeController classFromControllerPath:controllerPath];
	if (controllerClass != nil) {
		self.controller = (PNWNativeController*)[[[controllerClass alloc] init] autorelease];
	} else {
		PNWarn(@"WebUIError: Controller(%@) not found. Does %@ exist in the build target?",controllerPath, [PNWNativeController classNameFromControllerPath:controllerPath]);
	}
	
	self.callbackMethodName = [[self.url params] objectForKey:@"guid"];
}

- (void)performCallback
{
	if (isCancelled) return;	// If request was cancelled, don't callback.
	
	if (!self.callbackMethodName) {
		PNCLog(PNLOG_CAT_UI, @"No Callback method");
		return;
	}
#ifdef PNWUsingJQuery
	NSString* jsString = [NSString stringWithFormat:@"PankiaConnect._postMessage(%@,\"%@\");",self.callbackMethodName, 
						  [[response stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] 
						   stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
#else
	NSString* jsString = [NSString stringWithFormat:@"PankiaConnect._postMessage(%@,\"%@\".evalJSON())",self.callbackMethodName, 
						  [[response stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] 
						   stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
#endif
	NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:jsString];
	PNCLog(PNLOG_CAT_UI, @"jsString: %@", jsString);
	PNCLog(PNLOG_CAT_UI, @"result: %@", result);
	result = nil;	// This is for build warning.
}
- (void)run
{
	if (controller != nil) {
		[controller performRequest:self];
		
		if (error == nil) {
			[self performCallback];
			return;
		}
		
		if ([error.errorCode isEqualToString:kPNNativeConnectionWaitingForServerResponse]) {
			
		} else {
			PNWarn(@"NativeConnection error. %@", error);
		}
	} else {
		PNWarn(@"No controller.");
	}	
}
- (void)waitForServerResponse
{
	self.error = [[[PNError alloc] initWithCode:kPNNativeConnectionWaitingForServerResponse message:@"Waiting for server response."] autorelease];
}

- (NSDictionary*)params
{
	return [self.url params];
}

- (void)cancel
{
	isCancelled = YES;
}

- (void)setAsOK
{
	self.response = kPNNativeConnectionJSONForStatusOK;
}

- (void)setAsOKWithObject:(id)object forKey:(NSString*)key
{
	NSDictionary* responseDictionary = 
	[NSDictionary dictionaryWithObjectsAndKeys:@"ok", @"status", object, key, nil];
	self.response = [responseDictionary JSONRepresentation];
}

- (void)setAsNG
{
	self.response = kPNNativeConnectionJSONForStatusNG;
}

@end
