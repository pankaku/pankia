//
//  PNProfileContentView.h
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PNLocalizableLabel;

@interface PNProfileContentView : UIView {
	UIImageView *userIcon;
	UIImageView *countryIcon;
	PNLocalizableLabel *userNameLabel;
	PNLocalizableLabel *achivementPointLabel;
	PNLocalizableLabel *gradePointLabel;
	PNLocalizableLabel *coinLabel;	
}

@end
