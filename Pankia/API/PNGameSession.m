#import "PNGameSession.h"
#import "PNGameSession+Package.h"

#import "NSObject+PostEvent.h"
#import "NSThread+ControllerExt.h"

#import "AsyncUdpSocket.h"
#import "IPAddress.h"
#import "JsonHelper.h"

#import "PNNetworkUtil.h"
#import "PNNetworkError.h"
#import "PNPacket.h"

#import "PNUDPConnectionService.h"
#import "PNThreadManager.h"
#import "PNGameSet.h"
#import "PNGKSession.h"

#import "PNRoom.h"
#import "PNRoom+Package.h"

#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"

#import "PNLobby.h"

#import "PNMatchRequestHelper.h"
#import "PNRoomRequestHelper.h"

#import "PNGlobal.h"
#import "PNLogger+Package.h"

#import "PNManager.h"
#import "PNRoomManager.h"
#import "PNMatchManager.h"

extern NSNumber* inetToLongLong(const char* host,int port);
extern AsyncUdpSocket* udpSocketForInternet;

@interface PNGameSession(NTP)
- (void)synchronousProcessing;
- (void)sync:(NSData*)data opponent:(PNPeer*)peer counter:(int)cnt;
- (void)recvData:(NSData*)data from:(PNPeer*)peer;
@end

@interface PNGameSession(UDPLayer)
- (void)resendDataPacket:(NSArray*)params;
- (void)sendDataPacket:(PNPacket*)packet peer:(PNPeer*)peer;
- (void)onUdpSocket:(AsyncUdpSocket*)sock
didNotReceiveDataWithTag:(long)tag
		 dueToError:(NSError*)error;
- (void)send:(NSData*)data
		host:(NSString*)host
		port:(int)port;
-(void)sendPackedPackets;
-(void)pushSendQueue:(PNPacket*)packet peer:(PNPeer*)peer;
-(void)resendDataPacket:(NSArray*)params;
-(void)sendDataPacket:(PNPacket*)packet peer:(PNPeer*)peer;
-(void)setup:(AsyncUdpSocket*)udp
	 address:(NSString*)address
		port:(int)port;
-(void)sendPacketFilter:(NSArray*)aParams;
-(void)send:(NSArray*)aParams;
@end

@interface PNGameSession(GameSessionIO)
-(BOOL)sendData:(NSData *)data
		toPeers:(NSArray *)ps
	 connection:(int)aConnection
		   type:(int)aType
		command:(int)aCommand
		 method:(int)aMethod;
@end

@implementation PNGameSession(GameSessionIO)

-(BOOL)sendData:(NSData *)data
		toPeers:(NSArray *)ps
	 connection:(int)aConnection
		   type:(int)aType
		command:(int)aCommand
		 method:(int)aMethod
{
	NSArray* params = [NSArray 
					   arrayWithObjects:
					   data,
					   ps,
					   [NSNumber numberWithInt:aConnection],
					   [NSNumber numberWithInt:aType],
					   [NSNumber numberWithInt:aCommand],
					   [NSNumber numberWithInt:aMethod],
					   nil];
	if(self.gameSessionType == PNInternetSession) {
		[self performSelectorOnConnectionThread:@selector(sendPacketFilter:) withObject:params];
	} else {
		[self sendPacketFilter:params];
	}
	return YES;
}	

@end

@implementation PNGameSession (Package)

@dynamic peerSocket;
@dynamic startTime;
@dynamic timeDifference;
@dynamic gameKitSession;

@dynamic delegate;
@dynamic peers;
@dynamic selfPeer;
@dynamic room;
@dynamic recommendRTO;
@dynamic gameSessionType;
@dynamic isAlive;

-(void) setPeerSocket:(AsyncUdpSocket*)arg { PNSETPROP(peerSocket,arg); }
-(void) setStartTime:(double)arg { PNPSETPROP(startTime,arg); }
-(void) setTimeDifference:(double)arg { PNPSETPROP(timeDifference,arg); }
-(void) setGameKitSession:(PNGKSession*)arg { PNSETPROP(gameKitSession,arg); }
-(void) setIsStarted:(BOOL)arg { PNPSETPROP(isStarted,arg); }
-(void) setIsAlive:(BOOL)arg { PNPSETPROP(isAlive,arg); }
-(AsyncUdpSocket*) peerSocket { PNGETPROP(AsyncUdpSocket*,peerSocket); }
-(double) startTime { PNGETPROP(double,startTime); }
-(double) timeDifference { PNGETPROP(double,timeDifference); }
-(PNGKSession*) gameKitSession { PNGETPROP(PNGKSession*,gameKitSession); }
-(BOOL) isStarted { PNGETPROP(BOOL,isStarted); }
-(BOOL) isAlive { PNGETPROP(BOOL,isAlive); }

- (void)setDelegate:(id)arg { PNSETPROP(delegate,arg); }
- (void)setPeers:(NSMutableDictionary*)arg { PNSETPROP(peers,arg); }
- (void)setSelfPeer:(PNPeer*)arg { PNSETPROP(selfPeer,arg); }
- (void)setRoom:(PNRoom*)arg { PNSETPROP(room,arg); }
- (void)setRecommendRTO:(float)arg { PNPSETPROP(recommendRTO,arg); }
- (void)setGameSessionType:(PNGameSessionType)arg { PNPSETPROP(gameSessionType,arg); }
- (id)delegate { PNGETPROP(id,delegate); }
- (NSMutableDictionary*)peers { PNGETPROP(NSMutableDictionary*,peers); }
- (PNPeer*)selfPeer { PNGETPROP(PNPeer*,selfPeer); }
- (PNRoom*)room { PNGETPROP(PNRoom*,room); }
- (float)recommendRTO { PNGETPROP(float,recommendRTO); }
- (PNGameSessionType)gameSessionType { PNGETPROP(PNGameSessionType,gameSessionType); }
- (int)lobby { PNGETPROP(int,self.room.lobby.lobbyId); }


-(void)checkRematchResult:(double)aTimeout
{
	PNLog(@"CheckRematchResult");
	rematchCheckTransactionCounter++;
	[self performSelector:@selector(lazyRematchChecking:) withObject:[NSNumber numberWithInt:rematchCheckTransactionCounter] afterDelay:aTimeout];
}

-(NSArray*)opponents {
	NSMutableArray* opponentList = [NSMutableArray array];
	for(PNPeer* p in [self.peers allValues]) {
		if(p!=self.selfPeer && p.isConnecting)
			[opponentList addObject:p];
	}
	return opponentList;
}

// 続けるか否か送信する。
-(void)postRematchMessage:(BOOL)yesOrNo
{
	PNLog(@"postRematchMessage");
	// ホームボタン押したときもブロードキャストするべき？
	// ホームボタンを押される可能性が高い。
	NSData* data;
	NSMutableDictionary *params = [JsonHelper buildDoDictionary:@"p2p.rematch.request"];
	
	if(yesOrNo) {
		[params setObject:@"YES" forKey:@"is_continue"];
	} else {
		[params setObject:@"NO" forKey:@"is_continue"];
	}
	
	data = [JsonHelper toData:params];
	
	// ブロードキャスト
	[self sendData:data
		   toPeers:[self opponents]
		connection:kPNGameSessionReliable
			  type:kPNPacketFlagData
		   command:kPNPacketFlagCommandSystem
			method:kPNPacketFlagMethodRematch];
	
	
	isPosted = YES;
	self.selfPeer.rematchFlag = yesOrNo;
	self.selfPeer.receivedRematchMessage = YES;
	
	if(yesOrNo) {
		[self performSelector:@selector(checkResult:) withObject:[NSNumber numberWithInt:rematchCheckTransactionCounter]];
	} else {
		[self performSelector:@selector(lazyLeaveProcessing)
				   withObject:nil
				   afterDelay:2];
	}
}





@end



@implementation PNGameSession
@dynamic delegate;
@dynamic peers;
@dynamic selfPeer;
@dynamic room;
@dynamic recommendRTO;
@dynamic gameSessionType;
@dynamic isStarted;
@dynamic lobby;


- (id) init
{
	if (self = [super init]) {
		self.peers = [NSMutableDictionary dictionary];
		self.startTime			= 0;
		self.timeDifference		= 0;
		isAlive					= NO;
		self.isStarted			= NO;
		packetMaxSize			= 8192;
		latestSendTime			= CFAbsoluteTimeGetCurrent();
		synchronizeCount		= 0;
		self.gameKitSession		= nil;
		rematchMemberTable		= [[NSMutableDictionary alloc] init];
		timeStamp = -1;
		synchronizationTransactionCounter = 0;
		rematchCheckTransactionCounter = 0;
		cachedPeersForRematch = [[NSMutableDictionary alloc] init];
	}
	return  self;
}


-(NSArray*)peerList
{
	if(true) {
		if(sortedPeersList) {
			PNSafeDelete(sortedPeersList);
		}
		sortedPeersList = [[[self.peers allValues] sortedArrayUsingSelector:@selector(compareAsc:)] retain];
		return sortedPeersList;
	} else {
		if(sortedPeersList) return sortedPeersList;
		sortedPeersList = [[[self.peers allValues] sortedArrayUsingSelector:@selector(compareAsc:)] retain];
		return sortedPeersList;
	}
}

-(PNPeer*)peer:(int)index
{
	return [[self peerList] objectAtIndex:index];
}

-(PNPeer*)peer:(NSString*)address port:(int)port
{
	return [self.peers objectForKey:inetToLongLong([address UTF8String], port)];
}

-(double)timeElapsed
{
	return CFAbsoluteTimeGetCurrent() - self.startTime + self.timeDifference;
}

-(int)countPeers
{
	return [self.peers count];
}

-(void)setPeer:(PNPeer*)peer forKey:(id)key
{
	[self.peers setObject:peer forKey:key];
}

-(void)disconnect
{
	PNNetworkLog(@"Send disconect message to all peer.");
	if(self.gameSessionType == PNInternetSession) {
		NSData* data = [NSData dataWithBytes:"{}" length:2];
		[self sendData:data
			   toPeers:[self opponents]
			connection:kPNGameSessionUnreliable
				  type:kPNPacketFlagData
			   command:kPNPacketFlagCommandSystem
				method:kPNPacketFlagMethodFin
		 ];
		for(PNPeer* peer in [self.peers allValues]) {
			if(self.selfPeer == peer) continue;
			if(peer.isConnecting) {
				NSObject* delegateObject = self.delegate;
				if([delegateObject respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
					[delegateObject performSelectorOnMainThread:@selector(gameSession:didDisconnectPeer:)
													withObjects:[NSArray arrayWithObjects:self,peer,nil]];
			}
			peer.isConnecting = NO;
			[PNPacketFireWall removeIPv4:peer.address port:peer.udpPort];
		}
	} else {
		NSData* data = [NSData dataWithBytes:"{}" length:2];
		
		PNGKPacket* packet = [PNGKPacket create];
		packet.command = _PNGK_SESSION_PROTOCOL_FIN;
		packet.length = data.length;
		packet.srcData = (unsigned char*)malloc(data.length);
		memcpy(packet.srcData, data.bytes, data.length);
		int dataLen = [packet pack];
		
		[self.gameKitSession sendAll:[NSData dataWithBytes:packet.dstData length:dataLen] mode:kPNGameSessionUnreliable];

		for(PNPeer* peer in [self.peers allValues]) {
			if(self.selfPeer == peer) continue;
			if(peer.isConnecting) {
				NSObject* delegateObject = self.delegate;
				if([delegateObject respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
					[delegateObject performSelectorOnMainThread:@selector(gameSession:didDisconnectPeer:)
													withObjects:[NSArray arrayWithObjects:self,peer,nil]];
			}
			peer.isConnecting = NO;
		}
	}
	[self.peers removeAllObjects];
	PNLog(@"-------------------remove------------------");
}

-(BOOL)sendData:(NSData *)aData
		toPeers:(NSArray *)pPeers
   withDataMode:(PNSendDataMode)aMode
{
	
	return [self sendData:aData
				  toPeers:pPeers
			   connection:aMode
					 type:kPNPacketFlagData
				  command:kPNPacketFlagCommandUser
				   method:kPNPacketFlagMethodUser
			];
}

-(BOOL)sendDataToAllPeers:(NSData *)aData
			 withDataMode:(PNSendDataMode)aMode
{
	return [self sendData:aData toPeers:[self.peers allValues] withDataMode:aMode];
}


// デリゲート切り替えタイミング用のDelay
#define _BEFORE_DELAY		1.0
#define _AFTER_DELAY		1.0


// デリゲート切り替えディレイ用
-(void) CALLBACK_StartSynchronousProcessing
{
	AsyncUdpSocket* udp = udpSocketForInternet;
	[udp setDelegate:self];
	[self setup:udp address:nil	port:0];
	[udp receiveWithTimeout:10.0 tag:kPNStunUDPConnectionTagPacket];
	self.peerSocket = udp;
	
	[self performSelector:@selector(synchronousProcessing) withObject:nil afterDelay:_AFTER_DELAY];
}


-(void) CALLBACK_StartGameSessionOnUDPThread:(NSArray*)params
{
	PNLog(@"CALLBACK_StartGameSessionOnUDPThread");
	// デリゲート切り替えディレイ用
	[self performSelector:@selector(CALLBACK_StartSynchronousProcessing) withObject:nil afterDelay:_BEFORE_DELAY];
}

// ゲームセッションのスタート処理を行う。
-(void) startGameSession:(id)callbackDelegate sel:(SEL)sel
{
	callbackGameStarting			= [callbackDelegate retain];
	callbackGameStartingSel			= sel;
	
	if(self.gameSessionType == PNInternetSession) {
		[self performSelectorOnConnectionThread:@selector(CALLBACK_StartGameSessionOnUDPThread:) withObject:nil];
	} else {
		[self synchronousProcessing];
	}
}

-(void)CALLBACK_EndGameSession
{
	PNLog(@"GameSession::endGameSession.");
	self.isAlive = NO;
	if(self.gameSessionType == PNInternetSession) {
		if(self.room.isJoined) {
			[self.room leave];
		}
	}
	
	if(callbackGameStarting) {
		[callbackGameStarting release];
		callbackGameStarting = nil;
	}
	callbackGameStartingSel = nil;
	
	[PNUDPConnectionService deletePairingTable:[self.room.pairingTable allValues]];
	
	[self.room.pairingTable removeAllObjects];
	NSArray *ps = [self.peers allValues];
	for(PNPeer *p in ps) {
		if(p.isConnecting && self.selfPeer != p) {
			NSObject* delegateObject = delegate;
			if([delegateObject respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
				[delegateObject performSelectorOnMainThread:@selector(gameSession:didDisconnectPeer:)
												withObjects:[NSArray arrayWithObjects:self,p,nil]];
			
		}
		[PNPacketFireWall removeIPv4:p.address port:p.udpPort];
		p.isConnecting = NO;
	}
	
	self.room.isHeartBeatNecessary = NO;
	[self.peers removeAllObjects];
	PNLog(@"-------------------remove------------------");
	[PNUDPConnectionService clear];
	
	if(self.gameSessionType == PNInternetSession) {
		// Internet UDP Socket.
		if(self.peerSocket)
			self.peerSocket = nil;
		
		[PNUDPConnectionService rebind];
	} else {
		if(self.gameKitSession) {
			[self.gameKitSession stop];
			self.gameKitSession = nil;
		}
	} 
	
	if([self.delegate respondsToSelector:@selector(didGameSessionEnd:)])
		[self.delegate didGameSessionEnd:self];
	
	if([self.room.delegate respondsToSelector:@selector(room:didEndGameSession:)])
		[self.room.delegate room:self.room didEndGameSession:self];
}

-(void)endGameSession
{
	[self performSelectorOnMainThread:@selector(CALLBACK_EndGameSession) withObject:nil waitUntilDone:NO];
}

-(void)sendPacketFilter:(NSArray*)params
{
	double t = CFAbsoluteTimeGetCurrent();
	int r = 0;
	switch (kPNSoftwareSendDelayType) {
		case kPNSoftwareSendDelayTypeNone:{
		}break;
		case kPNSoftwareSendDelayTypeRandom:{
			r = MAX((rand()%kPNSoftwareSendDelayMaximum),kPNSoftwareSendDelayMinimum);
		}break;
		case kPNSoftwareSendDelayTypeSinewaveSmooth:{
			int f = (kPNSoftwareSendDelayMaximum-kPNSoftwareSendDelayMinimum)/2;
			r = (int)(kPNSoftwareSendDelayMinimum + f + f*sin(t/13.8888));
		}break;
		case kPNSoftwareSendDelayTypeSinewaveIntense:{
			int f = (kPNSoftwareSendDelayMaximum-kPNSoftwareSendDelayMinimum)/2;
			r = (int)(kPNSoftwareSendDelayMinimum + f + f*sin(t/13.8888*4));
		}break;
	}
	
	// Reliableのパケットは落とさない。
	int connection	= [[params objectAtIndex:2] intValue];
	if(connection != kPNGameSessionReliable && kPNSoftwareSendPacketLossPercentage) {
		int rnd = rand() % 100;
		int g = rnd - kPNSoftwareSendPacketLossPercentage;
		if(g < 0) {
			return;
		}
	}
	if(r) {
		[self performSelector:@selector(send:)
				   withObject:params
				   afterDelay:r/1000.0f];
	} else {
		[self send:params];
	}
}

-(void)send:(NSArray*)params
{
	NSData* data	= [params objectAtIndex:0];
	NSArray* ps		= [params objectAtIndex:1];
	int connection	= [[params objectAtIndex:2] intValue];
	int type		= [[params objectAtIndex:3] intValue];
	int command		= [[params objectAtIndex:4] intValue];
	int method		= [[params objectAtIndex:5] intValue];
	
	switch(connection) {
		case kPNGameSessionReliable: {
			if(self.gameSessionType == PNNearbySession) {
				NSArray* clients = ps;
				for(PNPeer* peer in clients) {
					if(peer.isConnecting && ![peer.address isEqualToString:[NSString stringWithFormat:@"%d",_PNGK_SESSION_SELF_PEER_NUMBER]]) {
						NSData* packedData = [PNGKSession packData:data];
						[self.gameKitSession send:packedData peer:peer.address mode:kPNGameSessionReliable];
					}
				}
			} else {
				NSArray* clients = ps;
				for(PNPeer* u in clients) {
					if(u.isConnecting && selfPeer != u) {
						int theFlag = connection|type|command|method;
						PNPacket* packet	= [PNPacket create];
						double time			= CFAbsoluteTimeGetCurrent();
						packet.data			= data;
						packet.theFlag		= theFlag;
						packet.sequence		= u.sendSequenceCounter++;
						packet.timestamp	= time;
						packet.address		= u.address;
						packet.port			= u.udpPort;
						[self sendDataPacket:packet peer:u];
					}
				}
			}
		}break;
		case kPNGameSessionUnreliable:{
			if(self.gameSessionType == PNNearbySession) {
				NSArray* clients = ps;
				for(PNPeer* peer in clients) {
					if(peer.isConnecting && ![peer.address isEqualToString:[NSString stringWithFormat:@"%d",_PNGK_SESSION_SELF_PEER_NUMBER]]) {
						NSData* packedData = [PNGKSession packData:data];
						[self.gameKitSession send:packedData peer:peer.address mode:kPNGameSessionUnreliable];
					}
				}
			} else {
				NSArray* clients = ps;
				for(PNPeer* u in clients) {
					if(u.isConnecting && selfPeer != u) {
						int theFlag = connection|type|command|method;
						
						PNPacket* packet	= [PNPacket create];
						packet.data			= data;
						packet.theFlag		= theFlag;
						packet.address		= u.address;
						packet.port			= u.udpPort;
						[packet pack];
						[self send:packet.packedData host:u.address port:u.udpPort];
					}
				}
			}
		}break;
		case kPNGameSessionRaw:{
		}break;
	}	
}


-(void)finishTimeoutObserver:(NSNumber*)aIsNeed // チェックが必要かどうか
					delegate:(id)aDelegate // コールバック先
					selector:(SEL)aSelector // コールバック先
				  withObject:(id)aArg	// 引数
{
	if([aIsNeed intValue] && [delegate respondsToSelector:aSelector]) {
		[delegate performSelector:aSelector
					   withObject:aArg];
	}
}


-(void)finish:(PNGameSet*)aGameSet// rematchTimeout:(float)aTimeout
{
	if(self.gameSessionType == PNNearbySession) {
//		isNeedRematchTimeout = YES;
//		[self performSelector:@selector(rematchTimeout) withObject:nil afterDelay:aTimeout];
	} else if (self.gameSessionType == PNInternetSession) {
		[[PNMatchManager sharedObject] finish:aGameSet room:self.room delegate:self 
								  onSucceeded:@selector(finishMatchSucceeded)
									 onFailed:@selector(finishMatchFailed:)];

	}
}
- (void)finishMatchSucceeded
{
	// BEGIN - lerry added code
	PNCLog(PNLOG_CAT_GAME, @"-[PNGameSession finishMatchSucceeded]");
	// END - lerry added code
}
- (void)finishMatchFailed:(PNError*)error
{
	PNWarn(@"[WARNING]match/finish error. %@", error.message);
}


// リマッチのパケットを受け取る
-(void)onReceivedRematchPacket:(NSDictionary*)params
{
	PNLog(@"Recv rematch packet.");
	PNPeer* aPeer		= [params objectForKey:@"from"];
	NSData* aData		= [params objectForKey:@"data"];
	
	NSString* jsonStr	= [[[NSString alloc] initWithBytes:aData.bytes length:aData.length encoding:NSUTF8StringEncoding] autorelease];
	NSDictionary* json	= [jsonStr JSONValue];
	NSString* command	= [json objectForKey:@"do"];
	
	if([command isEqualToString:@"p2p.rematch.sync"]) {
		PNLog(@"p2p.rematch.sync");
		[rematchMemberTable setObject:aPeer forKey:inetToLongLong([aPeer.address UTF8String], aPeer.udpPort)];
	} else if ([command isEqualToString:@"p2p.rematch.request"]) {
		PNLog(@"p2p.rematch.request");
		BOOL isContinue		= [[json objectForKey:@"is_continue"] boolValue];
		PNLog(@"Opponent continue flag is %s",isContinue?"TRUE":"FALSE");
		NSNumber* key		= inetToLongLong([aPeer.address UTF8String], aPeer.udpPort);
		PNPeer* p = [self.peers objectForKey:key];
		p.rematchFlag = isContinue;
		p.receivedRematchMessage = YES;
		if(!isContinue) {
			if(key) [self.peers removeObjectForKey:key];
			if([self.room.delegate respondsToSelector:@selector(room:didLeaveUser:)])
				[self.room.delegate room:room didLeaveUser:p.user];
			
			NSObject* delegateObject = self.delegate;
			if([delegateObject respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
				[delegateObject performSelectorOnMainThread:@selector(gameSession:didDisconnectPeer:)
												withObjects:[NSArray arrayWithObjects:self,p,nil]];
			
			p.isConnecting = NO;
			
			PNLog(@"-------------------remove------------------");
		}
		[self performSelector:@selector(checkResult:) withObject:[NSNumber numberWithInt:rematchCheckTransactionCounter]];
		
	} else if ([command isEqualToString:@"p2p.rematch.option"]) {
		NSObject* delegateObject = self.room.delegate;
		if([delegateObject respondsToSelector:@selector(receivedRequestMessage:)])
			[delegateObject performSelector:@selector(receivedRequestMessage:) withObject:json];
		
	}
}

// Loop check.
-(void)synchronousProcessingBeforeRematch:(NSNumber*)aTime counter:(NSNumber*)aCounter
{
	PNLog(@"synchronousProcessingBeforeRematch");
	
	// Count connection aliving player.
	int alivedCount = 0;
	BOOL isDisconnectedUserExist = NO;
	for(PNPeer* p in [cachedPeersForRematch allValues]) {
		if(self.selfPeer != p) {
			if(p.isConnecting) {
				alivedCount++;
			} else {
				isDisconnectedUserExist = YES;
				PNLog(@"Disccrencted user is exist");
			}
		}
	}
	
	// Check member connecting validation and recursive counter.
	if(![aCounter intValue] || isDisconnectedUserExist) {
		// If synchronous processing timeout or detected disconnecting user, leave from current room.
		[self.room leave];
		return;
	}
	
	
	// Count posted synchronization packet.
	int rematchMemberCount = 0;
	for(PNPeer* p in [rematchMemberTable allValues]) {
		PNLog(@"Opponent : %@",p.user.username);
		if(self.selfPeer != p && p.isConnecting)
			rematchMemberCount++;
	}
	
	PNLog(@"aliveCount:%d memberCount:%d", alivedCount, rematchMemberCount);
	if(alivedCount == rematchMemberCount) { // Synchronization ok.
		PNLog(@"Synchronization ok");
		// Next step
		if([self.room.delegate respondsToSelector:@selector(synchronizationBeforeVotingDone)])
			[self.room.delegate synchronizationBeforeVotingDone];
	} else {
		if([aCounter intValue]) {
			// Repeat.
			[self performSelector:@selector(synchronousProcessingBeforeRematch:counter:) 
					   withObjects:[NSArray arrayWithObjects:aTime,
								   [NSNumber numberWithInt:[aCounter intValue]-1],
								   nil]
					   afterDelay:[aTime doubleValue]];
		}
	}
}

-(void)waitForRematch:(double)aTimeout
{
	// Initialize relating factor.
	self.selfPeer.rematchFlag = NO;
	self.selfPeer.receivedRematchMessage = NO;
	self.isStarted = NO;
	isVotingTimeoutCheckNecessary = YES;
	
	// Rematch processing is notified to have started. 
	if([self.room.delegate respondsToSelector:@selector(didStartRematchProcessing)])
		[self.room.delegate didStartRematchProcessing];
	
	
	// Check member.
	int activeMember = 0;
	for(PNPeer* p in [self.peers allValues]) {
		if(p.isConnecting)
			activeMember++;
	}
	if(self.room.maxMemberNum != activeMember) { 
		// If detected disconnecting user, leave from current room.
		[self.room leave];
		return;
	}
	
	// Cached peers container for rematch processing.
	PNSafeDelete(cachedPeersForRematch);
	cachedPeersForRematch = [[NSMutableDictionary dictionary] retain];
	for(NSString* key in [self.peers allKeys]) {
		[cachedPeersForRematch setObject:[self.peers objectForKey:key] forKey:key];
	}
	PNLog(@"waitForRematch");
	{ // Send to all synchronous message.
		NSData* data;
		NSMutableDictionary *params = [JsonHelper buildDoDictionary:@"p2p.rematch.sync"];
		data = [JsonHelper toData:params];
		
		// Broad cast
		[self sendData:data
			   toPeers:[self opponents]
			connection:kPNGameSessionReliable
				  type:kPNPacketFlagData
			   command:kPNPacketFlagCommandSystem
				method:kPNPacketFlagMethodRematch];
	}
	
	for(PNPeer* p in [cachedPeersForRematch allValues]) {
		PNLog(@"%@ C:%s R:%s P:%s",p.user.username,p.isConnecting?"YES":"NO",p.rematchFlag?"YES":"NO",p.receivedRematchMessage?"YES":"NO");
	}
	
	// Repeat previous synchronization checking.
	const double delay = 1.0;
	int count = (int)(aTimeout / delay);
	[self synchronousProcessingBeforeRematch:[NSNumber numberWithDouble:delay] counter:[NSNumber numberWithInt:count]];
}


-(void)lazyRematchChecking:(NSNumber*)aTransaction
{
	if(isVotingTimeoutCheckNecessary) {
		PNLog(@"lazyRematchChecking");
		if([aTransaction intValue] == rematchCheckTransactionCounter)
		{
			PNLog(@"Check isPosted flag.");
			if(!isPosted) {
				[self postRematchMessage:NO];
				return;
			}
			
			if(self.selfPeer.rematchFlag) {
				[self performSelector:@selector(checkResult:) withObject:aTransaction afterDelay:5];
			}
		}
	}
}
-(void)checkResult:(NSNumber*)aTransaction
{
	if([aTransaction intValue] == rematchCheckTransactionCounter && isVotingTimeoutCheckNecessary) {
		int memberValidationCounter = 0;
		for(PNPeer* p in [cachedPeersForRematch allValues]) {
			if(p.receivedRematchMessage)
				memberValidationCounter++;
		}
		if(memberValidationCounter != [cachedPeersForRematch count])
			return;
		
		isVotingTimeoutCheckNecessary = NO;
		PNLog(@"lazyRematchResultChecking");
		
		int yesCounter = 0;
		for(PNPeer* p in [cachedPeersForRematch allValues]) {
			PNLog(@"%@ C:%s R:%s P:%s",p.user.username,p.isConnecting?"YES":"NO",p.rematchFlag?"YES":"NO",p.receivedRematchMessage?"YES":"NO");
		}
		
		for(PNPeer* p in [cachedPeersForRematch allValues]) {
			if(p.rematchFlag)
				yesCounter++;
			else {
				if(![self.peers objectForKey:inetToLongLong([p.address UTF8String], p.udpPort)])
					continue;
				if(inetToLongLong([p.address UTF8String], p.udpPort))
					[self.peers removeObjectForKey:inetToLongLong([p.address UTF8String], p.udpPort)];
				if([self.room.delegate respondsToSelector:@selector(room:didLeaveUser:)])
					[self.room.delegate room:room didLeaveUser:p.user];
				
				NSObject* delegateObject = self.delegate;
				if([delegateObject respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
					[delegateObject performSelectorOnMainThread:@selector(gameSession:didDisconnectPeer:)
													withObjects:[NSArray arrayWithObjects:self,p,nil]];
				
				p.isConnecting = NO;
				
				PNLog(@"-------------------remove------------------");
				PNLog(@"%@ was deleted.",p.user.username);
			}
		}
		
		
		// Notice! Cached peers list clear.
		@synchronized(self) {
			if(sortedPeersList) {
				id obj = sortedPeersList;
				sortedPeersList = nil;
				[obj release];
			}
		}
		
		NSArray* newPeerList = [[self.peers allValues] sortedArrayUsingSelector:@selector(compareAsc:)];

		// Decide host.
		for(PNPeer* p in newPeerList) {
			if(p.rematchFlag) {
				if(self.selfPeer == p)
					self.room.isOwner = YES;
				break;
			}
		}
		
		if([self.room.delegate respondsToSelector:@selector(decidedRematchResult:)])
			[self.room.delegate decidedRematchResult:newPeerList];
		
		
		// 全員リマッチであればすぐに開始
		if(self.room.maxMemberNum == yesCounter) {
			if(self.room.isOwner) {
				NSString* session = [PNUser session];
				[PNMatchRequestHelper start:session
									   room:self.room.roomId
								   delegate:self
								   selector:@selector(responseMatch:)
								 requestKey:@"PNGameSessionMatchStart"];
			}
		} else {
			NSMutableArray *userArray = [NSMutableArray array];
			for(PNPeer* p in newPeerList) {
				[userArray addObject:p.user];
			}
			if([self.room.delegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
				[self.room.delegate room:self.room didUpdateJoinedUsers:userArray];
			
			if(self.room.isOwner) {
				[self.room unlock];
			}
			
			// Rebind AsyncUdpSocket delegate for pairing.
			[PNUDPConnectionService rebind];
		}
		
		[rematchMemberTable removeAllObjects];
		for(PNPeer* p in [self.peers allValues]) {
			p.rematchFlag = NO;
			p.receivedRematchMessage = NO;
		}
		isPosted = NO;
	}
}

-(void)postRequestMessage:(NSDictionary*)parameter
{
	NSMutableDictionary *params = [JsonHelper buildDoDictionary:@"p2p.rematch.option"];
	[params addEntriesFromDictionary:parameter];
	NSData* data = [JsonHelper toData:params];
	
	// Broad cast
	[self sendData:data
		   toPeers:[self opponents]
		connection:kPNGameSessionReliable
			  type:kPNPacketFlagData
		   command:kPNPacketFlagCommandSystem
			method:kPNPacketFlagMethodRematch];
	
	NSObject* delegateObject = self.room.delegate;
	if([delegateObject respondsToSelector:@selector(receivedRequestMessage:)])
		[delegateObject performSelector:@selector(receivedRequestMessage:) withObject:params];
	
}

-(void)lazyLeaveProcessing
{
	NSData* data = [NSData dataWithBytes:"{}" length:2];
	[self sendData:data
		   toPeers:[self opponents]
		connection:kPNGameSessionUnreliable
			  type:kPNPacketFlagData
		   command:kPNPacketFlagCommandSystem
			method:kPNPacketFlagFin];
	
	//退室処理はUI側でキャッチして行います
	if([self.room.delegate respondsToSelector:@selector(decidedRematchResult:)])
		[self.room.delegate decidedRematchResult:nil];
}

-(void)responseMatch:(PNHTTPResponse*)response
{
	NSDictionary*	json = [response jsonDictionary];
	
	PNLog(@"responseMatch : %@",json);
	if(response.isValidAndSuccessful) {
		// Nothing to do.
	} else {
		PNLog(@"responseMatch error. %@",json);
	}
}

-(void)dealloc
{
	if(isStarted)
		[self endGameSession];
	
	if(sortedPeersList){[sortedPeersList release];}
	self.gameKitSession = nil;
	self.delegate = nil;
	self.peers = nil;
	self.room = nil;
	self.isAlive = NO;
	
	PNSafeDelete(rematchMemberTable);
	PNSafeDelete(cachedPeersForRematch);
	
	[super dealloc];
}

@end
