#import "NSObject+PostEvent.h"

@protocol PNAsyncBehaviorDelegate<NSObject>

// PushNotification経由でメッセージが来たときの動作を定義する
-(void)didPushNotificationBehavior:(id)aSender name:(NSString*)aBehaviorName params:(NSDictionary*)aParams;
@end
