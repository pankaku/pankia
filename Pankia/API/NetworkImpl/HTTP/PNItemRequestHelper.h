//
//  PNItemRequestHelper.h
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNHTTPRequestHelper.h"

@interface PNItemRequestHelper : PNHTTPRequestHelper {

}
+(void)acquireItems:(NSArray*)itemIdArray quantities:(NSArray*)quantities
		   delegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
+(void)consumeItems:(NSArray*)itemIdArray quantities:(NSArray*)quantities
		   delegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
+(void)getItemOwnershipsWithDelegate:(id)delegate
							selector:(SEL)selector
						  requestKey:(NSString*)key;

@end
