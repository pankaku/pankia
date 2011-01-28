//
//  PNLobbyViewController.h
//  PankakuNet
//
//  Created by pankaku on 10/08/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PNHeaderCell.h"

typedef enum {
	kPNInternetMatch,
	kPNNearbyMatch
} PNMatchType;

@interface PNLobbyViewController : PNTableViewController {
	IBOutlet PNHeaderCell*	headerCell_;	
	NSArray*				availableLobbies;
	PNMatchType				matchType;
}

@property (assign) IBOutlet PNHeaderCell*	headerCell_;
@property (retain) NSArray* availableLobbies;
@property (assign) PNMatchType matchType;

@end
