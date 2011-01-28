//
//  PNMatchManager.h
//  PankakuNet
//
//  Created by sota on 10/08/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNAbstractManager.h"

@class PNGameSet;
@class PNRoom;

@interface PNMatchManager : PNAbstractManager {

}
+ (PNMatchManager*)sharedObject;
- (void)finish:(PNGameSet*)gameSet room:(PNRoom*)room delegate:(id)selegate onSucceeded:(SEL)onSucceededSelector
	  onFailed:(SEL)onFailedSelector;
@end
