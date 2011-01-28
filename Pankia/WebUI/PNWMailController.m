//
//  PNWMailController.m
//  PankakuNet
//
//  Created by あんのたん on 11/01/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNWMailController.h"


@implementation PNWMailController

- (void)launch {
	[request waitForServerResponse];
	MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
	mailViewController.mailComposeDelegate = self;
	[mailViewController setSubject:[[request.params objectForKey:@"subject"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[mailViewController setMessageBody:[[request.params objectForKey:@"body"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isHTML:NO];
	[mailViewController setToRecipients:[NSArray arrayWithObject:[[request.params objectForKey:@"to"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[request.webView addSubview:mailViewController.view];
	[self retain];
	[request retain];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	NSLog(@"FInish mail action.");
	[controller.view removeFromSuperview];
	[controller release];
	[request setAsOK];
	[request performCallback];
	[request release];
	[self release];
}

@end
