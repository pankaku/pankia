//
//  PNPreview.m
//  PankakuNet
//
//  Created by あんのたん on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNPreview.h"
#import "PNImageUtil.h"
#import "PNLogger+Package.h"
#import "PNDashboard.h"

@implementation PNPreview

- (id)init {
	self = [super init];
	if (self) {		
		CGRect r = [UIScreen mainScreen].bounds;
		previewWindow = [[UIWindow alloc] initWithFrame:r];
		previewWindow.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		autoRotateViewController = [[PNAutoRotateViewController alloc] init];
		autoRotateViewController.rotationDelegate = [PNDashboard sharedObject];
		autoRotateViewController.view.frame = r;
		autoRotateViewController.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		[previewWindow addSubview:autoRotateViewController.view];
		
		imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, r.size.height, r.size.width)];
		[imageButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
		[autoRotateViewController.view addSubview:imageButton];
		
		indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.frame = CGRectMake(previewWindow.frame.size.width / 2 - 16, previewWindow.frame.size.height / 2 - 16, 37, 37);
		indicator.hidden = YES;
		[previewWindow addSubview:indicator];
	}
	
	return self;
}

- (void)showWithImage:(UIImage *)aImage {
	mainWindow = [[UIApplication sharedApplication] keyWindow];

	[imageButton setImage:aImage forState:UIControlStateNormal];
	imageButton.contentMode = UIViewContentModeScaleAspectFit;
	imageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	[previewWindow makeKeyAndVisible];
	previewWindow.alpha = 0.0f;
	
	[UIView beginAnimations:@"PNShowPreViewAnimation" context:nil];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelegate:self];
	previewWindow.alpha = 1.0f;
	[UIView setAnimationDidStopSelector:@selector(showAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void)loadImageFromUrl:(NSString*)url
{
	if ([PNImageUtil hasCacheForUrl:url]){
		indicator.hidden = YES;
		[indicator stopAnimating];
		UIImage* image = [UIImage imageWithContentsOfFile:[PNImageUtil cacheFilePathForURL:url]];
		
		if (image.size.width < image.size.height) {
			imageButton.imageView.transform = CGAffineTransformMakeRotation(-90.0f / 180.0f * M_PI);
		} else {
			imageButton.imageView.transform = CGAffineTransformMakeRotation(0.0f);
		}

		imageButton.contentMode = UIViewContentModeCenter;
		[imageButton setImage:image forState:UIControlStateNormal];
		loading = NO;
	} else {
		// キャッシュがなければダウンロードしにいき、数秒後に更新します
		if (loading == NO)
		{
			PNCLog(PNLOG_CAT_ITEM, @"load %@", url);
			[PNImageUtil createCacheForUrl:url];
			indicator.hidden = NO;
			[indicator startAnimating];
		}
		loading = YES;
		[self performSelector:@selector(loadImageFromUrl:) withObject:url afterDelay:0.5f];
	}
	
}

- (void)showAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
}

- (void)hide {
	[UIView beginAnimations:@"PNHidePreViewAnimation" context:nil];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelegate:self];
	previewWindow.alpha = 0.0f;
	[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[mainWindow makeKeyWindow];
	mainWindow = nil;
}

- (void)dealloc {
	[previewWindow release];
	previewWindow = nil;
	[autoRotateViewController release];
	autoRotateViewController = nil;
	[indicator release];
	[super dealloc];
}

@end
