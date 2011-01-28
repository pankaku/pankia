//
//  PNPurchaseModel.h
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

@interface PNPurchaseModel : PNDataModel {
	NSString* merchandise_id;
	NSString* locale;
	double price;
	NSString* purchase_date;
}
@property (nonatomic, retain) NSString* merchandise_id;
@property (nonatomic, retain) NSString* locale;
@property (nonatomic, retain) NSString* purchase_date;
@property (nonatomic, assign) double price;
@end
