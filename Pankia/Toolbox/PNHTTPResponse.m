//
//  PNHTTPResponse.m
//  PankakuNet
//
//  Created by Yujin TANG on 12/9/10.
//  Copyright 2010 Waseda University. All rights reserved.
//

#import "PNHTTPResponse.h"
#import "JsonHelper.h"
#import "PNRequestKeyManager.h"
#import "PNError.h"

@implementation PNHTTPResponse
@synthesize jsonDictionary, jsonString, requestKey, requestUrl, isValidAndSuccessful;

- (PNRequestObject*)request
{
	return [PNRequestKeyManager requestForKey:self.requestKey];
}
- (PNError*)error
{
	return [PNError errorFromResponse:self.jsonString];
}

- (id) initWithRequestKey:(NSString *)key andJson:(NSString *)json
{
	return [self initWithRequestURL:nil Key:key andJson:json];
}

- (id) initWithRequestURL:(NSString*)url Key:(NSString*)key andJson:(NSString*)json
{
	if (self = [super init]) {
		self.jsonString = json;
		self.jsonDictionary = [json JSONValue];
		self.requestKey = key;
		self.requestUrl = url;
		self.isValidAndSuccessful = (jsonDictionary && [JsonHelper isValid:jsonDictionary] && [JsonHelper isApiSuccess:jsonDictionary]);
	}
	return self;
}
- (id) initWithJson:(NSString*)json
{
	if (self = [super init]) {
		self.jsonString = json;
		self.jsonDictionary = [json JSONValue];
		self.isValidAndSuccessful = (jsonDictionary && [JsonHelper isValid:jsonDictionary] && [JsonHelper isApiSuccess:jsonDictionary]);
	}
	return self;	
}
+ (id) responseFromJson:(NSString*)json
{
	PNHTTPResponse* anInstance = [[[PNHTTPResponse alloc] initWithJson:json] autorelease];
	return anInstance;
}
- (void) dealloc
{
	[jsonDictionary release];
	jsonDictionary = nil;
	[jsonString release];
	jsonString = nil;
	[requestKey release];
	requestKey = nil;
	[requestUrl release];
	requestUrl = nil;
	[super dealloc];
}

@end
