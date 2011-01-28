//
//  PNMyLocalRoomEventCell.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMyLocalRoomEventCell.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"


@implementation PNMyLocalRoomEventCell

@synthesize startLocalMatchButton_;
@synthesize delegate;

- (void)awakeFromNib {
	[super awakeFromNib];
	[startLocalMatchButton_ setEnabled:NO];
}

- (IBAction)startLocalMatchButtonDidPush {
	[startLocalMatchButton_ setTitle:@"PNTEXT:BUTTON:Started"
							forState:UIControlStateNormal];
	[startLocalMatchButton_ refreshText];
	[startLocalMatchButton_ setEnabled:NO];
	
	float const delayTime = 1.0f;
	
	if (delegate != nil && [delegate respondsToSelector:@selector(start)]) {
		[delegate performSelector:@selector(start)
					   withObject:nil
					   afterDelay:delayTime];
	}
}

- (void)enableStartLocalMatchButton {
	[startLocalMatchButton_ setEnabled:YES];
}

- (void)disableStartLocalMatchButton {
	[startLocalMatchButton_ setEnabled:NO];
}

- (void)dealloc {
	self.delegate = nil;
	PNSafeDelete(startLocalMatchButton_);
	[super dealloc];
}

@end
