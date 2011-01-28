//
//  PNNativeRequest.h
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNWNativeController;
@class PNError;
@interface PNNativeRequest : NSObject {
	UIWebView*				webView_;
	NSString*				callbackMethodName;
	NSString*				selectorName;
	NSString*				response;
	NSDictionary*			params;
	NSURL*					url_;
	PNError*				error;
	PNWNativeController*	controller;	
	BOOL					isCancelled;
}
@property (nonatomic, retain) NSString* response;
@property (nonatomic, retain) PNError* error;
@property (nonatomic, retain) NSString* selectorName;
@property (nonatomic, retain) NSURL* url;
@property (readonly) NSDictionary* params;
@property (nonatomic, retain) UIWebView* webView;
- (id)initWithURL:(NSURL*)url webView:(UIWebView*)webView;
+ (id)requestWithURL:(NSURL*)url webView:(UIWebView*)webView;
- (void)run;
- (void)waitForServerResponse;
- (void)performCallback;
- (void)cancel;
- (void)setAsOK;
- (void)setAsNG;
- (void)setAsOKWithObject:(id)object forKey:(NSString*)key;
@end
