//
//  PNWGameController.m
//  PankakuNet
//
//  Created by sota2 on 10/12/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNWGameController.h"
#import "PNGameManager.h"
#import "NSString+CapitalizeExt.h"
#import "PNAPIHTTPDefinition.h"
#import "PNNativeRequest.h"

@implementation PNWGameController

- (void)show
{
	[self asyncRequest:kPNHTTPRequestCommandGameShow];
}

- (void)performRequest:(PNNativeRequest *)aRequest
{
	// マスターデータ取得系APIであれば、ここでハンドリングします
	NSString* masterSelectorName = [NSString stringWithFormat:@"latest%@JSONString", [aRequest.selectorName firstCharacterCapitalizedString]];
	SEL selector = NSSelectorFromString(masterSelectorName);
	if ([[PNGameManager sharedObject] respondsToSelector:selector]) {
		aRequest.response = [[PNGameManager sharedObject] performSelector:selector];
	} else {
		[super performRequest:aRequest];
	}
}
@end
