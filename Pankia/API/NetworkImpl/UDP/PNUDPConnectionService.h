#import "AsyncUdpSocket.h"
#import "PNNetworkError.h"
#import "NSObject+PostEvent.h"
#import "PNPacketFireWall.h"

#define kPNTTLDummyPacket					1		// Portを決めるためのダミーパケット用TTL
#define kPNTTLSpiblock						3
// TTLはLightBike1同様３パスまで有効に。（マンション等の多段NATを考慮）
#define kPNStunDefaultPacketTTL						64		// Unix default value.
#define kPNStunUDPConnectionTagDummyPacket			0x01	// ダミーパケット用タグ
#define kPNStunUDPConnectionTagPacket				0x02	// 通常のパケット用タグ
#define kPNUDPReceiveTimeout						15.0f	// レシーブイベントのタイムアウト

#define kPNPunchingStart							0x0001	// スタートした
#define kPNPunchingSendPacket						0x0002	// パケットを送信
#define kPNPunchingEnd								0x0003	// 終了
#define kPNPunchingPacketCount						12		// 12回送り合う


#define kPNKeepNATTablePacketDelayTime				30.0	// １０秒に一回NOOPパケットを打つ
#define kPNPunchingRTTDelayTime						0.25	// RTT計測用のディレイ
#define kPNPunchingReportDelayTime					1.5		// レポートするまでのディレイ
#define kPNPunchingTTLDelayTime						2.5		// 短いTTLパケットを打ってからのディレイ




@class PNPeer;
@class PNRoom;
@protocol PNUDPConnectionServiceDelegate;


/**
 * @brief NATチェックとUDPHolePunchingを行うクラス
 * 
 * 自分もしくは相手側からのUDPHolePunching要求を受けるためのバックグランドサービス。
 * このクラスの動作は全て別スレッド(ConnectionThread)で処理を行い、
 * アプリケーションが終了するまではこのコネクションとスレッドは維持されます。
 * スレッドは、ラウンドロビン方式からFIFO方式に変更し、プライオリティを最大値とする。
 * このインスタンスはシングルトンで維持されます。
 */
@interface PNUDPConnectionService : NSObject {
	id<PNUDPConnectionServiceDelegate> delegate;

	PNRoom* currentRoom; 
	AsyncUdpSocket* udpSocket;
	NSString* natHost;
	NSInteger natPort;
	PNPeer* selfPeer;
	int connectionPermissibleRangeSpeed;

	
	double timestampForPortMapping;
	
	NSString* opponentHost;
	NSInteger opponentPort;
	BOOL isAlive;
	BOOL isChecked;
	int checkCount;
	
	NSString* bindAddress;
	int bindPort;

	// PNPeer (Key = [address port])
	NSMutableDictionary* opponents;
	
	// Paring mapper (For symmetric logic)
	NSMutableDictionary* paringTableForSymmetric;
	
	int natType;
}

+(void) startPairingWithDelegate:(id<PNUDPConnectionServiceDelegate>)delegate
							room:(PNRoom*)room
					  ownSession:(NSString*)session
				 opponentSession:(NSString*)opponentSession;

+(void) checkNATWithDelegate:(id<PNUDPConnectionServiceDelegate>)delegate session:(NSString*)session;

+(PNUDPConnectionService*)sharedObject;
+(void)deletePairingTable:(NSArray*)aPeers;
+(void)rebind;
+(void)clear;

+(void)suspend;
+(void)resume;

@property(retain) id<PNUDPConnectionServiceDelegate> delegate;
@property(retain) AsyncUdpSocket* udpSocket;
@property(retain) NSString* natHost;
@property(assign) NSInteger natPort;
@property(retain) PNPeer* selfPeer;
@property(retain) NSString* opponentHost;
@property(assign) NSInteger opponentPort;
@property(assign) int natType;
@property(assign) BOOL isAlive;
@property(assign) BOOL isChecked;
@property(assign) int checkCount;
@property(retain) NSMutableDictionary* opponents;
@property(retain) PNRoom* currentRoom;
@property(retain) NSMutableDictionary* paringTableForSymmetric;

@property(retain) NSString *bindAddress;
@property(assign) int bindPort;
@property(assign) int connectionPermissibleRangeSpeed;

@end

@protocol PNUDPConnectionServiceDelegate<NSObject>

-(void)didStartWithService:(PNUDPConnectionService*)service;
-(void)stunService:(PNUDPConnectionService*)service didDetecteNat:(NSNumber*)natType;
-(void)stunService:(PNUDPConnectionService*)service didError:(PNNetworkError*)error;
-(void)stunService:(PNUDPConnectionService*)service didReport:(NSString*)report;
-(void)stunService:(PNUDPConnectionService*)service willStartPairing:(PNPeer*)peer;
-(void)stunService:(PNUDPConnectionService*)service didDonePairing:(PNPeer*)peer;

@end
