//
//  PNSpecialTableCell.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSpecialTableCell.h"
#import "PNLogger.h"

#define kPNSpecialCellBackgroundImage   @"PNSpecialTableCellBackgroundImage.png"

@implementation PNSpecialTableCell

- (void)awakeFromNib {

	if (!self.backgroundView) {
		UIImage* normalImage = [UIImage imageNamed:kPNSpecialCellBackgroundImage];		
        self.backgroundView = [[[UIImageView alloc] initWithImage:normalImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
	}
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)dealloc {
	[super dealloc];
}

@end
