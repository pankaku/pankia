//
//  PNDashboardHeaderView.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNDashboardHeaderView.h"
#import "PNControllerLoader.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNDashboard.h"
#import "PankiaNet+Package.h"
#import "PNGlobal.h"

// GradeGaugeのグラデーション指定カラーコード（先頭の#は不要です）。
#define	kPNDashboardHeaderTopColor		@"000000"
#define kPNDashboardHeaderBottomColor	@"292929"
#define DEFAULT_USER_NAME				@"Player"


@implementation PNDashboardHeaderView

@synthesize nameLabel_;
@synthesize homeButton_;
@synthesize dismissButton_;
@synthesize delegate;


- (void)awakeFromNib {
	[super awakeFromNib];
	dashboardHeaderButtons_ = [[NSArray arrayWithObjects:homeButton_, dismissButton_, nil] retain];
	
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		self.frame = CGRectMake(0.0f, 24.0f, 480.0f, 136.0f);
	}
	else {
		
	}
}

// グラデーションを描画します。
- (void)drawRect:(CGRect)rect {
	
	CGFloat red1	= [self hexToUIColorRed:kPNDashboardHeaderTopColor];
	CGFloat green1	= [self hexToUIColorGreen:kPNDashboardHeaderTopColor];
	CGFloat blue1	= [self hexToUIColorBlue:kPNDashboardHeaderTopColor];
	
	CGFloat red2	= [self hexToUIColorRed:kPNDashboardHeaderBottomColor];
	CGFloat green2	= [self hexToUIColorGreen:kPNDashboardHeaderBottomColor];
	CGFloat blue2	= [self hexToUIColorBlue:kPNDashboardHeaderBottomColor];
	
	[self setContext:UIGraphicsGetCurrentContext()];
	[self setColorRed1:red1 green1:green1 blue1:blue1 alpha1:1.00f
				  red2:red2 green2:green2 blue2:blue2 alpha2:1.00f];
	[self gradientRectX:0.0f y:0.0f width:480.0f height:24.0f];
}


// ラベルのアップデートを行います。
- (void)updateStats {

	if ([PNUser currentUser].username == nil || [[PNUser currentUser].username isEqualToString:@""]) {
		// handleがない場合はPLAYERにします。
		[PNUser currentUser].username = DEFAULT_USER_NAME;
	}
	[self setName:[PNUser currentUser].username];	
	[currentUserStats_ updateStats];
}

- (void)setName:(NSString*)name {

	self.nameLabel_.text = name;
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		self.nameLabel_.frame = CGRectMake(self.nameLabel_.frame.origin.x,
									 	   self.nameLabel_.frame.origin.y,
										   self.nameLabel_.frame.size.width,
										   self.nameLabel_.frame.size.height);
	}
	else {
		self.nameLabel_.frame = CGRectMake(self.nameLabel_.frame.origin.x,
										   self.nameLabel_.frame.origin.y,
										   320.0f - self.nameLabel_.frame.origin.x, 
										   self.nameLabel_.frame.size.height);
	}
}

- (void)disableAllButtons {
	for (UIButton* buttons in dashboardHeaderButtons_) {
		[buttons setEnabled:NO];
	}
}

- (void)resetAllButtons {
	for (UIButton* buttons in dashboardHeaderButtons_) {
		[buttons setEnabled:YES];
	}
}

- (void)dealloc {
	[homeButton_ release];
	[dismissButton_ release];
	currentUserStats_ = nil;
	
	PNSafeDelete(dashboardHeaderButtons_);
	
	[super dealloc];
}

#pragma mark button action
- (IBAction)onHomeButtonTouched {
	PNLog(@"Go Home!");
	if ([self.delegate respondsToSelector:@selector(popToRootViewController:)]) {
		[self.delegate popToRootViewController:YES];
	}
	self.delegate = nil;
}

- (IBAction)onDismissButtonTouched {
	PNLog(@"dismiss dashboard !!");
	[PankiaNet dismissDashboard];
}

@end
