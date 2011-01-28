//
//  PNCountryCodeUtil.m
//  PankakuNet
//
//  Created by nakashima on 10/02/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNCountryCodeUtil.h"


@implementation PNCountryCodeUtil

+(NSString*)getNumericCodeForAlpha2Code:(NSString*)alpha2Code
{
	NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"plist"];
	NSDictionary* countryCodes = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	return [countryCodes objectForKey:alpha2Code];
}

+(UIImage*)getFlagImageForAlpha2Code:(NSString*)alpha2Code
{
	NSString* imageName = [[self getNumericCodeForAlpha2Code:alpha2Code] stringByAppendingString:@".png"];
	return [UIImage imageNamed:imageName];
}

@end
