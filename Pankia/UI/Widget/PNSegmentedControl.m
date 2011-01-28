//
//  PNSegmentedControl.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSegmentedControl.h"


@implementation PNSegmentedControl

- (void)awakeFromNib
{
	const int buttonLeftCapWidth = 10;
	const int buttonTopCapHeight = 10;

	int numOfSegments = self.numberOfSegments;
	for (int i = 0; i < numOfSegments; i++) {
		NSString* targetImage = @"PNCenterSeparateButtonOn.png";
		
		if (i == 0) {
			targetImage = @"PNLeftSeparateButtonOff.png";
		}
		else if (i == numOfSegments -1) {
			targetImage = @"PNRightSeparateButtonOn.png";
		}
		
		UIImage* segImage = [UIImage imageNamed:targetImage];

		[self setImage:[segImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forSegmentAtIndex:i];
	}
	
}

- (void)dealloc
{
	[super dealloc];
}

@end
