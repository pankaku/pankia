//
//  PNJoinedRoomViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PankiaNetworkLibrary.h"
#import "PNJoinedRoomCell.h"
#import "PNJoinedRoomEventCell.h"
#import "PNHeaderCell.h"
#import "PNTableViewController.h"


typedef enum {
	kPNInternetMatchRoomJoiningNone,
	kPNInternetMatchRoomJoiningStartPairing,
	kPNInternetMatchRoomJoiningStartPunching,
	kPNInternetMatchRoomJoiningReport,
	kPNInternetMatchRoomJoiningDone
} PNInternetRoomJoiningPhase;

typedef enum {
	kPNInternetMatchRoomUserStateLoading,			// 部屋の情報をロード中
	kPNInternetMatchRoomUserStateObserving,			// 部屋を外から見ている
	kPNInternetMatchRoomUserStateRequesting,		// 入室リクエストを送っている
	kPNInternetMatchRoomUserStateJoining,			// 入室中
	kPNInternetMatchRoomUserStateLeaving,			// 退室リクエストを送っている
	kPNInternetMatchRoomUserStateBuyingCoins		// コイン購入手続き中
} PNInternetRoomUserState;


@interface PNJoinedRoomViewController : PNTableViewController <PNRoomDelegate,PNRoomManagerDelegate,PNGameSessionDelegate> {
	
	IBOutlet PNHeaderCell*				headerCell_;
	IBOutlet PNJoinedRoomCell*			joinedRoomCell;
	IBOutlet PNJoinedRoomEventCell*		joinedRoomEventCell_;
	
	PNRoom*					myRoom;	
	PNGameSession*			session;
	NSMutableArray*			joinedUsers;
	NSMutableDictionary*	speedLevels;;
	
	BOOL					isJoin;	
	BOOL					isReload;
	BOOL					roomMemberLoaded;
	int						transactionNumber;
	
	PNInternetRoomUserState		currentUserState;
	PNInternetRoomJoiningPhase	currentJoiningPhase;
	
	BOOL					hasSomeErrorForJoining;			// 入室できない理由があったかどうかを保存しておくフラグ(エラーメッセージの重複をさけるため)
	BOOL					backToRoomsViewAfterLeaving;	// 部屋を退室完了後にRoomsビューに戻るかどうかのフラグ
	BOOL					isWaitingForRematch;
	BOOL					appearDone;
	BOOL					forceLeaveFlag;
}

@property (assign) IBOutlet PNHeaderCell*				headerCell_;
@property (assign) IBOutlet PNJoinedRoomCell*			joinedRoomCell;
@property (assign) IBOutlet PNJoinedRoomEventCell*		joinedRoomEventCell_;
@property (retain)          NSMutableDictionary*		speedLevels;
@property (retain)			PNRoom*						myRoom;
@property (assign)			BOOL						isReload;
@property (assign)			BOOL						isJoin;
@property (assign)			BOOL						isWaitingForRematch;
@property (assign)			int							transactionNumber;
@property (assign)			PNInternetRoomJoiningPhase	currentJoiningPhase;
@property (assign)			PNInternetRoomUserState		currentUserState;
@property (retain)			NSMutableArray*				joinedUsers;

- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)resetRoomMembers;
- (BOOL)checkJoin;
- (void)join;
- (void)invite;
- (void)leave;
- (void)reloadStart;

- (void)onOKSelected;
- (void)onOKSelectedBackToRooms;
- (void)onCancelSelectedBackToRooms;

@end
