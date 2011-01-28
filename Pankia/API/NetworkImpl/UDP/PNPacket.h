
/**
 * @brief Peer間通信の時に用いるパケット構造体
 * 
 * 送信するときのプロトコルスタックは以下の通り、
 * IP｜UDP｜独自プロトコル
 * 独自プロトコルのヘッダは、
 * 32BIT : シーケンス番号
 * 32BIT : パケットフラグ
 * 32BIT : データ長
 * それ以降 : データ
 * データ
 */
@interface PNPacket : NSObject
{
	int				sequence;
	
	NSString*		address;
	int				port;
	
	int				theFlag;
	NSData*			data;
	NSData*			packedData;
	
	int				ackFlag;
	double			timestamp;
	int				resendCount;
}

+(NSData*)blockPack:(NSArray*)packets;
+(NSArray*)blockUnpack:(NSData*)data;

+(PNPacket*)create;
+(PNPacket*)createWithPackedData:(NSData*)data;

-(void)pack;
-(void)unpack;

@property(assign) int			sequence;

@property(retain) NSString*		address;
@property(assign) int			port;

@property(assign) int			theFlag;
@property(retain) NSData*		data;
@property(retain) NSData*		packedData;

@property(assign) int			ackFlag;
@property(assign) double		timestamp;
@property(assign) int			resendCount;

@end


// Private defined.
#define kPNPacketFlagConnectionReliable			kPNGameSessionReliable
#define kPNPacketFlagConnectionUnreliable		kPNGameSessionUnreliable
#define kPNPacketFlagConnectionRaw				kPNGameSessionRaw


#define kPNPacketFlagCommandSystem		0x010000
#define kPNPacketFlagCommandUser		0x020000
#define kPNPacketFlagMethodUser			0x000100
#define kPNPacketFlagMethodSync			0x000200
#define kPNPacketFlagMethodRematch		0x000300
#define kPNPacketFlagMethodPing			0x000400
#define kPNPacketFlagMethodPong			0x000500
#define kPNPacketFlagMethodPairing		0x000600
#define kPNPacketFlagMethodFin			0x000700


#define kPNPacketFlagData		0x0001
#define kPNPacketFlagAck		0x0002
#define kPNPacketFlagSync		0x0003
#define kPNPacketFlagFin		0x0004
#define kPNPacketFlagHeatbeat	0x0005


#define kPNSetPacketConnectionFlag(a,b)		(a)=(((a)&0x00FFFFFF)|(0xFF000000&(b)))
#define kPNSetPacketCommandFlag(a,b)		(a)=(((a)&0xFF00FFFF)|(0x00FF0000&(b)))
#define kPNSetPacketMethodFlag(a,b)			(a)=(((a)&0xFFFF00FF)|(0x0000FF00&(b)))
#define kPNSetPacketTypeFlag(a,b)			(a)=(((a)&0xFFFFFF00)|(0x000000FF&(b)))

#define kPNIsPacketConnection(a,b)			(((a)&0xFF000000)==(b))
#define kPNIsPacketCommand(a,b)				(((a)&0x00FF0000)==(b))
#define kPNIsPacketMethod(a,b)				(((a)&0x0000FF00)==(b))
#define kPNIsPacketType(a,b)				(((a)&0x000000FF)==(b))

#define kPNGetpacketConnection(a)		(((a)&0xFF000000))
#define kPNGetPacketCommand(a)			(((a)&0x00FF0000))
#define kPNGetPacketMethod(a)			(((a)&0x0000FF00))
#define kPNGetPacketType(a)				(((a)&0x000000FF))


