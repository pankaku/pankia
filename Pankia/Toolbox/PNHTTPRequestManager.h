//
//  PNHTTPRequestManager.h
//  PankiaLite
//
//  Created by sota2 on 10/10/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNHTTPDownload.h"
#import "PNHTTPService.h"

@protocol PNHTTPRequestManagerDelegate
- (void)httpRequestForKey:(NSString*)requestKey failedWithError:(NSError*)error;
@end

@interface PNHTTPRequestManager : NSObject <PNHTTPDownloadDelegate> {
	// begin - lerry added code
	NSMutableArray *requestList;
	// end - lerry added code
}
// begin - lerry added code
@property (retain) NSMutableArray *requestList;
// end - lerry added code
- (void)newRequestWithURL:(NSString*)url delegate:(id<PNHTTPRequestManagerDelegate>)delegate selector:(SEL)selector object:(id)object;
+ (PNHTTPRequestManager*)sharedObject;
// begin - lerry added code
- (void)bufferRequest:(PNHTTPService*)request;
- (void)cancelRequest:(PNHTTPService*)request;
- (void)clearRequests;
// end - lerry added code
@end
