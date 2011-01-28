//
//  PNIndicator.h
//  PankiaNet
//
//  Created by nakashima on 10/02/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PNIndicator : UIView {
	UIImageView*			 indicatorBackground;
	UIImageView*			indicatorLargeBackground;
	UILabel*				descriptionLabel;
	UIActivityIndicatorView* indicator;
}

@property (retain) UIImageView*				indicatorBackground;
@property (retain) UIImageView*	indicatorLargeBackground;
@property (retain) UILabel* descriptionLabel;
@property (retain) UIActivityIndicatorView* indicator;

- (void)start;
- (void)startInLargeMode;
- (void)stop;
- (BOOL)isIndicatorAnimating;
- (void)updateDescription:(NSString*)text;

@end
