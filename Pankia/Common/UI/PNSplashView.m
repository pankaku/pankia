//
//  PNSplashView.m
//  PankakuNet
//
//  Created by sota2 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSplashView.h"
#import "PNSplash.h"
#import "UIView+Slide.h"
#import "PNImageUtil.h"
#import "PNSplashManager.h"

#define kPNBackgroundImage    @"PNImageFrame300x200.png"
#define kPNDismissButtonImage @"PNDismissButton50.png"

@interface PNSplashView ()
@property (nonatomic, retain) PNSplash* splash;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, retain) PNAutoRotateViewController* autoRotateViewController;
- (void)show;
- (void)layoutSubviews;
- (void)loadImageFromUrl:(NSString*)url;
- (void)showAd;
@end

@implementation PNSplashView
@synthesize splash, currentOrientation, autoRotateViewController, autoRotateEnabled;

- (id)init
{
	if (self = [super init]) {
		
		autoRotateEnabled = YES;
		
		CGRect r = [UIScreen mainScreen].bounds;
		splashWindow = [[UIWindow alloc] initWithFrame:r];
		splashWindow.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
		self.autoRotateViewController = [[[PNAutoRotateViewController alloc] init] autorelease];
		autoRotateViewController.rotationDelegate = self;
		autoRotateViewController.view.frame = r;
		
		imageButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, r.size.height, r.size.width)] autorelease];
		[imageButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
		[autoRotateViewController.view addSubview:imageButton];
		
		backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNBackgroundImage]] autorelease];
		[autoRotateViewController.view addSubview:backgroundView];
		
		adImageView = [[[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 270.0f, 180.0f)] autorelease];
		adImageView.backgroundColor = [UIColor blackColor];
		[adImageView addTarget:self action:@selector(showAd) forControlEvents:UIControlEventTouchUpInside];
		[autoRotateViewController.view addSubview:adImageView];
		
		dismissButton = [[[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)] autorelease];
		UIImage* dismissButtonImage = [UIImage imageNamed:kPNDismissButtonImage];
		[dismissButton setImage:dismissButtonImage forState:UIControlStateNormal];
		[dismissButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
		[autoRotateViewController.view addSubview:dismissButton];

		[splashWindow addSubview:autoRotateViewController.view];
		
		indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.frame = CGRectMake(splashWindow.frame.size.width / 2 - 16, splashWindow.frame.size.height / 2 - 16, 37, 37);
		indicator.hidden = YES;
		[splashWindow addSubview:indicator];
	}
	return self;
}

- (void)layoutSubviews
{
	BOOL isLandscape = (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight);
	float windowWidth = splashWindow.frame.size.width;
	float windowHeight = splashWindow.frame.size.height;
	
	float longerSize = fmaxf(windowWidth, windowHeight);
	float shorterSize = fminf(windowWidth, windowHeight);
	
	float containerWidth = isLandscape ? longerSize : shorterSize;
	float containerHeight = isLandscape ? shorterSize : longerSize;
	
	[imageButton setWidth:containerWidth height:containerHeight];
	[imageButton moveToCenterInWidth:containerWidth height:containerHeight];
	[backgroundView moveToCenterInWidth:containerWidth height:containerHeight];
	[adImageView moveToX:backgroundView.frame.origin.x + 15.0f
					   y:backgroundView.frame.origin.y + 10.0f];
	[dismissButton moveToX:backgroundView.frame.origin.x + backgroundView.frame.size.width - dismissButton.frame.size.width + 15.0f
						 y:backgroundView.frame.origin.y - 17.0f];
}
- (void)setCurrentOrientation:(UIInterfaceOrientation)orientation
{
	currentOrientation = orientation;
	[self layoutSubviews];
}
- (void)showAd
{
	[[PNSplashManager sharedObject] sendPingToServer:splash target:kPNSplashPingTargetVisited 
											delegate:self onSucceeded:@selector(pingSent) onFailed:@selector(pingSent)];
}
- (void)pingSent
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:splash.linkURL]];
}
- (void)show
{
	[self retain];	// will be released when hide
	
	mainWindow = [[UIApplication sharedApplication] keyWindow];
	[splashWindow makeKeyAndVisible];
	
	[self loadImageFromUrl:splash.imageURL];
	
	// Opening animation
	
	splashWindow.alpha = 0.0f;
	CGRect backgroundTargetFrame = backgroundView.frame;
	CGRect dismissButtonTargetFrame = dismissButton.frame;
	CGRect adViewTargetFrame = adImageView.frame;
	
	[backgroundView slideX:0.0f y:100.0f];
	[dismissButton slideX:0.0f y:100.0f];
	[adImageView slideX:0.0f y:100.0f];
		
	[UIView beginAnimations:@"PNShowSplashAnimation" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	splashWindow.alpha = 1.0f;
	backgroundView.frame = backgroundTargetFrame;
	dismissButton.frame = dismissButtonTargetFrame;
	adImageView.frame = adViewTargetFrame;
	[UIView setAnimationDidStopSelector:@selector(showAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}
- (void)hide
{
	[mainWindow makeKeyWindow];
	mainWindow = nil;
	[splashWindow release];
	splashWindow = nil;
	[self release];
}

+ (PNSplashView*)showSplash:(PNSplash *)splashToShow orientation:(UIInterfaceOrientation)orientation
{
	PNSplashView* anInstance = [[[PNSplashView alloc] init] autorelease];
	anInstance.splash = splashToShow;
	anInstance.currentOrientation = orientation;
	[anInstance show];
	
	return anInstance;
}

- (void)loadImageFromUrl:(NSString*)url
{
	if ([PNImageUtil hasCacheForUrl:url]){
		indicator.hidden = YES;
		[indicator stopAnimating];
		UIImage* image = [UIImage imageWithContentsOfFile:[PNImageUtil cacheFilePathForURL:url]];
		adImageView.contentMode = UIViewContentModeCenter;
		[adImageView setImage:image forState:UIControlStateNormal];
		loading = NO;
	} else {
		// キャッシュがなければダウンロードしにいき、数秒後に更新します
		if (loading == NO)
		{
			[PNImageUtil createCacheForUrl:url];
			indicator.hidden = NO;
			[indicator startAnimating];
		}
		loading = YES;
		[self performSelector:@selector(loadImageFromUrl:) withObject:url afterDelay:0.5f];
	}
	
}

- (void)dealloc
{
	self.splash = nil;
	self.autoRotateViewController = nil;
	[super dealloc];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[self layoutSubviews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	currentOrientation = interfaceOrientation;
	return autoRotateEnabled; 
}

@end
