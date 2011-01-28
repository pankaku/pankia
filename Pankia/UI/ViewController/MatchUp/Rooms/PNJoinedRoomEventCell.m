//
//  PNJoinedRoomEventCell.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNJoinedRoomEventCell.h"
#import "PNDashboard.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"


@interface PNJoinedRoomEventCell(Private)
- (void)setStateNotReady;
- (void)setStateNotJoined;
- (void)setStateJoining;
- (void)setStateJoined;
@end


@implementation PNJoinedRoomEventCell

@synthesize delegate;
@synthesize joinState;
@synthesize joinButton_;


- (void)setJoinState:(JoinState)newState {
	joinState = newState;
	switch (newState) {
		case NOT_READY:
			[self setStateNotReady];
			break;
		case NOT_JOINED:
			[self setStateNotJoined];
			break;
		case JOINING:
			[self setStateJoining];
			break;
		case JOINED:
			[self setStateJoined];
			break;
		default:
			break;
	}
}

- (void)setStateNotReady {
	[joinMatchUpBtn setEnabled:NO];
}

- (void)setStateNotJoined {
	[joinMatchUpBtn setEnabled:YES];
	[joinMatchUpBtn defaultButtonColorBlue];
	[joinMatchUpBtn setTitle:@"PNTEXT:BUTTON:Join" forState:UIControlStateNormal];
	[joinMatchUpBtn refreshText];
}

- (void)setStateJoining {
	[joinMatchUpBtn setEnabled:YES];
	[joinMatchUpBtn defaultButtonColorRed];
	[joinMatchUpBtn setTitle:@"PNTEXT:BUTTON:Joining" forState:UIControlStateNormal];
	[joinMatchUpBtn refreshText];
}

- (void)setStateJoined {
	[joinMatchUpBtn setEnabled:YES];
	[joinMatchUpBtn defaultButtonColorRed];
	[joinMatchUpBtn setTitle:@"PNTEXT:BUTTON:Leave" forState:UIControlStateNormal];
	[joinMatchUpBtn refreshText];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.joinState = NOT_READY;
}


- (IBAction)joinMatchUpButtonDidPush {
	
	switch (joinState) {
		case JOINED:
			// 退室します。
			if (delegate != nil && [self.delegate respondsToSelector:@selector(leave)]) {
				[delegate performSelector:@selector(leave) withObject:nil];
			}	
			break;
		case NOT_JOINED:
			if (delegate != nil && [delegate respondsToSelector:@selector(checkJoin)]) {
				if (![delegate performSelector:@selector(checkJoin) withObject:nil]) {
					[[PNDashboard sharedObject] showAlertWithTitle:getTextFromTable(@"PNTEXT:UI:Internet_Match")
														   message:getTextFromTable(@"PNTEXT:INTERNET_MATCH:over_room_num")
													 okButtonTitle:getTextFromTable(@"PNTEXT:OK")
													  onOKSelected:@selector(onOKSelected) 
												 cancelButtonTitle:nil
												  onCancelSelected:nil
														  delegate:self];
					return;
				}
			}
			// ジョイン処理を開始します。
			joinState = JOINING;
			if(delegate != nil && [delegate respondsToSelector:@selector(join)]){
				[delegate performSelector:@selector(join) withObject:nil];
			}	
			break;
		case JOINING:
			// ジョイン処理中はなにもしません。
			break;
		default:
			break;
	}
}

- (void)onOKSelected {
	
}

- (void)dealloc {
	self.joinButton_	= nil;
	self.delegate		= nil;
    [super dealloc];
}
@end
