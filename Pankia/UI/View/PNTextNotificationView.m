//
//  PNTextNotificationView.m
//  PankakuNet
//
//  Created by 横江 宗太 on 10/04/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNTextNotificationView.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNNotificationService.h"
#import <QuartzCore/QuartzCore.h>
#import "UILabel+textWidth.h"

@implementation PNTextNotificationView
@synthesize titleLabel, descriptionLabel, iconImage, smallIconImage, pointLabel;

- (void)setNotificationInfo:(PNTextNotification *)info{
	if (notificationInfo != nil){
		[notificationInfo release];
		notificationInfo = nil;
	}
	
	notificationInfo = [info retain];
	self.titleLabel.text = notificationInfo.title;
	self.descriptionLabel.text = notificationInfo.description;
	self.iconImage.image = notificationInfo.iconImage;
	self.smallIconImage.image = notificationInfo.smallIconImage;
	self.pointLabel.text = notificationInfo.pointString;
	self.appearTime = notificationInfo.appearTime;
	
	//アイコンを表示しない場合に左右位置を調整します
	if (self.iconImage.image == nil){
		float xWithNoIcon = self.iconImage.frame.origin.x;
		float xWithIcon = self.titleLabel.frame.origin.x;
		float newWidth = self.titleLabel.frame.size.width + (xWithIcon - xWithNoIcon);
		self.titleLabel.frame = CGRectMake(xWithNoIcon, self.titleLabel.frame.origin.y, newWidth, self.titleLabel.frame.size.height);
		self.descriptionLabel.frame = CGRectMake(xWithNoIcon, self.descriptionLabel.frame.origin.y, newWidth, self.descriptionLabel.frame.size.height);
	}
	
	//スモールアイコン（右側のアイコン）を表示させる場合に左右位置を調整します
	if (self.smallIconImage.image != nil){
		const float MARGIN_BETWEEN_SMALL_ICON_AND_POINT_STRING = 4.0f;
		float pointStringWidth = [self.pointLabel textWidth];
		float rightEndOfPointLabel = self.pointLabel.frame.origin.x + self.pointLabel.frame.size.width;
		float leftEndOfPointLabelText = rightEndOfPointLabel - pointStringWidth;
		float leftEndOfSmallIcon = leftEndOfPointLabelText - self.smallIconImage.frame.size.width - MARGIN_BETWEEN_SMALL_ICON_AND_POINT_STRING;
		
		smallIconImage.frame = CGRectMake(leftEndOfSmallIcon, self.smallIconImage.frame.origin.y, 
										  self.smallIconImage.frame.size.width, self.smallIconImage.frame.size.height);
	}
}
- (PNTextNotification*)notificationInfo{
	return notificationInfo;
}

- (void) initOptions{
	self.notificationInfo = nil;
	touchedFlag = NO;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
	if (self = [super initWithCoder:aDecoder]){
		[self initOptions];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self initOptions];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{	
	if (touchedFlag == YES) return;	//既に一度タッチされていたら、なにもしません。
	touchedFlag = YES;	//一度タッチされたことを記憶します
	
	//リンク先URLが指定されていればSafariを起動してURLを表示します
	if (notificationInfo.urlToJump != nil && ![notificationInfo.urlToJump isEqualToString:@""]){
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:notificationInfo.urlToJump]];
		return;
	}
	
	//ターゲットとアクションが指定されていれば、そのアクションを実行します
	if (notificationInfo.target != nil && notificationInfo.action != nil){
		if ([notificationInfo.target respondsToSelector:notificationInfo.action]){
			[notificationInfo.target performSelector:notificationInfo.action];
			return;
		}
	}
}

- (void)dealloc {
	self.titleLabel = nil;
	self.descriptionLabel = nil;
	self.notificationInfo = nil;
	self.iconImage = nil;
    [super dealloc];
}


@end
