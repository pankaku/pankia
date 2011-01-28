//
//  PNFormatUtil.h
//  PankakuNet
//
//  Created by sota on 10/09/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNItem;
@class PNSKProduct;
@class PNRank;
@interface PNFormatUtil : NSObject {

}

+ (NSString*)timeElapsedSinceDate:(NSString*)dateStr;
+ (NSString*)priceFormat:(double)price locale:(NSString*)locale;
+ (NSString*)quantityFormat:(PNItem*)item;
+ (NSString*)trimSpaces:(NSString*)string;
+ (NSString*)priceOfProduct:(PNSKProduct*)product;
+ (NSString*)stringWithComma:(int64_t)value;
+ (NSString*)stringRepresentationForRank:(PNRank*)rank;
@end
