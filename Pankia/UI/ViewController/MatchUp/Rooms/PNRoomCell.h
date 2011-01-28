//
//  PNRoomCell.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableCell.h"

/**
 @brief インターネットルームの一覧情報を表示するCellクラスです。
 PNRoomsViewControllerに所属。
 */
@interface PNRoomCell : PNTableCell {
	BOOL islocked_;
	UIImageView*	imageView;
}

@property BOOL islocked_;

- (void)lock;
- (void)unlock;

@end
