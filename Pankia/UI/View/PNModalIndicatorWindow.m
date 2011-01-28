//
//  PNModalIndicatorWindow.m
//  PankakuNet
//
//  Created by あんのたん on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNModalIndicatorWindow.h"

@implementation PNModalIndicatorWindow
@synthesize isActive;

- (id)init {
	return [super initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)show {
	indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	indicator.frame = CGRectMake(self.frame.size.width / 2 - 16, self.frame.size.height / 2 - 16, 37, 37);
	[self addSubview:indicator];
	self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
	mainWindow = [[[UIApplication sharedApplication] keyWindow] retain];
	[self makeKeyAndVisible];
	[indicator startAnimating];
	self.isActive = YES;
}

- (void)hide {
	[mainWindow makeKeyAndVisible];
	[mainWindow release];
	mainWindow = nil;
	[indicator stopAnimating];
	[indicator release];
	indicator = nil;
	self.isActive = NO;
}

- (void)dealloc {
	[mainWindow release];
	[indicator release];
	[super dealloc];
}

@end
