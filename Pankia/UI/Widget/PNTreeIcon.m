//
//  PNTreeIcon.m
//  PankakuNet
//
//  Created by nakashima on 10/02/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNTreeIcon.h"


@implementation PNTreeIcon

- (void)_init
{
	UIImage* normalImage = [UIImage imageNamed:@"PNTreeIconClose.png"];
	UIImage* selectedImage = [UIImage imageNamed:@"PNTreeIconOpen.png"];

	[self setBackgroundImage:normalImage forState:UIControlStateNormal];
	[self setBackgroundImage:selectedImage forState:UIControlStateSelected];	
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

- (void)cellOpen
{
	self.selected = YES;
}

- (void)cellClose
{
	self.selected = NO;
}

@end
