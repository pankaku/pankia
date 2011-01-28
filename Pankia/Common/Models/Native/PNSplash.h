//
//  PNSplash.h
//  PankakuNet
//
//  Created by sota2 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNSplashModel;
@interface PNSplash : NSObject <NSCoding> {
	NSDate* startAt;
	NSDate* endAt;
	int _id;
	NSString* imageURL;
	NSString* linkURL;
	NSString* text;
	BOOL isDebug;
	BOOL hasAppeared;
}
@property (nonatomic, retain) NSDate *startAt, *endAt;
@property (nonatomic, retain) NSString *imageURL, *linkURL, *text;
@property (nonatomic, assign) int id;
@property (nonatomic, assign) BOOL isDebug, hasAppeared;
+ (PNSplash*)splashFromModel:(PNSplashModel*)model;
- (BOOL)isValid;
@end
