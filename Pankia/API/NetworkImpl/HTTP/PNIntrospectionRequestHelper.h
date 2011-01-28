//
//  PNIntrospectionRequestHelper.h
//  PankakuNet
//
//  Created by sota2 on 10/10/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNHTTPRequestHelper.h"

@interface PNIntrospectionRequestHelper : PNHTTPRequestHelper {
	
}
+(void)sendReport:(NSString*)text level:(NSString*)level delegate:(id)delegate 
		 selector:(SEL)selector requestKey:(NSString*)key;
@end
