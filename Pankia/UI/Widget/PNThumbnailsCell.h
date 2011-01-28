//
//  PNThumbnailsCell.h
//  PankakuNet
//
//  Created by sota on 10/09/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNThumbnailView.h"

#define kPNNumOfThumbs 4

@interface PNThumbnailsCell : UITableViewCell {
	NSArray* thumbnails;
	int numOfUse;
	int selectedImage;
	float leftOffset;
	float eachWidth, eachHeight;
}
@property (nonatomic, retain) NSArray* thumbnails;
- (void)hideAllThumbnails;
- (void)addThumbnailFromURL:(NSString*)url;
- (void)addThumbnailFromURL:(NSString*)url originalUrl:(NSString*)originalUrl;
@end
