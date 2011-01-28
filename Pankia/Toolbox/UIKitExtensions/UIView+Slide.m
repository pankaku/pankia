//
//  UILabel+Slide.m
//  PankakuNet
//
//  Created by pankaku on 10/06/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIView+Slide.h"


@implementation UIView(Slidable)
- (void)slideX:(float)x y:(float)y
{
	CGRect currentFrame = self.frame;
	[self setFrame:CGRectMake(currentFrame.origin.x + x, currentFrame.origin.y + y, currentFrame.size.width, currentFrame.size.height)];
}
- (void)moveToX:(float)x y:(float)y
{
	CGRect currentFrame = self.frame;
	[self setFrame:CGRectMake(x, y, currentFrame.size.width, currentFrame.size.height)];	
}
- (void)setWidth:(float)width height:(float)height
{
	CGRect currentFrame = self.frame;
	[self setFrame:CGRectMake(currentFrame.origin.x, currentFrame.origin.y, width, height)];
}
- (void)moveToCenterInWidth:(float)width height:(float)height
{
	float containerWidth = width;
	float containerHeight = height;
	float viewWidth = self.frame.size.width;
	float viewHeight = self.frame.size.height;
	
	self.frame = CGRectMake(containerWidth * 0.5 - viewWidth * 0.5, containerHeight * 0.5 - viewHeight * 0.5, viewWidth, viewHeight);
}
@end
