//
//  PNFacebookManager.h
//  PankakuNet
//
//  Created by pankaku on 10/08/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PNError;
@interface PNFacebookManager : NSObject {

}
+ (PNFacebookManager*)sharedObject;

- (void)linkWithUid:(unsigned long long)uid sessionKey:(NSString*)sessionKey sessionSecret:(NSString*)sessionSecret delegate:(id)aDelegate
			   onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)unlinkWithDelegate:(id)aDelegate
			   onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
@end
