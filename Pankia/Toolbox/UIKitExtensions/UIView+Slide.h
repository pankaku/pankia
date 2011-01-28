//
//  UILabel+Slide.h
//  PankakuNet
//
//  Created by pankaku on 10/06/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView(Slidable)
- (void)slideX:(float)x y:(float)y;
- (void)moveToX:(float)x y:(float)y;
- (void)setWidth:(float)width height:(float)height;
- (void)moveToCenterInWidth:(float)width height:(float)height;
@end
