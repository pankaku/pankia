#import "PNNotificationService.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNControllerLoader.h"
#import "PNTextNotificationView.h"
#import "JsonHelper.h"
#import "PankiaNet+Package.h"
#import "PNGlobal.h"
#import "PNFormatUtil.h"

static PNNotificationService* _nInstance = nil;

@implementation PNTextNotification
@synthesize title, description, urlToJump, target, action, iconImage, smallIconImage, pointString, appearTime;

- (id) init{
	if (self = [super init]){
		self.title = nil;
		self.description = nil;
		self.urlToJump = nil;
		self.target = nil;
		self.action = nil;
		self.iconImage = nil;
		self.smallIconImage = nil;
		self.pointString = nil;
		self.appearTime = kPNNotificationViewDefaultAppearTime;
	}
	return self;
}
- (void) dealloc{
	self.title = nil;
	self.description = nil;
	self.urlToJump = nil;
	self.target = nil;
	self.action = nil;
	self.iconImage = nil;
	self.smallIconImage = nil;
	self.pointString = nil;
	self.appearTime = 0.0f;
	[super dealloc];
}
@end


@interface PNNotificationService(Private)
- (void)autostart;
- (void)showAchievementNoticeRightNow:(PNAchievement*)achievementData;
- (void)showTextNoticeRightNow:(PNTextNotification*)notification;
- (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
			 urlToJump:(NSString*)urlToJump target:(id)target action:(SEL)action;
- (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
		smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString
			 urlToJump:(NSString*)urlToJump target:(id)target action:(SEL)action;
- (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime
			 iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString
			 urlToJump:(NSString*)urlToJump target:(id)target action:(SEL)action;
@end

@implementation PNNotificationService

@synthesize delegateForAchievement;

- (id)init
{
	if(self = [super init]){
		queue = [[NSMutableArray alloc] init];
		showingNotifications = 0;
	}
	return self;	
}

+ (PNNotificationService*)sharedObject{
    @synchronized(self) {
        if (!_nInstance) {
            _nInstance = [[PNNotificationService alloc] init];
		}
    }
    return _nInstance;
}

/**!
 現在表示中のノーティフィケーションがなく、またデリゲート先でノーティフィケーション表示が許可されていれば
 キューに入っているノーティフィケーションを順番に表示させていきます。
 そうでない場合は、待機します。
 */
- (void)autostart{
	BOOL showNotification = YES;
	if ([[PankiaNet sharedObject].pankiaNetDelegate respondsToSelector:@selector(shouldShowNotification)]){
		showNotification = [[PankiaNet sharedObject].pankiaNetDelegate shouldShowNotification];
	}
	
	if ([queue count] == 1 && showNotification)
		[self flushNotices];
}

- (void)showAchievementNotice:(PNAchievement*)achievementData
{
	//Add queue
	[queue addObject:achievementData];
	
	PNCLog(PNLOG_CAT_UI, @"add notice queue - %d", [queue count]);
	
	[self autostart];
}

+ (void)showTextNotice:(NSString*)title description:(NSString*)description{
	[[self sharedObject] showTextNotice:title description:description iconImage:nil urlToJump:nil
				  target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description urlToJump:(NSString*)urlToJump{
	[[self sharedObject] showTextNotice:title description:description iconImage:nil urlToJump:urlToJump
				  target:nil action:nil];
}
+ (void)showTextNotice:(NSString *)title description:(NSString *)description target:(id)target action:(SEL)action{
	[[self sharedObject] showTextNotice:title description:description iconImage:nil urlToJump:nil
				  target:target action:action];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage{
	[[self sharedObject] showTextNotice:title description:description iconImage:iconImage urlToJump:nil
				  target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
			 urlToJump:(NSString*)urlToJump{
	[[self sharedObject] showTextNotice:title description:description iconImage:iconImage urlToJump:urlToJump
				  target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
				target:(id)target action:(SEL)action{
	[[self sharedObject] showTextNotice:title description:description iconImage:iconImage urlToJump:nil
				  target:target action:action];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
		smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString{
	[[self sharedObject] showTextNotice:title description:description iconImage:iconImage smallIconImage:smallIconImage 
			 pointString:pointString urlToJump:nil target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
		smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString urlToJump:(NSString*)urlToJump{
	[[self sharedObject] showTextNotice:title description:description iconImage:iconImage smallIconImage:smallIconImage 
			 pointString:pointString urlToJump:urlToJump target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
		smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString target:(id)target action:(SEL)action{
	[[self sharedObject] showTextNotice:title description:description iconImage:iconImage smallIconImage:smallIconImage 
			 pointString:pointString urlToJump:nil target:target action:action];
}

- (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
			 urlToJump:(NSString*)urlToJump target:(id)target action:(SEL)action{
	[self showTextNotice:title description:description iconImage:iconImage smallIconImage:nil 
			 pointString:nil urlToJump:urlToJump target:target action:action];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:nil smallIconImage:nil pointString:nil
							  urlToJump:nil target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
			 urlToJump:(NSString*)urlToJump{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:nil smallIconImage:nil pointString:nil
							  urlToJump:urlToJump target:nil action:nil];	
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
				target:(id)target action:(SEL)action{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:nil smallIconImage:nil pointString:nil
							  urlToJump:nil target:target action:action];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
			 iconImage:(UIImage*)iconImage{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:iconImage smallIconImage:nil pointString:nil
							  urlToJump:nil target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
			 iconImage:(UIImage*)iconImage urlToJump:(NSString*)urlToJump{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:iconImage smallIconImage:nil pointString:nil
							  urlToJump:urlToJump target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
			 iconImage:(UIImage*)iconImage target:(id)target action:(SEL)action{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:iconImage smallIconImage:nil pointString:nil
							  urlToJump:nil target:target action:action];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
			 iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage 
		   pointString:(NSString*)pointString{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:iconImage smallIconImage:smallIconImage pointString:nil
							  urlToJump:nil target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
			 iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage 
		   pointString:(NSString*)pointString urlToJump:(NSString*)urlToJump{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:iconImage smallIconImage:smallIconImage pointString:nil
							  urlToJump:urlToJump target:nil action:nil];
}
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime 
			 iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage 
		   pointString:(NSString*)pointString target:(id)target action:(SEL)action{
	[[self sharedObject] showTextNotice:title description:description appearTime:appearTime
							  iconImage:iconImage smallIconImage:smallIconImage pointString:nil
							  urlToJump:nil target:target action:action];
}

- (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage 
		smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString
			 urlToJump:(NSString*)urlToJump target:(id)target action:(SEL)action{
	[self showTextNotice:title description:description appearTime:kPNNotificationViewDefaultAppearTime
			   iconImage:iconImage smallIconImage:smallIconImage pointString:pointString
			   urlToJump:urlToJump target:target action:action];
}
- (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime
			 iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString
			 urlToJump:(NSString*)urlToJump target:(id)target action:(SEL)action{
	
	PNTextNotification *notification = [[[PNTextNotification alloc] init] autorelease];
	
	//title, descriptionがnilだった場合に空の文字列として扱います。
	if (title != nil){
		notification.title = title;
	}else{
		notification.title = @"";
	}
	if (description != nil){
		notification.description = description;
	}else{
		notification.description = @"";
	}
	
	notification.iconImage = iconImage;
	notification.smallIconImage = smallIconImage;
	notification.pointString = pointString;
	notification.urlToJump = urlToJump;
	notification.target = target;
	notification.action = action;
	notification.appearTime = appearTime;
	
	[queue addObject:notification];
	
	[self autostart];
}

- (void)showNextNotice{
	[queue removeObjectAtIndex:0];
	showingNotifications--;
	
	PNCLog(PNLOG_CAT_NOTIFICATION, @"showNextNotice queue(%d)", [queue count]);
	if ([queue count] > 0){
		id notificationToShow = [queue objectAtIndex:0];
		
		if ([notificationToShow isKindOfClass:[PNAchievement class]]){
			[self showAchievementNoticeRightNow:(PNAchievement*)notificationToShow];
		}
		if ([notificationToShow isKindOfClass:[PNTextNotification class]]){
			[self showTextNoticeRightNow:(PNTextNotification*)notificationToShow];
		}
	}
}
- (void)flushNotices{
	if ([queue count] > 0 && showingNotifications == 0){
		id notificationToShow = [queue objectAtIndex:0];
		
		if ([notificationToShow isKindOfClass:[PNAchievement class]]){
			[self showAchievementNoticeRightNow:(PNAchievement*)notificationToShow];
		}
		if ([notificationToShow isKindOfClass:[PNTextNotification class]]){
			[self showTextNoticeRightNow:(PNTextNotification*)notificationToShow];
		}
	}
}

- (void) showTextNoticeRightNow:(PNTextNotification*)notification{
	PNTextNotificationView *view = (PNTextNotificationView*)[PNControllerLoader loadUIViewFromNib:@"PNTextNotificationView" filesOwner:self];
	view.notificationInfo = notification;	
	showingNotifications++;
	[view performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}
- (void)showAchievementNoticeRightNow:(PNAchievement*)achievement{
	PNTextNotificationView *view = (PNTextNotificationView*)[PNControllerLoader loadUIViewFromNib:@"PNTextNotificationView" filesOwner:self];
	PNTextNotification* notification = [[[PNTextNotification alloc] init] autorelease];
	notification.title = achievement.title;
	notification.description = [PNFormatUtil trimSpaces:achievement.description];
	notification.pointString = [NSString stringWithFormat:@"%d",achievement.value];
	notification.iconImage = [UIImage imageNamed:@"PNUnlockedAchievementIcon.png"];
	notification.target = [PankiaNet class];
	notification.action = @selector(achievementNoticeTouched:);
	
	view.notificationInfo = notification;	
	showingNotifications++;
	[view performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

- (void)dealloc
{
	self.delegateForAchievement		= nil;
	PNSafeDelete(queue);
	[super dealloc];
	
}
@end
