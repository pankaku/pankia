#import "AsyncSocket.h"

@protocol PNTCPConnectionServiceDelegate;
@protocol PNServiceNotifyDelegate;
@class PNError;


/**
 * @brief サーバーからTCP経由でプッシュされたイベントを受け取るためのクラスです。
 * 
 * Subscribeされたトピックに何か変動があれば、TCP経由でイベントがプッシュされます。
 * 例：部屋に入室した、退出した。ユーザーデータの変更等々。
 * TCPバックチャンネルはメインスレッドで稼働し、高速なパケットのやり取りで使用することはできません。
 * また３０秒に１回セッションのハートビートを送信し、セッションを維持しようと試みます。
 */
@interface PNTCPConnectionService : NSObject
{
	AsyncSocket *socket;
	// Observer
	NSMutableDictionary *delegates;
	int pingState;
	
	double heartbeatLastTimeStamp;
	int transactionID;
	BOOL isAlive;
	
}

+ (BOOL) startWithSession:(NSString*)session;
+ (void) setObserver:(id)delegate key:(NSString*)key;
+ (void) removeObserver:(NSString*)key;
+ (void) removeAllObserver;
+ (PNTCPConnectionService*) sharedObject;

- (void) stop;
- (void)ping:(NSNumber*)aTransactionID;

@property(retain) AsyncSocket *socket;
@property(retain) NSMutableDictionary *delegates;
@property(assign) int pingState;
@property(assign) int transactionID;
@property(assign) BOOL isAlive;
@end


@protocol PNTCPConnectionServiceDelegate<PNServiceNotifyDelegate>

-(void)didConnectWithService:(PNTCPConnectionService*)service;
-(void)didDisconnectWithService:(PNTCPConnectionService*)service;
-(void)service:(PNTCPConnectionService*)service didFailWithError:(PNError*)error;

@end
