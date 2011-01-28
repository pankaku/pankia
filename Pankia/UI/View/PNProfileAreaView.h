//
//  PNProfileAreaView.h
//  PankakuNet
//
//  Created by  Ken Saito on 10/12/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNImageView.h"
#import "PNUserStatsLabel.h"

@protocol PNProfileAreaViewDelegate

- (void)profileAreaTapped;

@end

@interface PNProfileAreaView : UIView {
	id <PNProfileAreaViewDelegate> delegate;
	IBOutlet	UILabel*		nameLabel;
	IBOutlet	PNImageView*	selfIcon;
	IBOutlet    UIImageView*    flagIcon;
	
	PNUserStatsLabel*			currentUserStats;
}

@property (assign) id delegate;
@property (retain) IBOutlet	UILabel*		nameLabel;
@property (retain) IBOutlet	PNImageView*	selfIcon;
@property (retain) IBOutlet UIImageView*    flagIcon;

- (void)loadImageWithUrl:(NSString *)url;
- (void)setName:(NSString*)name;
- (void)updateStats;
- (void)setFlagIconImage:(NSString*)countryCode;
@end
