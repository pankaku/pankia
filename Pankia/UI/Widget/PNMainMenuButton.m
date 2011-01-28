//
//  PNMainMenuButton.m
//  PankakuNet
//
//  Created by Sota Yokoe on 10/04/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMainMenuButton.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"
 

@interface PNMainMenuButton(Private)
- (void) addCustomComponents;
@end

@implementation PNMainMenuButton

- (void) awakeFromNib {
	[self setTitle:getTextFromTable(self.titleLabel.text) forState:UIControlStateNormal];
}

- (void) setEnabled:(BOOL)value {
	[super setEnabled:value];
}

- (void)dismiss {
	titleLabel.text = @"";
}

- (void) addCustomComponents {
	CGRect frame = self.frame;
	
	CGRect labelFrame = CGRectMake(0.0f, frame.size.height - 52.0f, frame.size.width + 3.0, 52.0f);
	
	// ラベルを追加します
	UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
	label.text = @"";
	label.backgroundColor	= [UIColor clearColor];
	label.textColor			= [UIColor whiteColor];
	label.shadowColor		= [UIColor blackColor];
	label.shadowOffset		= CGSizeMake(0, 1);
	label.textAlignment		= UITextAlignmentCenter;
	label.font				= [UIFont fontWithName:kPNDefaultFontName size:11.0f];
	label.numberOfLines		= 2;

	titleLabel = label;
	[self addSubview:label];
}

- (void) dealloc {
	[titleLabel release];
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self addCustomComponents];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self addCustomComponents];
	}
	return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state{
	titleLabel.text = title;
}
@end
