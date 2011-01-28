//
//  PNGradeGaugeFilledView.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGradeGaugeFilledView.h"

// GradeGaugeのグラデーション指定カラーコード（先頭の#は不要です）。
#define kPNGradeGaugeFilledTopColor		@"FFFFFF"
#define kPNGradeGaugeFilledBottumColor	@"999999"


@implementation PNGradeGaugeFilledView

// グラデーションを描画します。
- (void)drawRect:(CGRect)rect {

	CGFloat red1	= [self hexToUIColorRed:kPNGradeGaugeFilledTopColor];
	CGFloat green1	= [self hexToUIColorGreen:kPNGradeGaugeFilledTopColor];
	CGFloat blue1	= [self hexToUIColorBlue:kPNGradeGaugeFilledTopColor];
	
	CGFloat red2	= [self hexToUIColorRed:kPNGradeGaugeFilledBottumColor];
	CGFloat green2	= [self hexToUIColorGreen:kPNGradeGaugeFilledBottumColor];
	CGFloat blue2	= [self hexToUIColorBlue:kPNGradeGaugeFilledBottumColor];

	[self setContext:UIGraphicsGetCurrentContext()];
	[self setColorRed1:red1 green1:green1 blue1:blue1 alpha1:1.00f
				  red2:red2 green2:green2 blue2:blue2 alpha2:1.00f];
	[self gradientRectX:0.0f y:0.0f width:80.0f height:14.0f];
}

- (void)dealloc {
	[super dealloc];
}

@end
