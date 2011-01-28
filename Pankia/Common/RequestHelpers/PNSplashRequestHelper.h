//
//  PNSplashRequestHelper.h
//  PankiaLite
//
//  Created by sota2 on 10/10/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNHTTPRequestHelper.h"


@interface PNSplashRequestHelper : PNHTTPRequestHelper {

}
+ (void) sendAckToServerForSplashId:(int)splashId delegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
+ (void) sendPingToServerForSplashId:(int)splashId targets:(NSArray*)targets 
							delegate:(id)delegate selector:(SEL)selector key:(NSString*)key;
@end
