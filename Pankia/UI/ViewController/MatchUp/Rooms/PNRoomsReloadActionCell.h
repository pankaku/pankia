//
//  PNRoomsReloadActionCell.h
//  PankakuNet
//
//  Created by nakashima on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNFixedTableCell.h"


@interface PNRoomsReloadActionCell : PNFixedTableCell {
	id delegate;
}

@property (retain) id delegate;
//- (IBAction)pressedReloadBtn:(id)sender;

@end
