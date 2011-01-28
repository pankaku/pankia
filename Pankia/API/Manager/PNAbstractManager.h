//
//  PNAbstractManager.h
//  PankakuNet
//
//  Created by sota on 10/08/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNHTTPResponse.h"

@interface PNAbstractManager : NSObject {

}
- (void)defaultResponse:(PNHTTPResponse*)response;
@end
