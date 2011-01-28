//
//  PNJoinedRoomEventCell.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNJoinedLocalRoomEventCell.h"
#import "PNGlobal.h"

@implementation PNJoinedLocalRoomEventCell

@synthesize notHostText_;


- (void)awakeFromNib {
	[super awakeFromNib];
	notHostText_.hidden = YES;
}

- (void)showNotHostText {
	notHostText_.hidden = NO;
}

- (void)hideNotHostText {
	notHostText_.hidden = YES;
}

- (void)dealloc {
	PNSafeDelete(notHostText_);
	[super dealloc];
}	
	
@end
