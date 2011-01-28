//
//  PNAbstractManager.m
//  PankakuNet
//
//  Created by sota on 10/08/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNAbstractManager.h"
#import "PNRequestKeyManager.h"
#import "PNHTTPRequestHelper.h"
#import "PNError.h"
#import "NSObject+PostEvent.h"

@implementation PNAbstractManager
/*
 * ただstatus=okかどうかをみてonSucceeded / onFailedのセレクタを呼ぶだけの処理はこのメソッドで処理します。
 */
- (void)defaultResponse:(PNHTTPResponse*)response {
	NSString* requestKey = [response requestKey];
	NSString* resp = [response jsonString];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];	
	id delegate = request.delegate;
	SEL onSucceededSelector = request.onSucceededSelector;
	SEL onFailedSelector = request.onFailedSelector;
	id object = request.object;
	
	if(response.isValidAndSuccessful) {
		if([delegate respondsToSelector:onSucceededSelector]){
			if (object) {
				[delegate performSelector:onSucceededSelector withObject:object];
			} else {
				[delegate performSelector:onSucceededSelector];
			}
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		if([delegate respondsToSelector:onFailedSelector]){
			if (object) {
				[delegate performSelector:onFailedSelector withObjects:[NSArray arrayWithObjects:error, object, nil]];
			} else {
				[delegate performSelector:onFailedSelector withObject:error];
			}
		}				
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
@end
