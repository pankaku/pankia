//
//  PNPreviousButton.m
//  PankakuNet
//
//  Created by Kazuto Maruoka on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNPreviousButton.h"


@implementation PNPreviousButton

- (void)_init
{
	UIImage* normalImage = [UIImage imageNamed:@"PNPreviousButton.png"];

	[self setBackgroundImage:normalImage forState:UIControlStateNormal];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[self _init];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self _init];
	}
	
	return self;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self _init];
	}
	return self;
}

@end
