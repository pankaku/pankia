/*! \brief NotificationViewを表示するクラスです。
 *
 * AchievementのunLock時などにNotificationViewを表示します。
 * このクラスはシングルトンです。
 *
 */
#import "PankiaNetworkLibrary.h"

@protocol PankiaNetDelegate;

@interface PNTextNotification : NSObject {
	NSString *title;
	NSString *description;
	NSString *urlToJump;
	id target;
	SEL action;
	UIImage *iconImage;
	UIImage *smallIconImage;
	NSString *pointString;
	float appearTime;
}
@property (retain) NSString *title;
@property (retain) NSString *description;
@property (retain) NSString *urlToJump;
@property (retain) UIImage *iconImage;
@property (retain) UIImage *smallIconImage;
@property (retain) NSString *pointString;
@property (assign) id target;
@property (assign) SEL action;
@property (assign) float appearTime;
@end

@interface PNNotificationService : NSObject <PNManagerDelegate>{
	id<PankiaNetDelegate> delegateForAchievement;
	NSMutableArray *queue;
	int showingNotifications;
}

@property (retain) id<PankiaNetDelegate> delegateForAchievement;

- (id)init;
+ (PNNotificationService*)sharedObject;

- (void)showAchievementNotice:(PNAchievement*)achievementData;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description urlToJump:(NSString*)urlToJump;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description target:(id)target action:(SEL)action;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage urlToJump:(NSString*)urlToJump;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage target:(id)target action:(SEL)action;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString urlToJump:(NSString*)urlToJump;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString target:(id)target action:(SEL)action;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime urlToJump:(NSString*)urlToJump;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime target:(id)target action:(SEL)action;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime iconImage:(UIImage*)iconImage;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime iconImage:(UIImage*)iconImage urlToJump:(NSString*)urlToJump;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime iconImage:(UIImage*)iconImage target:(id)target action:(SEL)action;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString urlToJump:(NSString*)urlToJump;
+ (void)showTextNotice:(NSString*)title description:(NSString*)description appearTime:(float)appearTime iconImage:(UIImage*)iconImage smallIconImage:(UIImage*)smallIconImage pointString:(NSString*)pointString target:(id)target action:(SEL)action;

- (void)showNextNotice;
- (void)flushNotices;	//現在たまっているNotificationを表示させます(表示を止めた後再開させるときに使ってください)


@end
