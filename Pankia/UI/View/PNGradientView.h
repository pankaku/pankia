//
//  PNGradientView.h
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface PNGradientView : UIView {
	CGContextRef	context_;
	float			color_[8];
}

- (void)setContext:(CGContextRef)context;
- (void)setColorRed1:(float)red1 green1:(float)green1 blue1:(float)blue1 alpha1:(float)alpha1
				red2:(float)red2 green2:(float)green2 blue2:(float)blue2 alpha2:(float)alpha2;
- (void)gradientRectX:(float)x y:(float)y width:(float)width height:(float)height;
- (CGFloat)hexToUIColorRed:(NSString *)hex;
- (CGFloat)hexToUIColorGreen:(NSString *)hex;
- (CGFloat)hexToUIColorBlue:(NSString *)hex;

@end
