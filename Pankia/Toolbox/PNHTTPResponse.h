//
//  PNHTTPResponse.h
//  PankakuNet
//
//  Created by Yujin TANG on 12/9/10.
//  Copyright 2010 Waseda University. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PNRequestObject;
@class PNError;
@interface PNHTTPResponse : NSObject {
	NSDictionary*	jsonDictionary;
	NSString*		jsonString;
	BOOL			isValidAndSuccessful;
	NSString*		requestKey;
	NSString*		requestUrl;
}

@property (retain) NSDictionary*	jsonDictionary;
@property (retain) NSString*		jsonString;
@property (retain) NSString*		requestKey;
@property (retain) NSString*		requestUrl;
@property (assign) BOOL				isValidAndSuccessful;
@property (readonly) PNRequestObject* request;
@property (readonly) PNError* error;

- (id) initWithRequestKey:(NSString*)key andJson:(NSString*)json;
- (id) initWithRequestURL:(NSString*)url Key:(NSString*)key andJson:(NSString*)json;
- (id) initWithJson:(NSString*)json;
+ (id) responseFromJson:(NSString*)json;
@end
