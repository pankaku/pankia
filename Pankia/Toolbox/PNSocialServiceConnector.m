//
//  PNSocialServiceConnector.m
//  PankakuNet
//
//  Created by sota2 on 10/11/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSocialServiceConnector.h"
#import "Helpers.h"
#import "NSDictionary+GetterExt.h"

@implementation PNSocialServiceConnector
@synthesize delegate;

- (void)getIconURLFromTwitterWithId:(NSString *)userId
{
	receivedData = [[NSMutableData data] retain];
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/users/show/%@.json", userId]]
										 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSURLConnection *conn;
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
}

// データを受け取る度に呼び出される
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

// データを全て受け取ると呼び出される
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString* receivedString = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
	[receivedData release];
	
	NSDictionary* dictionary = [receivedString JSONValue];
	NSString* imageURL = [dictionary stringValueForKey:@"profile_image_url" defaultValue:@""];
	
	if ([delegate respondsToSelector:@selector(socialServiceConnectorDidReceiveTwitterIconURL:)]) {
		[delegate performSelector:@selector(socialServiceConnectorDidReceiveTwitterIconURL:) withObject:imageURL];
	}
}
@end
