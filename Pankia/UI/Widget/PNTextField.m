//
//  PNTextField.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNTextField.h"


@implementation PNTextField

- (void)_init
{
	self.borderStyle = UITextBorderStyleNone;
	UIImage* image = [UIImage imageNamed:@"PNInputBoxBackgroundImage.png"];
	UIImage* image2 = [UIImage imageNamed:@"PNInputBoxBackgroundImage.png"];
	const int buttonLeftCapWidth = 10;
	const int buttonTopCapHeight = 10;
	NSString* fontName = @"Verdana";
	[self setFont:[UIFont fontWithName:fontName size:12]];
	defaultBackgroundImage = [[image stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] retain];
	whiteBackgroundImage = [[image2 stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] retain];
	[self setBackgroundColor:[UIColor blackColor]];
	[self setBackground:defaultBackgroundImage];
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

- (void)dealloc {
	[whiteBackgroundImage release];
	[defaultBackgroundImage release];
	[super dealloc];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 14.0f, bounds.origin.y, bounds.size.width - 18.0f, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 14.0f, bounds.origin.y, bounds.size.width - 18.0f, bounds.size.height);
}

@end
