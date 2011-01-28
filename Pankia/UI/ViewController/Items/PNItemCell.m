//
//  PNItemCell.m
//  PankiaNet
//
//  Created by Wencheng FANG
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNItemCell.h"
#import "PNPurchaseModel.h"
#import "PNStoreManager.h"
#import "PNFormatUtil.h"
#import "PNItem.h"
#import "PNMerchandise.h"

@implementation PNItemCell

@synthesize iconImage, merchandiseNameLabel, priceLabel, datetimeLabel, purchase;

- (void)setPurchase:(PNPurchaseModel*)p
{
	if (purchase != nil){
		[purchase release];
		purchase = nil;
	}
	purchase = [p retain];
	
	[self.headIcon setImage:nil];
	
	PNMerchandise* merchandise = [[PNStoreManager sharedObject] merchandiseWithProductIdentifier:purchase.merchandise_id];
	self.merchandiseNameLabel.text = (merchandise != nil) ? merchandise.name : @"-";
	
	if (merchandise != nil) {
		PNItem* item = [PNItem itemWithId:[merchandise.item_id intValue]];
		[self.headIcon loadImageWithUrl:item.iconUrl];
	}
	
	self.priceLabel.text = [PNFormatUtil priceFormat:p.price locale:p.locale];
	self.datetimeLabel.text = [PNFormatUtil timeElapsedSinceDate:purchase.purchase_date];
}

- (void)dealloc
{
	[iconImage release];
	[nameLabel release];
	[priceLabel release];
    [datetimeLabel release];
	
	self.purchase = nil;
	
    [super dealloc];
}


@end
