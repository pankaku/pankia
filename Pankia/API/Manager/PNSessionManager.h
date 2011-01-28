#import "PNServiceNotifyDelegate.h"
#import "PNAsyncBehaviorDelegate.h"
#import "PNManagerDelegate.h"
#import "PNHTTPResponse.h"

extern NSString* const kPNSessionManagerChangeLastestSessionNotification;

@class PNManager;
@class PNUser;
@class PNNetworkError;

/**
 @brief Session作成のHTTP通信の補助をするクラスです。
 
 sessionの作成や、deviceの登録、pushnotificationのHTTP通信の補助をします。
 */
@interface PNSessionManager : NSObject<PNServiceNotifyDelegate> {
@public
	id<PNAsyncBehaviorDelegate> asyncBehaviorDelegate;
@private	
	id<PNManagerDelegate>		managerDelegate;	
	NSString*					latestSessionId;
}

@property (retain) id<PNManagerDelegate>	managerDelegate;
@property (retain) NSString*				latestSessionId;

+ (PNSessionManager*)sharedObject;

- (void)createSessionWithDelegate:(id)delegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector;
- (void)transferDeviceWithOnSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)verifyLastSessionWithCompleteHandler:(void (^)(BOOL isValid, PNError* error))completionHandler;
- (void)destroySession;
- (void)terminate;

@end

