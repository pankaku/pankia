//
//  PNVerifyUtil.m
//  PankakuNet
//
//  Created by pankaku on 10/05/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNVerifyUtil.h"
#import "NSData+Utils.h"

@implementation PNVerifyUtil

/**
 * @brief 指定したIDのアチーブメントの解放をリクエストするときに必要なverifierStringを返します
 */
+(NSString*)verifierStringForAchievementId:(int)achievementId session:(NSString*)session secret:(NSString*)secret{
	NSString* rawStr = [NSString stringWithFormat:@"%@%@%d",secret,session,achievementId];
	return [NSData sha1FromString:rawStr];
}
@end
