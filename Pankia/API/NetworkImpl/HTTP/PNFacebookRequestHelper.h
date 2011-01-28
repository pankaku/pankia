//
//  PNFacebookRequestHelper.h
//  PankakuNet
//
//  Created by pankaku on 10/08/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNHTTPRequestHelper.h"

@interface PNFacebookRequestHelper : PNHTTPRequestHelper {
	
}
+ (void)linkWithUid:(unsigned long long)uid sessionKey:(NSString*)sessionKey sessionSecret:(NSString*)sessionSecret delegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void)unlinkWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void)importGraphWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void)verifyWithDelegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
@end
