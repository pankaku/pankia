//
//  PNLobbyViewCell.h
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNLobby;

@interface PNLobbyViewCell : UITableViewCell {

}

// The designated initializer.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withLobby:(PNLobby *)lobby;

@end
