//
//  PNProfileAreaView.m
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNProfileAreaView.h"
#import "PNControllerLoader.h"
#import "PNNavigationController.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNCountryCodeUtil.h"
#import "PNDashboard.h"

@implementation PNProfileAreaView

@synthesize delegate;
@synthesize nameLabel;
@synthesize selfIcon;
@synthesize flagIcon;

#define DEFAULT_USER_NAME @"Player"

- (void)awakeFromNib {
	currentUserStats =
		(PNUserStatsLabel*)[PNControllerLoader loadUIViewFromNib:@"PNUserStatsLabel"
													  filesOwner:self];	
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		self.frame = CGRectMake(0.0f, 320.0f - 50.0f, 480.0f, 50.0f);
		[currentUserStats setFrame:
			CGRectMake(65.0f, 20.0f, self.frame.size.width - 10.0f, 35.0f)];
	}
	else {
		self.frame = CGRectMake(0.0f, 480.0f - 50.0f, 320.0f, 50.0f);
		[currentUserStats setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 35.0f)];
	}
	currentUserStats.alignment = UITextAlignmentLeft;
	currentUserStats.user = [PNUser currentUser];
	[self addSubview:currentUserStats];
	
	// Set tap gesture recognizer
	UITapGestureRecognizer *singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self
											action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
}

- (void)hiddenFlagIconImage:(BOOL)boo {
	[self.flagIcon setHidden:boo];
}

// ラベルのアップデートを行います。
- (void)updateStats {
	PNLog(@"------------- currentUser:%@ --------------",[PNUser currentUser].username);
	if ([PNUser currentUser].username == nil || [[PNUser currentUser].username isEqualToString:@""]) {
		// handleがない場合はPLAYERにします。
		[PNUser currentUser].username = DEFAULT_USER_NAME;
	}
	[self setName:[PNUser currentUser].username];
	[selfIcon loadImageOfUser:[PNUser currentUser]];
	
	if ([[PNManager sharedObject] loggedinOnce]) {
		[self hiddenFlagIconImage:NO];
		[self setFlagIconImage:[PNUser currentUser].countryCode];
	}
	else {
		[self hiddenFlagIconImage:YES];
	}	
	[currentUserStats updateStats];
}

- (void)setName:(NSString*)name {
	self.nameLabel.text = name;
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x,
										  self.nameLabel.frame.origin.y,
										  currentUserStats.frame.origin.x + currentUserStats.textIndentX, // - self.nameLabel.frame.origin.x,
										  self.nameLabel.frame.size.height);
	}
	else {
		self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x,
										  self.nameLabel.frame.origin.y,
										  320.0f - self.nameLabel.frame.origin.x, 
										  self.nameLabel.frame.size.height);
	}
}

- (void)loadImageWithUrl:(NSString *)url {
	if (url) {
		[selfIcon loadImageWithUrl:url];
	}	
}

- (void)setFlagIconImage:(NSString*)countryCode {	
	self.flagIcon.image	= [PNCountryCodeUtil getFlagImageForAlpha2Code:countryCode];
}

- (void)dealloc {
	[nameLabel release];
	[selfIcon release];
	[flagIcon release];
	[super dealloc];
}

#pragma mark -

- (void)handleSingleTap:(id)sender {
	[delegate profileAreaTapped];
}

@end
