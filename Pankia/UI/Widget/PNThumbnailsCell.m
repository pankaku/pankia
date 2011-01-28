//
//  PNThumbnailsCell.m
//  PankakuNet
//
//  Created by sota on 10/09/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNThumbnailsCell.h"
#import "PNDashboard.h"

@implementation PNThumbnailsCell
@synthesize thumbnails;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	int col = (int)floor((location.x - leftOffset) / eachWidth);
	int row = (int)floor(location.y / eachHeight);
	
	
	int index = col + row * 2;
	
	if (index >= 0 && index <= 3) {
		if ([thumbnails count] > index) {
			selectedImage = index;
		}
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	int col = (int)floor((location.x - leftOffset) / eachWidth);
	int row = (int)floor(location.y / eachHeight);
	
	int index = col + row * 2;
	
	if (index >= 0 && index <= 3) {
		if ([thumbnails count] > index && selectedImage == index) {
			PNThumbnailView* thumb = [thumbnails objectAtIndex:index];
			if (thumb.hidden == NO) {
				[PNDashboard showImage:thumb.originalUrl];
			}
		}
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	eachWidth = ([[PNDashboard sharedObject] isLandscapeMode]) ? 190.0f : 145.0f;
	eachHeight = ([[PNDashboard sharedObject] isLandscapeMode]) ? 145.0f : 190.0f;
	leftOffset = [[PNDashboard sharedObject] isLandscapeMode] ? 10.0f : 2.0f;
	
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		NSMutableArray* thumbs = [NSMutableArray array];
        for (int i = 0; i < kPNNumOfThumbs; i++) {
			PNThumbnailView* thumbnail = [PNThumbnailView viewWithImageURL:nil];
			
			if ([[PNDashboard sharedObject] isLandscapeMode]) {
				thumbnail.transform = CGAffineTransformMakeRotation(0.0f);
			} else {
				thumbnail.transform = CGAffineTransformMakeRotation(90.0f / 180.0f * M_PI);
			}
			thumbnail.frame = CGRectMake(leftOffset + (float)(i % 2) * eachWidth, (i / 2) * eachHeight, eachWidth, eachHeight);
			

			thumbnail.hidden = YES;
			[thumbs addObject:thumbnail];
			[self.contentView addSubview:thumbnail];
		}
		self.thumbnails = [thumbs retain];
		numOfUse = 0;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)hideAllThumbnails
{
	for (PNThumbnailView* thumbnail in thumbnails) {
		thumbnail.hidden = YES;
	}
	numOfUse = 0;
}

- (void)addThumbnailFromURL:(NSString*)urlString
{
	if (numOfUse == kPNNumOfThumbs) return;
	
	PNThumbnailView *thumbnail = [thumbnails objectAtIndex:numOfUse];
	
	thumbnail.hidden = NO;
	[thumbnail loadImageFromURL:urlString];
	
	NSString* originalUrlString;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
		NSURL* url = [NSURL URLWithString:urlString];
		NSMutableArray* urlComponents = [NSMutableArray arrayWithArray:[url pathComponents]];
		NSString* fileName = [urlComponents lastObject];
		NSString* extension = [fileName pathExtension];
		NSString* originalFileName = [@"1024x768." stringByAppendingString:extension];
		[urlComponents removeLastObject];
		[urlComponents addObject:originalFileName];
		
		NSURL* originalUrl = [[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:originalFileName];
		originalUrlString = [originalUrl absoluteString];
	} else {
		NSString* fileName = [[urlString componentsSeparatedByString:@"/"] lastObject];
		NSString* extension = [fileName pathExtension];
		originalUrlString = [urlString stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"1024x768.%@", extension]];
	}

	thumbnail.originalUrl = originalUrlString;

	numOfUse++;
}
- (void)addThumbnailFromURL:(NSString*)url originalUrl:(NSString*)originalUrl
{
	if (numOfUse == kPNNumOfThumbs) return;
	
	PNThumbnailView *thumbnail = [thumbnails objectAtIndex:numOfUse];
	
	thumbnail.hidden = NO;
	thumbnail.originalUrl = originalUrl;
	[thumbnail loadImageFromURL:url];
	
	numOfUse++;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   // [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.thumbnails = nil;
    [super dealloc];
}


@end
