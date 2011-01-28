//
//  NSURL+NativeConnection.h
//  PankakuNet
//
//  Created by あんのたん on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kPankiaNativeConnectionWindowCloseNotification;
extern NSString* const kPankiaNativeConnectionHideIndicatorNotification;
extern NSString* const kPankiaNativeConnectionShowIndicatorNotification;

@interface NSURL (NativeConnection)
- (NSDictionary*)params;
- (BOOL)nativeActionWithWebView:(UIWebView *)aWebView;
- (BOOL)isNativeRequest;
- (NSString*)navigationBarTitle;
@end
