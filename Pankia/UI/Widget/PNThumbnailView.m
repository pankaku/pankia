//
//  PNThumbnailView.m
//  PankakuNet
//
//  Created by sota on 10/09/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNThumbnailView.h"
#import "PNLogger+Package.h"
#import "PNImageUtil.h"
#import "PNDashboard.h"

#define kPNFrameImageLandscape	@"PNThumbnailBackgroundImage"
#define kPNFrameImagePortrait	@"PNThumbnailBackgroundImagePortrait"

@interface PNThumbnailView ()
@property (nonatomic, retain) UIImageView* thumbnail;
@end

@implementation PNThumbnailView
@synthesize indicator, thumbnail, originalUrl;

- (void)loadImageFromURL:(NSString*)url
{
	if ([PNImageUtil hasCacheForUrl:url]){
		UIImage* image = [UIImage imageWithContentsOfFile:[PNImageUtil cacheFilePathForURL:url]];
		
		if (image.size.width < image.size.height) {
			thumbnail.transform = CGAffineTransformMakeRotation(-90.0f / 180.0f * M_PI);
		}
		thumbnail.contentMode = UIViewContentModeCenter;
		thumbnail.image = image;
		[self setNeedsDisplay];
		indicator.hidden = YES;
		[indicator stopAnimating];
		loading = NO;
	} else {
		// キャッシュがなければダウンロードしにいき、数秒後に更新します
		if (loading == NO)
		{
			PNCLog(PNLOG_CAT_ITEM, @"load %@", url);
			[PNImageUtil createCacheForUrl:url];
		}
		loading = YES;
		[self performSelector:@selector(loadImageFromURL:) withObject:url afterDelay:0.5f];
		[indicator startAnimating];
	}
	return;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
	if (self = [super initWithImage:image]) {
		loading = NO;
		
		self.thumbnail = [[[UIImageView alloc] initWithImage:nil] autorelease];
		[self addSubview:thumbnail];
		thumbnail.frame = CGRectMake(5.0f, 5.0f, 180.0f, 135.0f);
		
		indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
		[self addSubview:indicator];
		float indicatorSize = 32.0f;
		indicator.frame = CGRectMake(95.0f - indicatorSize * 0.5f, 77.0f - indicatorSize * 0.5f, indicatorSize, indicatorSize);
		indicator.hidden = YES;
	}
	return self;
}

+ (PNThumbnailView*)viewWithImageURL:(NSString*)url
{
	NSString* frameImage = [[PNDashboard sharedObject] isLandscapeMode] ? kPNFrameImageLandscape : kPNFrameImagePortrait;
	PNThumbnailView* instance = [[[PNThumbnailView alloc] initWithImage:[UIImage imageNamed:frameImage]] autorelease];
	if (url) [instance loadImageFromURL:url];
	return instance;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	self.thumbnail = nil;
	self.indicator = nil;
    [super dealloc];
}


@end
