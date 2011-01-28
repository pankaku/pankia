//
//  PNNativeRequestManager.h
//  PankakuNet
//
//  Created by sota2 on 11/01/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNNativeRequest;
@interface PNNativeRequestManager : NSObject {
	NSMutableArray* pendingRequests;
}
+ (PNNativeRequestManager *)sharedObject;
- (void)pushRequest:(PNNativeRequest*)request;
- (void)pullRequest:(PNNativeRequest*)request;
- (void)cancelAllRequests;
@end
