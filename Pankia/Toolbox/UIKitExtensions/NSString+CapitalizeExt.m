//
//  NSString+CapitalizeExt.m
//  PankakuNet
//
//  Created by sota2 on 10/12/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+CapitalizeExt.h"


@implementation NSString(CapitalizeExt)
- (NSString*) firstCharacterCapitalizedString
{
	if ([self length] <= 1) return [[self copy] autorelease];
	return [[[self substringToIndex:1] capitalizedString] stringByAppendingString:[self substringFromIndex:1]];
}
@end
