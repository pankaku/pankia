//
//  PNCellArrow.m
//  PankakuNet
//
//  Created by 横江 宗太 on 10/07/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNCellArrow.h"


@implementation PNCellArrow


+ (id)arrow {
	return [[[self alloc] init] autorelease];
}
- (id)init {
    if ((self = [super initWithImage:[UIImage imageNamed:@"PNCellArrowImage.png"]])) {
        CGRect originalFrame = self.frame;
		originalFrame.size.width = originalFrame.size.width + 15.0f;
		self.frame = originalFrame;
		self.contentMode = UIViewContentModeLeft;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
