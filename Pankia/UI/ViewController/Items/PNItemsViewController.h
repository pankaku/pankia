//
//  PNItemsViewController.h
//  PankakuNet
//
//  Created by sota on 10/09/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"

@interface PNItemsViewController : PNViewController {
	IBOutlet UIButton* storeButton;
	IBOutlet UIButton* purchaseHistoryButton;
}
- (IBAction)onMyItemsPressed;
- (IBAction)onStorePressed;
- (IBAction)onPurchaseHistoryPressed;
@end
