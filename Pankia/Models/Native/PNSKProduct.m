//
//  PNSKProduct.m
//  PankakuNet
//
//  Created by sota2 on 10/09/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSKProduct.h"
#import <StoreKit/StoreKit.h>

@implementation PNSKProduct
@synthesize productIdentifier, price, priceLocale, localizedTitle, localizedDescription;

+ (PNSKProduct*)productFromSKProduct:(SKProduct*)product
{
	PNSKProduct* instance = [[[PNSKProduct alloc] init] autorelease];
	instance.productIdentifier = product.productIdentifier;
	instance.price = product.price;
	instance.priceLocale = product.priceLocale;
	instance.localizedTitle = product.localizedTitle;
	instance.localizedDescription = product.localizedDescription;
	return instance;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:productIdentifier forKey:@"product_identifier"];
	[coder encodeObject:price forKey:@"price"];
	[coder encodeObject:priceLocale forKey:@"price_locale"];
	[coder encodeObject:localizedTitle forKey:@"localized_title"];
	[coder encodeObject:localizedDescription forKey:@"localized_description"];
}
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
	self.productIdentifier = [decoder decodeObjectForKey:@"product_identifier"];
	self.price = [decoder decodeObjectForKey:@"price"];
	self.priceLocale = [decoder decodeObjectForKey:@"price_locale"];
	self.localizedTitle = [decoder decodeObjectForKey:@"localized_title"];
	self.localizedDescription = [decoder decodeObjectForKey:@"localized_description"];
    return self;
}
@end
