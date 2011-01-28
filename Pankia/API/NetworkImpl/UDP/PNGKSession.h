#import <GameKit/GameKit.h>

@class PNUser;
@class PNPeer;
@class PNRoom;
@class PNLocalRoom;
@class PNError;
@class PNRoomManager;
@class PNLobby;

@protocol PNRoomDelegate;
@protocol PNRoomManagerDelegate;
@protocol PNGKSessionDelegate;

#define _PNGK_SESSION_PROTOCOL_REQUEST_JOIN			0x8013 // 相手の部屋に入る。
#define _PNGK_SESSION_PROTOCOL_RESPONSE_JOIN_OK		0x8014 // JOIN出来たことを返す。
#define _PNGK_SESSION_PROTOCOL_INQUIRY_SYNC			0x8016 // 開始して良いかサーバーから問い合わせる
#define _PNGK_SESSION_PROTOCOL_SYNC_OK				0x8017 // 開始しても良い状態
#define _PNGK_SESSION_PROTOCOL_SYNC_NG				0x8018 // 
#define _PNGK_SESSION_PROTOCOL_FAIL					0x8019 // 途中経過で何かのエラーが起こって失敗した場合、サーバーから送ってくる。
#define _PNGK_SESSION_PROTOCOL_START_MESSAGE		0x8020 // ゲーム開始
#define _PNGK_SESSION_PROTOCOL_ECHO					0x8021 // For RTT
#define _PNGK_SESSION_PROTOCOL_PING					0x8022 // 
#define _PNGK_SESSION_PROTOCOL_PONG					0x8023 // 
#define _PNGK_SESSION_PROTOCOL_DATA					0x8024 // 
#define _PNGK_SESSION_PROTOCOL_LEAVE				0x8025 // ルームから退出するメッセージを飛ばす。
#define _PNGK_SESSION_PROTOCOL_FIN					0x8026 // 接続を切る

#define _PNGK_SESSION_STATE_NONE	0xFF00
#define _PNGK_SESSION_STATE_READY	0xFF01
#define _PNGK_SESSION_STATE_STARTED	0xFF02
#define _PNGK_SESSION_STATE_ENDED	0xFF03


@interface PNGKPacket : NSObject
{
	int command;
	int length;
	unsigned char* srcData;
	unsigned char* dstData;
}

-(int)pack;
-(int)unpack:(NSData*)data;
-(void)setSourceData:(NSData*)data;
-(NSDictionary*)convertToJSON;

+(PNGKPacket*)create;

@property(assign) int command;
@property(assign) int length;
@property(assign) unsigned char* srcData;
@property(assign) unsigned char* dstData;

@end

/**
 * @brief ローカルのPeer間通信をするためのクラス
 * 
 * 内部ではGameKitAPIを使っており、
 * ローカル対戦のコネクション制御は全てここで行う。
 */
@interface PNGKSession : NSObject<GKSessionDelegate> {
	id<PNGKSessionDelegate>		delegate;
	id<PNRoomDelegate>			roomDelegate;
	id<PNRoomManagerDelegate>	roomManagerDelegate;
	BOOL						isHost;
	BOOL                        isConnectedResponse;
	NSMutableDictionary*		members;
	GKSession*					gksession;
	int							state;
	int							joinCounter;
	int							checkCounter;
	PNLocalRoom*				currentRoom;
	PNPeer*						hostPeer;
	NSMutableDictionary*		rooms;
	NSString*					gameKey;
	NSString*					version;
	NSTimer*					timeoutTimer;
}

+(PNGKSession*)create;
+(NSData*)packData:(NSData*)data;

-(void)start:(BOOL)isHost gameKey:(NSString*)aGameKey version:(NSString*)aVersion lobby:(PNLobby*)lobby;
-(void)selectRoom:(PNRoom*)room;
-(void)notifyStartingMessage;
-(void)stop;
-(void)send:(NSData*)data peer:(NSString*)peer mode:(int)mode;
-(void)sendAll:(NSData*)data mode:(int)mode;
-(void)leave;

@property(retain) id<PNGKSessionDelegate> delegate;
@property(retain) id<PNRoomDelegate> roomDelegate;
@property(retain) id<PNRoomManagerDelegate> roomManagerDelegate;
@property(assign) BOOL isHost;
@property(assign) BOOL isConnectedResponse;
@property(retain) NSMutableDictionary* members;
@property(retain) GKSession* gksession;
@property(retain) PNLocalRoom* currentRoom;
@property(retain) PNPeer* hostPeer;
@property(retain) NSMutableDictionary* rooms;

@end


@protocol PNGKSessionDelegate<NSObject>
@optional
-(void)session:(PNGKSession*)aSession didReceiveWithData:(NSData*)aData from:(PNPeer*)aOpponent;
-(void)session:(PNGKSession*)aSession didFailWithError:(PNError*)aError;
-(void)session:(PNGKSession*)aSession didSendError:(PNError*)aError opponentPeerID:(NSString*)aPeerId data:(NSData*)aData;
@end


// Private defined.
#define _PNGK_SESSION_SELF_PEER_NUMBER 0x7FFFFFFF
