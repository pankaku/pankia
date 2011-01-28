//
//  PNStoreRequestHelper.h
//  PankakuNet
//
//  Created by sota on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNHTTPRequestHelper.h"
#import "PNNetworkError.h"

@interface PNStoreRequestHelper : PNHTTPRequestHelper {

}
+(void)registerReceipt:(NSString*)receipt
				 price:(float)price
				locale:(NSString*)locale
				delegate:(id)delegate
				selector:(SEL)selector
			  requestKey:(NSString*)key;
+(void)getMerchandisesWithDelegate:(id)delegate
						  selector:(SEL)selector
						requestKey:(NSString*)key;
+(void)getPurchaseHistoryWithOffset:(int)offset
							  limit:(int)limit
						   delegate:(id)delegate
						   selector:(SEL)selector
						 requestKey:(NSString*)key;
@end
