//
//  PNHTTPDownload.m
//  HTTPDownload
//
//  Created by sota2 on 10/10/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNHTTPDownload.h"
#import "PNHTTPResponse.h"
#import "PNError.h"
#import "PNLogger.h"
#import "PNStandardLoggingConfig.h"

static PNHTTPDownload* _sharedInstance;

@interface PNHTTPDownload()
@property (nonatomic, retain) id<PNHTTPDownloadDelegate> delegate;
@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSMutableData* downloadedData;
@property (nonatomic, retain) NSMutableArray* stoppableDownloads;
@property (nonatomic, assign) int requestNumber;
+ (PNHTTPDownload*)sharedObject;
- (void)callSucceededSelector;
- (void)callFailedSelectorWithError:(NSError*)error;
- (void)setResponse:(NSString*)value;
- (void)startDownloadWithURL:(NSString*)url;
- (void)stopDownloads;
@end

@implementation PNHTTPDownload
@synthesize connection, delegate, downloadedData, requestNumber, response, stoppableDownloads, userInfo;
- (id) init
{
	if (self = [super init]) {
		self.downloadedData = [NSMutableData data];
	}
	return self;
}
+ (PNHTTPDownload*)sharedObject
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [[PNHTTPDownload alloc] init];
			_sharedInstance.stoppableDownloads = [NSMutableArray array];
		}
	}
	return _sharedInstance;
}
#pragma mark -
- (void)startDownloadWithURL:(NSString*)url
{
	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] 
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:15.0f];
	self.connection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
}
- (void)downloadFromURL:(NSString*)url delegate:(id<PNHTTPDownloadDelegate>)aDelegate
{
	self.delegate = aDelegate;
	[self retain];
	[[PNHTTPDownload sharedObject].stoppableDownloads addObject:self];
	[self startDownloadWithURL:url];
}
- (void)cancel
{
	if (self.connection != nil) {
		[connection cancel];
	}
	NSError* error = [NSError errorWithDomain:@"PNHTTPDownload" code:-1 userInfo:nil];
	[self callFailedSelectorWithError:error];
}
+ (void)stopDownloads
{
	[[PNHTTPDownload sharedObject] stopDownloads];
}
- (void)stopDownloads
{
	@synchronized (self) {
		NSArray* downloadsToCancel = [stoppableDownloads copy];
		for(PNHTTPDownload* download in downloadsToCancel) {
			[download cancel];
		}
		[downloadsToCancel release];
	}
}
#pragma mark -
- (void)callSucceededSelector
{
	if (delegate != nil) {
		if ([delegate respondsToSelector:@selector(httpDownloadSucceeded:)]) {
			[delegate httpDownloadSucceeded:self];
		}
	}
	[[PNHTTPDownload sharedObject].stoppableDownloads removeObject:self];
	[self autorelease];
}
- (void)callFailedSelectorWithError:(NSError*)error
{
	if (delegate != nil && error != nil) {
		if ([delegate respondsToSelector:@selector(httpDownloadFailed:withError:)]) {
			[delegate httpDownloadFailed:self withError:error];
		}
	}
	[[PNHTTPDownload sharedObject].stoppableDownloads removeObject:self];
	[self autorelease];
}
#pragma mark -
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    [downloadedData appendData:d];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self setResponse:[[[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding] autorelease]];
	[self callSucceededSelector];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self callFailedSelectorWithError:error];
}
#pragma mark -
- (void)setResponse:(NSString*)value
{
	if (response != nil) {
		[response release];
		response = nil;
	}
	if (value) {
		response = [value retain];
	}
}
- (void)dealloc
{
	self.downloadedData = nil;
	self.delegate = nil;
	self.connection = nil;
	self.userInfo = nil;
	[self setResponse:nil];
	[super dealloc];
}

#pragma mark -
+ (void)asyncDownloadFromURL:(NSString*)urlString success:(void(^)(PNHTTPResponse*))successBlock
					 failure:(void(^)(PNError*))failureBlock
{
	NSDictionary* params = [[NSDictionary dictionaryWithObjectsAndKeys:urlString, @"urlString",
							 Block_copy(successBlock), @"successBlock",
							 Block_copy(failureBlock), @"failureBlock", nil] retain];
	[NSThread detachNewThreadSelector:@selector(downloadInBackground:) toTarget:[self class]
						   withObject:params];
	
}
+ (void)downloadInBackground:(NSDictionary*)params
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* urlString = [params objectForKey:@"urlString"];
	PNCLog(PNLOG_CAT_HTTP_REQUEST, @"[HTTPRequest]%@", urlString);
	
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];  
	NSMutableDictionary* resultDictionary = [NSMutableDictionary dictionaryWithDictionary:params];

	if (error) {
		[resultDictionary setObject:error forKey:@"error"];
	} else {
		NSString* resultString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		[resultDictionary setObject:resultString ? resultString : @"" forKey:@"resultString"];
	}
	
	[[[[[self class] alloc] init] autorelease] performSelectorOnMainThread:@selector(performBlockOnMainThread:)
																withObject:resultDictionary waitUntilDone:YES];
	[params autorelease];
	[pool release];
}
- (void)performBlockOnMainThread:(NSDictionary*)params
{
	NSError* error = (NSError*)[params objectForKey:@"error"];
	NSString* resultString = [params objectForKey:@"resultString"];
	void(^successBlock)(PNHTTPResponse *) = [params objectForKey:@"successBlock"];
    void(^failureBlock)(PNError *) = [params objectForKey:@"failureBlock"];
	
	if(error)
    {
		if ([error code] == -1009) {	// Network error
			failureBlock([PNError connectionError]);
		} else {
			failureBlock((PNError*)error);
		}
    }
    else
    {
        successBlock([PNHTTPResponse responseFromJson:resultString]);
    }
	
	Block_release(successBlock);
	Block_release(failureBlock);
}
@end
