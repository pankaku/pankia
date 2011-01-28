//
//  PNAppMainViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"
#import "PNMainMenuButton.h"
#import "PNProfileAreaView.h"

@interface PNAppMainViewController : PNViewController <PNProfileAreaViewDelegate> {
	
	PNMainMenuButton*	networkMatchBtn;
	PNMainMenuButton*	leaderboardsBtn;
	PNMainMenuButton*	achievementsBtn;	
	PNMainMenuButton*	itemsBtn;
	PNMainMenuButton*	storeBtn;
	PNProfileAreaView*	profileAreaView;
	
	NSArray* menuButtons;
	NSArray* menuButtonNames;
	NSArray* offlineEnableButtons;
	
	CGRect buttonFrames[5];
}

@property (retain) IBOutlet PNMainMenuButton* networkMatchBtn;
@property (retain) IBOutlet PNMainMenuButton* leaderboardsBtn;
@property (retain) IBOutlet PNMainMenuButton* achievementsBtn;
@property (retain) IBOutlet PNMainMenuButton* itemsBtn;
@property (retain) IBOutlet PNMainMenuButton* storeBtn;
@property (retain) NSArray* menuButtons;
@property (retain) NSArray* menuButtonNames;
@property (retain) NSArray* offlineEnableButtons;

- (IBAction)onNetworkMatchBtnPressed;
- (IBAction)onLeaderboardsBtnPressed;
- (IBAction)onAchievementsBtnPressed;
- (IBAction)onItemsBtnPressed;
- (IBAction)onStoreBtnPressed;

- (void)relocateMenuButtons;
- (void)updateProfileArea;

@end
