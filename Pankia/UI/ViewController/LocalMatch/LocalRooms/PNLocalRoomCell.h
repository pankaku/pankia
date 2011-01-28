//
//  PNLocalRoomCell.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableCell.h"

/**
 @brief 入室可能なローカルルームの一覧を表示するCellクラスです。
 PNLocalRoomsViewControllerに所属。
 */
@interface PNLocalRoomCell : PNTableCell {
}

- (void)setRoomName:(NSString *)newRoomName;

@end
