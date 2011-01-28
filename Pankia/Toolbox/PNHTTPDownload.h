//
//  PNHTTPDownload.h
//  HTTPDownload
//
//  Created by sota2 on 10/10/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNHTTPDownload;
@class PNHTTPResponse;
@class PNError;
@protocol PNHTTPDownloadDelegate
- (void)httpDownloadSucceeded:(PNHTTPDownload*)download;
- (void)httpDownloadFailed:(PNHTTPDownload*)download withError:(NSError*)error;
@end

@interface PNHTTPDownload : NSObject {
	id delegate;
	NSURLConnection* connection;
	NSMutableData* downloadedData;
	NSString* response;
	NSMutableArray* stoppableDownloads;
	NSDictionary* userInfo;
}
@property (nonatomic, retain) NSDictionary* userInfo;
@property (nonatomic, readonly) NSString* response;
- (void)cancel;
- (void)downloadFromURL:(NSString*)url delegate:(id<PNHTTPDownloadDelegate>)delegate;
+ (void)stopDownloads;


#pragma mark -
+ (void)asyncDownloadFromURL:(NSString*)urlString success:(void(^)(PNHTTPResponse*))successBlock
			 failure:(void(^)(PNError*))failureBlock;
@end
