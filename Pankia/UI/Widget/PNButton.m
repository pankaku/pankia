//
//  PNButton.m
//  PankakuNet
//
//  Created by sota2 on 10/10/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNButton.h"
#import "PNLocalizedString.h"
#import "PNGlobal.h"
 

#define kPNDefaultStateBackgroundImage  @"PNPositiveButton.png"
#define kPNSelectedStateBackgroundImage @"PNDisableButton.png"
static const float kTitleLabelFontSize = 11.0f;

@implementation PNButton

+ (id)button
{
    return [[[[self class] alloc] init] autorelease];
}

- (void)configureBackgroundImage
{
    UIImage* normalImage = [UIImage imageNamed:kPNDefaultStateBackgroundImage];
	UIImage* selectedImage = [UIImage imageNamed:kPNSelectedStateBackgroundImage];
	
	float buttonLeftCapWidth = 18.0f;
	float buttonTopCapHeight = 18.0f;
    
	NSString* fontName = kPNDefaultFontName;
	[self.titleLabel setFont:[UIFont fontWithName:fontName size:kTitleLabelFontSize]];
	
	[self setTitle:getTextFromTable(self.titleLabel.text)];
	
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateHighlighted];
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateDisabled];
}

// For instances placed on xib files.
- (void)awakeFromNib
{
    [self configureBackgroundImage];
    
    // Localize text.
	[self setTitle:getTextFromTable(self.titleLabel.text)];
}

- (id)init {
    if ((self = [super init])) {
        [self configureBackgroundImage];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self configureBackgroundImage];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        [self configureBackgroundImage];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
	NSString* localizedTitle = getTextFromTable(title);
	[self setTitle:localizedTitle forState:UIControlStateNormal];
	[self setTitle:localizedTitle forState:UIControlStateDisabled];
}

- (void)dealloc {
    [super dealloc];
}


@end
