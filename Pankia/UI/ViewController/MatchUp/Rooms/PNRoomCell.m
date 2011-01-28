//
//  PNRoomCell.m
//  PankiaNet
//
//  Created by Ken Saito on 12/16/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNRoomCell.h"


@implementation PNRoomCell
@synthesize islocked_;

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.islocked_ = NO;
	
	UIImage*	bgImage = [UIImage imageNamed:@"PNInformationCellBackground.png"];
	imageView			= [[[UIImageView alloc] initWithImage:bgImage] autorelease];
	imageView.alpha		= 0.5f;
	imageView.hidden	= NO;
	[self addSubview:imageView];
	
}

- (void)dealloc
{	
    [super dealloc];
}

- (void)lock
{
	imageView.hidden = NO;	
}

- (void)unlock
{
	imageView.hidden = YES;	
}

@end
