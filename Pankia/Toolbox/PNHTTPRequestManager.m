//
//  PNHTTPRequestManager.m
//  PankiaLite
//
//  Created by sota2 on 10/10/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNHTTPRequestManager.h"
#import "PNRequestKeyManager.h"

static PNHTTPRequestManager* _sharedInstance;

@implementation PNHTTPRequestManager

@synthesize requestList;

- (void)newRequestWithURL:(NSString*)url delegate:(id<PNHTTPRequestManagerDelegate>)delegate selector:(SEL)selector object:(id)object
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate 
											 onSucceededSelector:selector onFailedSelector:nil withObject:object];
	PNHTTPDownload* downloader = [[[PNHTTPDownload alloc] init] autorelease];
	[downloader downloadFromURL:url delegate:self];
	downloader.userInfo = [NSDictionary dictionaryWithObject:requestKey forKey:@"request_key"];
}

- (void)httpDownloadSucceeded:(PNHTTPDownload *)download
{
	NSString* requestKey = [download.userInfo objectForKey:@"request_key"];
	[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:download.response];
}

- (void)httpDownloadFailed:(PNHTTPDownload *)download withError:(NSError *)error
{
	NSString* requestKey = [download.userInfo objectForKey:@"request_key"];
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id<PNHTTPRequestManagerDelegate> delegate = request.delegate;
	if ([(NSObject*)delegate respondsToSelector:@selector(httpRequestForKey:failedWithError:)]) {
		[delegate httpRequestForKey:requestKey failedWithError:error];
	}
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}

#pragma mark Singleton Pattern
- (id)init
{
	if (self = [super init]) {
		// begin - lerry added code
		if (!requestList) {
			requestList = [[NSMutableArray alloc] init];
		} else {
			[requestList removeAllObjects]; // not sure whether this is dangerous
		}

		// end - lerry added code
	}	
	return self;
}

- (void) dealloc
{
	// begin - lerry added code
	[requestList release];
	// end - lerry added code
	[super dealloc];
}

+ (PNHTTPRequestManager *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}

// begin - lerry added code
- (void)bufferRequest:(PNHTTPService*)request {
	[requestList addObject:request];
}

- (void)cancelRequest:(PNHTTPService*)request {
	[requestList removeObject:request];
}

- (void)clearRequests {
	int numRequest = [requestList count];
	NSMutableArray* toDelete = [NSMutableArray arrayWithCapacity:numRequest];
	for (int i = 0; i < numRequest; i++) {
		PNHTTPService* req = [requestList objectAtIndex:i];
		if (req.isMutable == YES) {
			[req cancel];
			[toDelete addObject:req];
		}
	}
	// deletion
	for (int i=0; i<[toDelete count]; i++) {
		[requestList removeObject:[toDelete objectAtIndex:i]];
	}
}
// end - lerry added code
@end
