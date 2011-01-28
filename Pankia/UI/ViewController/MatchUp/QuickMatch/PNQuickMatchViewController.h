//
//  PNQuickMatchViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNQuickMatchViewController.h"
#import "PNViewController.h"
#import "PankiaNetworkLibrary.h"
#import "PNRoomCell.h"
#import "PNRoomNoneCell.h"
#import "PNJoinedRoomViewController.h"
#import "PNLocalizableLabel.h"
#import "PNLobby.h"

typedef enum {
	kPNQuickMatchStateNone,
	kPNQuickMatchStateCreating,
	kPNQuickMatchStateCreated,
	kPNQuickMatchStateFinding,
	kPNQuickMatchStateStarting
} MatchingStatus;

@interface PNQuickMatchViewController : PNViewController<PNRoomManagerDelegate, PNRoomDelegate, PNGameSessionDelegate> {
	
	NSMutableArray*			failedRoomNames;
	UIBarButtonItem*		cancelButton;
	UILabel*				lobbyName;
	
	PNRoomCell*		        matchUpRoomCell;
	PNRoomNoneCell*         noneCell;
	PNRoom*					roomToJoin;
	PNGameSession*			currentGameSession;
	PNLocalizableLabel*		statusLabel;
	PNLobby*				lobby;	
	
	PNJoinedRoomViewController*		joinedRoomViewController;	//部屋に入室した場合はJoinedRoomViewController,作った場合はMyRoomViewControllerになります
	MatchingStatus currentStatus;
	
	BOOL hasJoinedRoomViewControllerPushed;
	BOOL shouldCancelMatching;
	BOOL canCancelMatching;
	BOOL isPushedCancelButton;
}

@property (assign) IBOutlet	PNRoomCell*			matchUpRoomCell;
@property (assign) IBOutlet PNRoomNoneCell*		noneCell;
@property (retain) IBOutlet PNLocalizableLabel*	statusLabel;
@property (retain) IBOutlet UILabel*			lobbyName;
@property (retain) PNLobby*						lobby;
@property (retain) PNRoom*						roomToJoin;
@property (retain) NSMutableArray*				failedRoomNames;
@property (retain) PNJoinedRoomViewController*	joinedRoomViewController;
@property (retain) PNGameSession*				currentGameSession;

@end
