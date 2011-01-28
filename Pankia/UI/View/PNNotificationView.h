//
//  PNNotificationView.h
//  PankakuNet
//
//  Created by 横江 宗太 on 10/04/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**!
 このクラスはTextNotificationViewやAchievementNotificationViewの根底となるクラスです
 */
@interface PNNotificationView : UIView {
	float appearTime;
	UIWindow *notificationWindow;
}
@property (assign) float appearTime;
- (void)show;
@end
