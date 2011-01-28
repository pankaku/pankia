//
//  PNIndicator.m
//  PankiaNet
//
//  Created by nakashima on 10/02/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNIndicator.h"
#import "PNGlobal.h"
#import "PNDashboard.h"
#import "PNLocalizedString.h"
 

#define kPNIndicatorBackground			@"PNIndicatorBackgroundImage.png"
#define kPNLargeIndicatorBackground		@"PNLargeIndicatorBackgroundImage.png"


@implementation PNIndicator

@synthesize indicatorBackground, indicatorLargeBackground, indicator, descriptionLabel;

const float INDICATOR_OFFSET					=   0.0f;	
const float INDICATOR_BACKGROUND_WIDTH			= 130.0f;
const float INDICATOR_BACKGROUND_HEIGHT			=  90.0f;
const float INDICATOR_LARGE_BACKGROUND_WIDTH	= 260.0f;
const float INDICATOR_LARGE_BACKGROUND_HEIGHT	= 100.0f;
const float INDICATOR_WIDTH						=  50.0f;
const float INDICATOR_HEIGHT					=  50.0f;

- (PNIndicator*)init {
	
	if (self = [super init]) {
		float indicatorBackground_X, indicatorBackground_Y,
				indicatorLargeBackground_X, indicatorLargeBackground_Y,
				descriptionLabel_X, descriptionLabel_Y,
				indicator_X, indicator_Y;
		if ([[PNDashboard sharedObject] isLandscapeMode]) {
			indicatorBackground_X      = (480.0/2.0) - (INDICATOR_BACKGROUND_WIDTH/2.0) + INDICATOR_OFFSET;
			indicatorBackground_Y      = (320.0/2.0) - (INDICATOR_BACKGROUND_HEIGHT/2.0);
			indicatorLargeBackground_X = (480.0/2.0) - (INDICATOR_LARGE_BACKGROUND_WIDTH / 2.0) + INDICATOR_OFFSET;
			indicatorLargeBackground_Y = (320.0/2.0) - (INDICATOR_LARGE_BACKGROUND_HEIGHT / 2.0);
			descriptionLabel_X = (480.0 - INDICATOR_LARGE_BACKGROUND_WIDTH) / 2.0  + INDICATOR_OFFSET;
			descriptionLabel_Y = (320.0/2.0) + (INDICATOR_HEIGHT/2.0);
			indicator_X        = (480.0/2.0) - INDICATOR_WIDTH + INDICATOR_OFFSET + (INDICATOR_WIDTH/2.0);
			indicator_Y        = (320.0/2.0) - INDICATOR_HEIGHT + (INDICATOR_HEIGHT/2.0);
		} else {
			indicatorBackground_X      = (320.0/2.0) - (INDICATOR_BACKGROUND_WIDTH  /2.0);
			indicatorBackground_Y      = (480.0/2.0) - (INDICATOR_BACKGROUND_HEIGHT /2.0);
			indicatorLargeBackground_X = (320.0/2.0) - (INDICATOR_LARGE_BACKGROUND_WIDTH  /2.0);
			indicatorLargeBackground_Y = (480.0/2.0) - (INDICATOR_LARGE_BACKGROUND_HEIGHT /2.0);
			descriptionLabel_X = (320.0 - INDICATOR_LARGE_BACKGROUND_WIDTH) / 2.0;
			descriptionLabel_Y = (480.0/2.0) + (INDICATOR_HEIGHT/2.0);
			indicator_X        = (320.0/2.0) - INDICATOR_WIDTH  + (INDICATOR_WIDTH /2.0);
			indicator_Y        = (480.0/2.0) - INDICATOR_HEIGHT + (INDICATOR_HEIGHT/2.0);
		}
		
		self.indicatorBackground   = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNIndicatorBackground]] autorelease];
		indicatorBackground.frame  = CGRectMake(
			indicatorBackground_X,
			indicatorBackground_Y,
			INDICATOR_BACKGROUND_WIDTH, INDICATOR_BACKGROUND_HEIGHT);
		indicatorBackground.hidden = YES;
		
		self.indicatorLargeBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNLargeIndicatorBackground]] autorelease];
		indicatorLargeBackground.frame = CGRectMake(
											  indicatorLargeBackground_X, 
											  indicatorLargeBackground_Y, 
											  INDICATOR_LARGE_BACKGROUND_WIDTH, INDICATOR_LARGE_BACKGROUND_HEIGHT);
		indicatorLargeBackground.hidden = YES;
		
		self.descriptionLabel = [[[UILabel alloc] initWithFrame:
								  CGRectMake(descriptionLabel_X, descriptionLabel_Y,
											 INDICATOR_LARGE_BACKGROUND_WIDTH, 15.0f)] autorelease];
		descriptionLabel.hidden = YES;
		descriptionLabel.textAlignment = UITextAlignmentCenter;
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor whiteColor];
		descriptionLabel.font = [UIFont fontWithName:kPNDefaultFontName size:10.0f];
		descriptionLabel.text = @"";
		
		self.indicator        = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(
			indicator_X, indicator_Y,
			INDICATOR_WIDTH, INDICATOR_HEIGHT)] autorelease];
		indicator.hidden = YES;
		
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[self addSubview:indicatorBackground];
		[self addSubview:indicatorLargeBackground];
		[self addSubview:descriptionLabel];
		[self addSubview:indicator];
	}
	return self;
}

- (void)dealloc {
	self.indicatorBackground		= nil;
	self.indicatorLargeBackground	= nil;
	self.descriptionLabel			= nil;
	self.indicator					= nil;
	[super dealloc];
}

- (void)start {
	indicatorBackground.hidden		=  NO;
	indicatorLargeBackground.hidden = YES;
	indicator.hidden				=  NO;
	descriptionLabel.hidden			= YES;
	[indicator startAnimating];
}

- (void)startInLargeMode {
	indicatorBackground.hidden		= YES;
	indicatorLargeBackground.hidden =  NO;
	indicator.hidden				=  NO;
	descriptionLabel.hidden			=  NO;
	[indicator startAnimating];
}
- (void)updateDescription:(NSString*)text {
	
	if (text == nil)
		return;
	descriptionLabel.text = getTextFromTable(text);
	descriptionLabel.hidden = NO;
}


- (void)stop {
	indicatorBackground.hidden		= YES;
	indicatorLargeBackground.hidden = YES;
	descriptionLabel.hidden			= YES;
	indicator.hidden				= YES;
	[indicator stopAnimating];
}

- (BOOL)isIndicatorAnimating
{
	return [indicator isAnimating];
}

@end
