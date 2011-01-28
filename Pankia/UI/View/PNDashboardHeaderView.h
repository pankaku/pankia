//
//  PNDashboardHeaderView.h
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNImageView.h"
#import "PNGradientView.h"
#import "PNUserStatsLabel.h"
#import "PNRootViewController.h"


@protocol PNDashboardHeaderDelegate;

@interface PNDashboardHeaderView : PNGradientView {
	IBOutlet UILabel*	nameLabel_;
	IBOutlet UIButton*	homeButton_;
	IBOutlet UIButton*	dismissButton_;
	
	PNUserStatsLabel*	currentUserStats_;
	NSArray*			dashboardHeaderButtons_;		

	id <PNDashboardHeaderDelegate> delegate;
}

@property(retain) IBOutlet UILabel*		nameLabel_;
@property(retain) IBOutlet UIButton*	homeButton_;
@property(retain) IBOutlet UIButton*	dismissButton_;
@property(assign, nonatomic)id <PNDashboardHeaderDelegate> delegate;

- (void)setName:(NSString*)name;
- (void)updateStats;
- (void)disableAllButtons;
- (void)resetAllButtons;
- (IBAction)onHomeButtonTouched;
- (IBAction)onDismissButtonTouched;

@end

@protocol PNDashboardHeaderDelegate <NSObject>
- (void)popToRootViewController:(BOOL)animated;
@end

