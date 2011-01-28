//
//  PNSimpleSessionManager.h
//  PankakuNet
//
//  Created by sota2 on 10/10/25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PNSimpleSessionManager : NSObject {

}
+ (PNSimpleSessionManager*)sharedObject;
- (void)createSessionWithDelegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
						 onFailed:(SEL)onFailedSelector withObject:(id)anObject;
@end
