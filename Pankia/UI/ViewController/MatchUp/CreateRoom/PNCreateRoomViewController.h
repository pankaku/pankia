//
//  PNCreateRoomViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"

#import "PNRightSegmentButton.h"
#import "PNCenterSegmentButton.h"
#import "PNLeftSegmentButton.h"
#import "PNLobby.h"

@interface PNCreateRoomViewController : PNViewController {
	UITextField*			roomNameField;
	UIButton*				createRoomBtn;
	PNRightSegmentButton*   playerSegBtnRight;
	PNCenterSegmentButton*  playerSegBtnCenter;
	PNLeftSegmentButton*    playerSegBtnLeft;
	PNRightSegmentButton*   gradeFilterSegBtnRight;
	PNCenterSegmentButton*  gradeFilterSegBtnCenter;
	PNLeftSegmentButton*    gradeFilterSegBtnLeft;
	PNRightSegmentButton*   publishSegBtnRight;
	PNLeftSegmentButton*    publishSegBtnLeft;
	
	UILabel*				numberOfPlayersLabel;
	UILabel*				gradeFilterLabel;
	UILabel*				publicOrPrivateLabel;
	int						playerNum;
	BOOL					isPublish;
	NSString*				gradeFilter;
	
	PNLobby *lobby;
}
@property (retain) PNLobby *lobby;
@property (retain) IBOutlet	UITextField*	roomNameField;
@property (retain) IBOutlet	PNRightSegmentButton*   playerSegBtnRight;
@property (retain) IBOutlet	PNCenterSegmentButton*  playerSegBtnCenter;
@property (retain) IBOutlet	PNLeftSegmentButton*    playerSegBtnLeft;
@property (retain) IBOutlet	PNRightSegmentButton*   publishSegBtnRight;
@property (retain) IBOutlet	PNLeftSegmentButton*    publishSegBtnLeft;
@property (retain) IBOutlet	PNRightSegmentButton*   gradeFilterSegBtnRight;
@property (retain) IBOutlet	PNCenterSegmentButton*  gradeFilterSegBtnCenter;
@property (retain) IBOutlet	PNLeftSegmentButton*    gradeFilterSegBtnLeft;
@property (retain) IBOutlet UILabel					*numberOfPlayersLabel, *gradeFilterLabel, *publicOrPrivateLabel;


- (IBAction)endEditing:(id)sender;
- (IBAction)pressedPlayerSegBtn:(id)sender;
- (IBAction)pressedGradeFilterSegBtn:(id)sender;
- (IBAction)pressedPublishSegBtn:(id)sender;

- (void)onOKSelected;

@end
