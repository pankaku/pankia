//
//  PNGradientView.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGradientView.h"


@implementation PNGradientView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		color_[0] = 1.0f; color_[1] = 1.0f; color_[2] = 1.0f; color_[3] = 1.0f;
		color_[4] = 1.0f; color_[5] = 1.0f; color_[6] = 1.0f; color_[7] = 1.0f;		
	}
	return self;
}

- (void)gradientRectX:(float)x y:(float)y width:(float)width height:(float)height {
	CGColorSpaceRef space		= CGColorSpaceCreateDeviceRGB();
	CGGradientRef	gradient	= CGGradientCreateWithColorComponents(space, color_, nil, 2);
	
	CGContextSaveGState(context_);
	CGContextClipToRect(context_, CGRectMake(x, y, width, height));
	CGContextDrawLinearGradient(context_, gradient, CGPointMake(0, y), CGPointMake(0, y + height), 0);
	CGContextRestoreGState(context_);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(space);
}

- (void)setColorRed1:(float)red1 green1:(float)green1 blue1:(float)blue1 alpha1:(float)alpha1
				red2:(float)red2 green2:(float)green2 blue2:(float)blue2 alpha2:(float)alpha2 {
	color_[0] = red1; color_[1] = green1; color_[2] = blue1; color_[3] = alpha1;
	color_[4] = red2; color_[5] = green2; color_[6] = blue2; color_[7] = alpha2;
}

- (void)setContext:(CGContextRef)context {
	if (context_ != nil) {
		CGContextRelease(context_);
		context_ = nil;
	}
	context_ = context;
	CGContextRetain(context_);
}

// ColorCode(#00---- ~ #FF----)を正規化(0.0~1.0)した値を返します。
- (CGFloat)hexToUIColorRed:(NSString *)hex {
	NSScanner*	colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat red = ((color & 0xFF0000) >> 16) / 255.0f;
	
	return red;
}

// ColorCode(#--00-- ~ #--FF--)を正規化(0.0~1.0)した値を返します。
- (CGFloat)hexToUIColorGreen:(NSString *)hex {
	NSScanner*	colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat green = ((color & 0x00FF00) >> 8) / 255.0f;
	
	return green;
}

// ColorCode(#----00 ~ #----FF)を正規化(0.0~1.0)した値を返します。
- (CGFloat)hexToUIColorBlue:(NSString *)hex {
	NSScanner*	colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat blue = (color & 0x0000FF) / 255.0f;
	
	return blue;
}

@end
