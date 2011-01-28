//
//  PNTextNotificationView.h
//  PankakuNet
//
//  Created by 横江 宗太 on 10/04/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNNotificationView.h"
#import "PNNotificationService.h"

@interface PNTextNotificationView : PNNotificationView {
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UIImageView *iconImage;
	IBOutlet UIImageView *smallIconImage;
	IBOutlet UILabel *pointLabel;
	
	PNTextNotification* notificationInfo;
	BOOL touchedFlag;
}
@property (retain) UILabel* titleLabel;
@property (retain) UILabel* descriptionLabel;
@property (retain) UIImageView* iconImage;
@property (retain) UIImageView* smallIconImage;
@property (retain) UILabel* pointLabel;
@property (retain) PNTextNotification* notificationInfo;
@end
