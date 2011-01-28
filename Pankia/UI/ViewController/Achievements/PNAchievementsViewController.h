//
//  PNAchievementsViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 12/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"

@interface PNAchievementsViewController : PNTableViewController {	
	NSArray *availableAchievements;
}
@property (retain) NSArray *availableAchievements;
@end
