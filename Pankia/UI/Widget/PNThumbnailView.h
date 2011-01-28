//
//  PNThumbnailView.h
//  PankakuNet
//
//  Created by sota on 10/09/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PNThumbnailView : UIImageView {
	UIImageView* thumbnail;
	UIActivityIndicatorView* indicator;
	NSString* originalUrl;
	BOOL loading;
}
@property (nonatomic, retain) UIActivityIndicatorView* indicator;
@property (nonatomic, retain) NSString* originalUrl;
+ (PNThumbnailView*)viewWithImageURL:(NSString*)url;
- (void)loadImageFromURL:(NSString*)url;
@end
