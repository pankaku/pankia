//
//  PNParseUtil.h
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PNParseUtil : NSObject {

}
+ (NSDate*)dateFromString:(NSString*)dateStr;
+ (NSString*)localizedStringForKey:(NSString*)key inDictionary:(NSDictionary*)dictionary defaultValue:(NSString*)defaultValue;
@end
