//
//  PNSplashModel.h
//  PankakuNet
//
//  Created by sota2 on 10/10/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

#define kPNFieldNameForStartAt		@"start_at"
#define kPNFieldNameForEndAt		@"end_at"
#define kPNFieldNameForImageURL		@"image_url"
#define kPNFieldNameForLinkURL		@"link_url"
#define kPNFieldNameForText			@"text"
#define kPNFieldNameForId			@"id"
#define kPNFieldNameForIsDebug		@"is_debug"
#define kPNFieldNameForHasAppeared	@"has_appeared"

@interface PNSplashModel : PNDataModel {
	NSString* start_at;
	NSString* end_at;
	int _id;
	NSString* image_url;
	NSString* link_url;
	NSString* text;
	BOOL is_debug; 
}
@property (nonatomic, retain) NSString *start_at, *end_at, *image_url, *link_url, *text;
@property (nonatomic, assign) int id;
@property (nonatomic, assign) BOOL is_debug;
@end
