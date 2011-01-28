#import "PNPeer.h"
#define kPNGameSessionDefaultRTO				0.200 // 200ms

@class PNMembershipModel;
@class PNPeer;
@class PNUser;

@interface PNPeer(Package)

@property(retain)	PNUser*			user;
@property(retain)	NSString*		address;
@property(assign)	float			rto;
@property(assign)	BOOL			isHost;
@property(assign,readonly,getter=speedLevel)	PNConnectionLevel speedLevel;

@property(assign)	int				udpPort;
@property(assign)	float			rtt;
@property(assign)	float			srtt;
@property(assign)	float			rttvar;
@property(assign)	float			icmpRtt;
@property(assign)	double			packetTimeStamp;
@property(retain)	NSMutableDictionary*	received_packets_for_rtt;
@property(retain)	NSMutableArray*			saved_rtts;
@property(retain)	NSMutableDictionary*	saved_NTPTimeStamps;
@property(assign)	int				subDeviceTime;
@property(assign)	int				joinedNumber;
@property(retain)	NSMutableArray* sendQueue;
@property(retain)	NSMutableArray* readQueue;
@property(retain)	NSMutableArray* sentPackets;
@property(retain)	NSMutableArray* readPackets;
@property(assign)	int				sendSequenceCounter;
@property(assign)	int				readSequenceCounter;
@property(retain)	NSMutableDictionary* syncPackets;
@property(assign)	BOOL			isConnecting;
@property(assign)	BOOL			rematchFlag;
@property(assign)	BOOL			receivedRematchMessage;
@property(assign)	int				pairingNumber;


+(PNPeer*)createPeer;	/**< @brief ピアオブジェクトを作成 */
+(PNPeer*)createPeerWithUser:(PNUser*)user;	/**< @brief ユーザーを指定してピアオブジェクトを作成 */
-(void)setMembershipModel:(PNMembershipModel*)aModel;	/**< @brief メンバーシップモデルを設定 */

@end
