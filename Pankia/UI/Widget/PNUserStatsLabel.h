//
//  PNUserStatsLabel.h
//  PankiaNet
//
//  Created by Sota on 10/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNUser.h"

@interface PNUserStatsLabel : UIView {
	PNUser* _user;
	IBOutlet    UIImageView*    achievementImage;
	IBOutlet	UILabel*		achievementLabel;
	IBOutlet    UIImageView*    gradePointImage;
	IBOutlet    UILabel*        gradeNameLabel;
	IBOutlet	UILabel*		gradePointLabel;
	IBOutlet	UIImageView*	coinImage;
	IBOutlet	UILabel*		coinLabel;
	UITextAlignment _alignment;
	int textIndentX;
}
@property (retain, setter = setUser) PNUser* user;
@property (assign, setter = setAlignment) UITextAlignment alignment;
@property (assign, readonly) int textIndentX;
-(void) updateStats;
-(void) updateLayout;
@end
