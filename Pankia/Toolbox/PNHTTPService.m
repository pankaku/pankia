#import "PNHTTPService.h"
#import "PNServiceNotifyDelegate.h"
#import "PNLogger+Common.h"
#import "PNGlobal.h"
#import "PNHTTPRequestHelper.h"

@interface PNHTTPService (Private)
- (NSError*)synchronousRequest;
- (BOOL)request:(BOOL)aIsPost;
@end

@implementation PNHTTPService
@synthesize data, requestURL, delegate, userInfo, sec, isMutable, urlConnection, urlRequest;

#pragma mark --- Private Methods ---
- (NSError*)synchronousRequest
{
	self.urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.requestURL]
									   cachePolicy:NSURLRequestUseProtocolCachePolicy
								   timeoutInterval:self.sec];
	
	NSURLResponse* resp;
	NSError* err;
	NSData* result = [NSURLConnection sendSynchronousRequest:self.urlRequest
										   returningResponse:&resp
													   error:&err];
	if (result) {
		PNCLog(PNLOG_CAT_HTTP_REQUEST, @"synchronizedRequest send ok.");
	} else {
		PNCLog(PNLOG_CAT_HTTP_REQUEST, @"synchronizedRequest send ng.");
	}
	return err;
}

- (BOOL)request:(BOOL)aIsPost
{
	if(aIsPost) {
		NSArray* pair		= [self.requestURL componentsSeparatedByString:@"?"];
		NSString* url		= [pair objectAtIndex:0];
		NSString* params	= [pair objectAtIndex:1];

		self.urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:self.sec];
		
		NSData* pData = [NSData dataWithBytes:[params UTF8String] length:params.length];
		
		[self.urlRequest setHTTPMethod:@"POST"];
		[self.urlRequest setHTTPBody:pData];
		PNCLog(PNLOG_CAT_HTTP_REQUEST, @"http request timeout after: %ds", [self.urlRequest timeoutInterval]);
	} else {
		self.urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.requestURL]
										   cachePolicy:NSURLRequestUseProtocolCachePolicy
									   timeoutInterval:self.sec];
	}
	PNCLog(PNLOG_CAT_HTTP_REQUEST,@"%@",self.requestURL);
	
	self.urlConnection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
	return (self.urlConnection != nil);
}

- (id)init 
{
	if (self = [super init]) {
		self.data = [[NSMutableData alloc] init];
		self.isMutable = YES;
	}
	return self;
}

-(void)dealloc {
	[requestURL release];
	requestURL = nil;	
	[urlRequest release];
	urlRequest = nil;
	[urlConnection release];
	urlConnection = nil;
	[userInfo release];
	userInfo = nil;
	[delegate release];
	delegate = nil;
	PNSafeDelete(data);
	[super dealloc];
}

#pragma mark --- NSURLConnection Delegate Methods ---
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    [self.data appendData:d];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	// print error message
	PNWarn(@"Connection failed due to: %@", error);
	
    // inform the user
	PNNetworkError *err = [[[PNNetworkError alloc] init] autorelease];
	err.message   = @"Can't connect to server.";
	err.errorType = kPNHTTPErrorFailed;
	if([self.delegate respondsToSelector:@selector(error:userInfo:)]) {
		[self.delegate error:err userInfo:self.userInfo];
	}
	
	// since the data received is not complete, delete it
	PNSafeDelete(self.data);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// announce the successful loading of data
	NSString* resp = [[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] autorelease];
	if ([self.delegate respondsToSelector:@selector(notify:userInfo:)])
		[self.delegate notify:resp userInfo:self.userInfo];
	
	// clear data buffer for new coming data
	PNSafeDelete(self.data);
}

#pragma mark --- Static Methods ---
+ (PNHTTPService*)synchronousRequestWithURL:(NSString*)url
{
	PNHTTPService* httpService	= [[[PNHTTPService alloc] init] autorelease];
	httpService.requestURL		= url;
	httpService.delegate		= nil;
	httpService.userInfo		= nil;
	httpService.sec				= kPNHTTPRequestTimeout;
	NSError* error = [httpService synchronousRequest];
	if (error) {
		PNWarn(@"Error occured when posting a synchronous request: %@", error);
	}
	return httpService;
}

+ (PNHTTPService*) GETWithURL:(NSString*)url
					 delegate:(id)delegate
					 userInfo:(id)info
{
	return [PNHTTPService GETWithURL:url
							delegate:delegate
							userInfo:info
							 timeout:kPNHTTPRequestTimeout];
}

+ (PNHTTPService*) GETWithURL:(NSString*)url
					 delegate:(id)delegate
					 userInfo:(id)info
					  timeout:(int)sec
{
	PNHTTPService* httpService	= [[[PNHTTPService alloc] init] autorelease];
	httpService.requestURL		= url;
	httpService.delegate		= delegate;
	httpService.userInfo		= info;
	httpService.sec				= sec;
	if (![httpService request:NO]) {
		PNWarn(@"Failed to create connection to %@", url);
	}
	return httpService;
}

+ (PNHTTPService*) POSTWithURL:(NSString*)url
					  delegate:(id)delegate
					  userInfo:(id)info
					   timeout:(int)sec
{
	PNHTTPService* httpService	= [[[PNHTTPService alloc] init] autorelease];
	httpService.requestURL		= url;
	httpService.delegate		= delegate;
	httpService.userInfo		= info;
	httpService.sec				= sec;
	if (![httpService request:YES]) {
		PNWarn(@"Failed to create connection to %@", url);
	}
	return httpService;
}

+ (PNHTTPService*) GETWithURL:(NSString*)url 
					 delegate:(id)delegate
					 userInfo:(id)info
					isMutable:(BOOL)_isMutable
{
	return [PNHTTPService GETWithURL:url
							delegate:delegate 
							userInfo:info
							 timeout:kPNHTTPRequestTimeout
						   isMutable:_isMutable];
}

+ (PNHTTPService*) GETWithURL:(NSString*)url 
					 delegate:(id)delegate
					 userInfo:(id)info
					  timeout:(int)sec
					isMutable:(BOOL)_isMutable
{
	PNHTTPService* httpService	= [[[PNHTTPService alloc] init] autorelease];
	httpService.requestURL		= url;
	httpService.delegate		= delegate;
	httpService.userInfo		= info;
	httpService.sec				= sec;
	httpService.isMutable		= _isMutable;
	if (![httpService request:NO]) {
		PNWarn(@"Failed to create connection to %@", url);
	}
	return httpService;
}

+ (PNHTTPService*) POSTWithURL:(NSString*)url 
					  delegate:(id)delegate
					  userInfo:(id)info
					   timeout:(int)sec
					 isMutable:(BOOL)_isMutable
{
	PNHTTPService* httpService	= [[[PNHTTPService alloc] init] autorelease];
	httpService.requestURL		= url;
	httpService.delegate		= delegate;
	httpService.userInfo		= info;
	httpService.sec				= sec;
	httpService.isMutable		= _isMutable;
	if (![httpService request:YES]) {
		PNWarn(@"Failed to create connection to %@", url);
	}
	return httpService;
}

- (BOOL)cancel
{
	if (self.isMutable) {
		[self.urlConnection cancel];
		return YES;
	} else {
		return NO;
	}

}

@end
