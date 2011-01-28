//
//  PNSKProduct.h
//  PankakuNet
//
//  Created by sota2 on 10/09/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKProduct;
@interface PNSKProduct : NSObject <NSCoding> {
	NSString* productIdentifier;
	NSString* localizedTitle;
	NSString* localizedDescription;
	NSDecimalNumber* price;
	NSLocale* priceLocale;
}
@property (nonatomic, retain) NSString* productIdentifier;
@property (nonatomic, retain) NSString* localizedTitle;
@property (nonatomic, retain) NSString* localizedDescription;
@property (nonatomic, retain) NSDecimalNumber* price;
@property (nonatomic, retain) NSLocale* priceLocale;
+ (PNSKProduct*)productFromSKProduct:(SKProduct*)product;
@end
