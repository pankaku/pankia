//
//  PNGradeGaugeEmptyView.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNGradeGaugeEmptyView.h"

// GradeGaugeのグラデーション指定カラーコード（先頭の#は不要です）。
#define	kPNGradeGaugeEmptyTopColor		@"556666"
#define kPNGradeGaugeEmptyBottomColor	@"003333"


@implementation PNGradeGaugeEmptyView

// グラデーションを描画します。
- (void)drawRect:(CGRect)rect {

	CGFloat red1	= [self hexToUIColorRed:kPNGradeGaugeEmptyTopColor];
	CGFloat green1	= [self hexToUIColorGreen:kPNGradeGaugeEmptyTopColor];
	CGFloat blue1	= [self hexToUIColorBlue:kPNGradeGaugeEmptyTopColor];
	
	CGFloat red2	= [self hexToUIColorRed:kPNGradeGaugeEmptyBottomColor];
	CGFloat green2	= [self hexToUIColorGreen:kPNGradeGaugeEmptyBottomColor];
	CGFloat blue2	= [self hexToUIColorBlue:kPNGradeGaugeEmptyBottomColor];
	
	[self setContext:UIGraphicsGetCurrentContext()];
	[self setColorRed1:red1 green1:green1 blue1:blue1 alpha1:1.00f
				  red2:red2 green2:green2 blue2:blue2 alpha2:1.00f];
	[self gradientRectX:0.0f y:0.0f width:384.0f height:14.0f];
}

- (void)dealloc {
	[super dealloc];
}

@end
