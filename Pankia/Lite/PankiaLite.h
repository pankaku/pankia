//
//  PankiaLite.h
//  PankiaLite
//
//  Created by sota2 on 10/10/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNGlobal.h"

#define PANKIA_LITE_NO	// DEFINE PANKIA_LITE for LITE EDITION
#import "PNExtendedAppDelegate.h"
@interface PankiaLite : NSObject <PNAppDelegateProtocol> {

}
+ (void)initWithGameKey:(NSString*)gameKey secret:(NSString*)secret options:(NSDictionary*)options;
@end
