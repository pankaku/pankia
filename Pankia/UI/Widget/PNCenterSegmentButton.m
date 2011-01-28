//
//  PNCenterSegmentButton.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNCenterSegmentButton.h"
#import "PankiaNetworkLibrary+Package.h"


@implementation PNCenterSegmentButton

- (void)awakeFromNib {
	[self setTitle:getTextFromTable(self.titleLabel.text) forState:UIControlStateNormal];
}

- (void)_init {
	UIImage* normalImage = [UIImage imageNamed:@"PNSegmentedControlImageOnCenter.png"];
	UIImage* selectedImage = [UIImage imageNamed:@"PNSegmentedControlImageOffCenter.png"];
	
	const int buttonLeftCapWidth = 10;
	const int buttonTopCapHeight = 10;
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateSelected];
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];	
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateHighlighted];	
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateDisabled];	
	
}

- (id)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[self _init];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self _init];
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		[self _init];
	}
	return self;
}

@end
