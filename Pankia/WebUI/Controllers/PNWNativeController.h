//
//  PNWNativeController.h
//  PankakuNet
//
//  Created by sota2 on 10/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNNativeRequest.h"
#import "PNError.h"
#import "PNHTTPResponse.h"

@interface PNWNativeController : NSObject {
	PNNativeRequest* request;
}
+ (Class)classFromControllerPath:(NSString*)path;
+ (NSString*)classNameFromControllerPath:(NSString*)path;
- (void)performRequest:(PNNativeRequest*)request;
- (void)defaultHTTPResponse:(PNHTTPResponse*)response;
- (void)asyncRequest:(NSString*)baseURL;
@end
