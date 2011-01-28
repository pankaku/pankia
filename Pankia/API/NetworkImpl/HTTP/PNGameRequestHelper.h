//
//  PNGameRequestHelper.h
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNHTTPRequestHelper.h"

@interface PNGameRequestHelper : PNHTTPRequestHelper {

}
+ (void)getDetailsOfGame:(NSString*)gameId delegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
+ (void)getCategoriesWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
+ (void)getGradesWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
+ (void)getItemsWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
+ (void)getVersionsWithDelegate:(id)delegate selector:(SEL)selector requestKey:(NSString*)key;
@end
