//
//  UIWebView+PankiaDashboardExtension.h
//  PankakuNet
//
//  Created by sota on 11/01/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIWebView(PankiaDashboardExtension)
- (void)loadDashboardURL:(NSURL*)url;
- (void)loadHTMLStringForURL:(NSURL*)url;
@end
