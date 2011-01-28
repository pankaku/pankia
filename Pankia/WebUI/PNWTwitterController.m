//
//  PNWTwitterController.m
//  PankakuNet
//
//  Created by sota2 on 11/01/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNWTwitterController.h"
#import "PNTwitterManager.h"

@implementation PNWTwitterController
- (void)link
{
	[request waitForServerResponse];
	[self retain];
	[request retain];
	
	NSString* account = [request.params objectForKey:@"account"];
	NSString* password = [request.params objectForKey:@"password"];
	
	[[PNTwitterManager sharedObject] linkWithAccountName:account password:password onSuccess:^(void) {
		[request setAsOK];
		[request performCallback];	
		[request release];
		[self release];
	} onFailure:^(PNError *error) {
		[request setAsNG];
		[request performCallback];
		[request release];
		[self release];
	}];
}

- (void)unlink
{
	[request waitForServerResponse];
	[self retain];
	[request retain];
	
	[[PNTwitterManager sharedObject] unlinkWithOnSuccess:^(void) {
		[request setAsOK];
		[request performCallback];		
		[request release];
		[self release];
	} onFailure:^(PNError *error) {
		[request setAsNG];
		[request performCallback];	
		[request release];
		[self release];
	}];
}

@end
