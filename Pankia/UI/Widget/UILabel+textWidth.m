//
//  UILabel+textWidth.m
//  PankakuNet
//
//  Created by 横江 宗太 on 10/03/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UILabel+textWidth.h"


@implementation UILabel(TextWidth)
- (float)textWidth{
	return [self textWidthOfString:self.text];
}
- (float)textWidthOfString:(NSString*)value{
	CGSize textSize = [value sizeWithFont:self.font];
	return textSize.width;
}
- (float)textHeight
{
	CGSize textSize = [self.text sizeWithFont:self.font];
	return textSize.height;
}
@end
