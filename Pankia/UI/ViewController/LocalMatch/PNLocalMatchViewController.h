//
//  PNLocalMatchViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLobby.h"
#import "PNTableViewController.h"

// ローカル対戦で部屋の選択のUIを使うかどうかの設定です。
#define kPNSelectionOfTheLocalRoomUse YES

@interface PNLocalMatchViewController : PNTableViewController {
@private	
	NSArray*		nearbyMatch_;
	NSArray*		dataSource_;
	NSMutableArray* iconImages_;
	PNLobby*		lobby_;	
}
@property (retain) PNLobby* lobby_;

@end
