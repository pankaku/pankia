//
//  PNSingleButton.m
//  PankakuNet
//
//  Created by pankaku on 10/07/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSingleButton.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"
 

@implementation PNSingleButton

- (void)awakeFromNib
{
	[self setTitle:getTextFromTable(self.titleLabel.text)];
}

/*!
 * 背景画像の引き延ばしの設定を行います
 */
- (void)_init
{
	UIImage* normalImage = [UIImage imageNamed:@"PNSingleButtonOff.png"];
	UIImage* selectedImage = [UIImage imageNamed:@"PNSingleButtonOn.png"];
	
	const int buttonLeftCapWidth = 18;
	const int buttonTopCapHeight = 18;
	NSString* fontName = kPNDefaultFontName;
	[self.titleLabel setFont:[UIFont fontWithName:fontName size:11]];
	
	[self setTitle:getTextFromTable(self.titleLabel.text)];
	
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateDisabled];	
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

- (void)setTitle:(NSString*)title
{
	[self setTitle:title forState:UIControlStateNormal];
	[self setTitle:title forState:UIControlStateDisabled];
}

- (void)setButtonTitleSize:(int)size
{
	NSString* fontName = kPNDefaultFontName;
	[self.titleLabel setFont:[UIFont fontWithName:fontName size:size]];
}
@end
