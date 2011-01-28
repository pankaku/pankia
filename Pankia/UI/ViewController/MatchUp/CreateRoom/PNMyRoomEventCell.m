//
//  PNMyRoomEventCell.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNDashboard.h"
#import "PNMyRoomEventCell.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"


@implementation PNMyRoomEventCell

@synthesize delegate;
@synthesize inviteButton_;


- (IBAction)inviteButtonDidPush {
	if (delegate != nil && [delegate respondsToSelector:@selector(invite)]) {
		[delegate performSelector:@selector(invite) withObject:nil];
	}
}

- (void)dealloc {
	self.inviteButton_	= nil;
	self.delegate		= nil;
	[super dealloc];
}

@end
