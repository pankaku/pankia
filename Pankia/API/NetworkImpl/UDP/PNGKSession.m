#import "PNGKSession.h"
#import "JsonHelper.h"
#import "PNRoom.h"
#import "PNLocalRoom.h"
#import "PNRoom+Package.h"
#import "PNRoomManager.h"
#import "NSObject+PostEvent.h"
#import "PNUDPConnectionService.h"
#import "PNNetworkError.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNLogger+Package.h"


static int pack(PNGKPacket *packet);
static int unpack(PNGKPacket* packet,unsigned char* data,int len);
static int GetConnectionMode(int mode);

@implementation PNGKPacket
@synthesize command, length, srcData, dstData;

-(id)init
{
	if(self = [super init])
	{
		command = -1;
		length = 0;
		srcData = NULL;
		dstData = NULL;
	}
	return self;
}

-(void)setSourceData:(NSData*)data
{
	if(srcData) free(srcData);
	srcData = (unsigned char*)malloc(data.length);
	memcpy(srcData,data.bytes,data.length);
	length = data.length;
}

-(NSDictionary*)convertToJSON
{
	NSData* sdata = [NSData dataWithBytes:srcData length:length];
	NSString* received;
	NSDictionary* json;
	received	= [[[NSString alloc] initWithData:sdata encoding:NSUTF8StringEncoding] autorelease];
	json		= [received JSONValue];
	return json;
}


-(int)pack
{
	return pack(self);
}

-(int)unpack:(NSData*)data 
{
	return unpack(self, (unsigned char*)data.bytes, (int)data.length);
}

-(void)dealloc
{
	if(srcData) free(srcData);
	if(dstData) free(dstData);
	[super dealloc];
}

+(PNGKPacket*)create
{
	PNGKPacket* packet = [[[PNGKPacket alloc] init] autorelease];
	return packet;
}

@end




@implementation PNGKSession
@synthesize delegate;
@synthesize roomDelegate;
@synthesize roomManagerDelegate;
@synthesize isHost;
@synthesize isConnectedResponse;
@synthesize members;
@synthesize gksession;
@synthesize currentRoom;
@synthesize hostPeer;
@synthesize rooms;

-(id)init
{
	if(self = [super init]) {
		self.delegate = nil;
		self.roomDelegate = nil;
		self.roomManagerDelegate = nil;
		self.members = [NSMutableDictionary dictionary];
		self.gksession = nil;
		state = _PNGK_SESSION_STATE_NONE;
		self.isHost = NO;
		joinCounter = 1;
		self.currentRoom = nil;
		self.hostPeer = nil;
		self.rooms = [NSMutableDictionary dictionary];
	}
	return self;
}

-(void)dealloc
{
	self.gksession = nil;
	self.delegate = nil;
	self.roomDelegate = nil;
	self.roomManagerDelegate = nil;
	self.members = nil;
	self.currentRoom = nil;
	self.rooms = nil;
	[timeoutTimer invalidate];
	[gameKey release];
	[version release];
	[super dealloc];
}

+(PNGKSession*)create
{
	return [[[PNGKSession alloc] init] autorelease];
}

+(NSData*)packData:(NSData*)data
{
	PNGKPacket* packet = [PNGKPacket create];
	packet.command = _PNGK_SESSION_PROTOCOL_DATA;
	packet.length = data.length;
	packet.srcData = (unsigned char*)malloc(data.length);
	memcpy(packet.srcData, data.bytes, data.length);
	int dataLen = [packet pack];
	return [NSData dataWithBytes:packet.dstData length:dataLen];
}

-(void)setPeerToParams:(PNPeer*)peer dstParams:(NSMutableDictionary*)params
{
	NSString* countryCode		= peer.user.countryCode;
	NSNumber* achievementPoint	= [NSNumber numberWithInt:peer.user.achievementPoint] ;
	NSNumber* achievementTotal	= [NSNumber numberWithInt:peer.user.achievementTotal];
	NSString* gradeName			= peer.user.gradeName;
	NSNumber* gradePoint		= [NSNumber numberWithInt:peer.user.gradePoint];
	NSString* iconURL			= peer.user.iconURL;
	NSNumber* gradeEnabled		= [NSNumber numberWithBool:peer.user.gradeEnabled];
	
	[params setObject:countryCode?countryCode:@"" forKey:@"countryCode"];
	[params setObject:achievementPoint?achievementPoint:[NSNumber numberWithInt:0] forKey:@"achievementPoint"];
	[params setObject:achievementTotal?achievementTotal:[NSNumber numberWithInt:0] forKey:@"achievementTotal"];
	[params setObject:gradeName?gradeName:@"" forKey:@"gradeName"];
	[params setObject:gradePoint?gradePoint:[NSNumber numberWithInt:0] forKey:@"gradePoint"];
	[params setObject:iconURL?iconURL:@"" forKey:@"iconURL"];
	[params setObject:gradeEnabled forKey:@"gradeEnabled"];
}

- (void)setParamToPeer:(PNPeer*)dstPeer srcParams:(NSDictionary*)params
{
	NSString* countryCode		= [params objectForKey:@"countryCode"];
	NSNumber* achievementPoint	= [params objectForKey:@"achievementPoint"];
	NSNumber* achievementTotal	= [params objectForKey:@"achievementTotal"];
	NSString* gradeName			= [params objectForKey:@"gradeName"];
	NSNumber* gradePoint		= [params objectForKey:@"gradePoint"];
	NSString* iconURL			= [params objectForKey:@"iconURL"];
	NSNumber* gradeEnabled		= [params objectForKey:@"gradeEnabled"];
	
	dstPeer.user.countryCode		= countryCode;
	dstPeer.user.achievementPoint	= [achievementPoint intValue];
	dstPeer.user.achievementTotal	= [achievementTotal intValue];
	dstPeer.user.gradeName			= gradeName;
	dstPeer.user.gradePoint			= [gradePoint intValue];
	dstPeer.user.iconURL			= iconURL;
	dstPeer.user.gradeEnabled		= [gradeEnabled boolValue];
}

- (void)sendPackingDataByReliableMode:(PNGKPacket*)packet peer:(NSString*)peerID
{
	int dataLen = [packet pack];
	[self send:[NSData dataWithBytes:packet.dstData length:dataLen]
		  peer:peerID
		  mode:kPNGameSessionReliable];
}

- (void)sendToAllPackingDataByReliableMode:(PNGKPacket*)packet
{
	int dataLen = [packet pack];
	[self sendAll:[NSData dataWithBytes:packet.dstData length:dataLen]
			 mode:kPNGameSessionReliable];
}



- (void)start:(BOOL)aIsHost gameKey:(NSString*)aGameKey version:(NSString*)aVersion lobby:(PNLobby*)lobby
{
	[self stop];
	state = _PNGK_SESSION_STATE_READY;
	
	int peerMode;
	NSString * publishName = [PNUser currentUser].username;
	self.isHost = aIsHost;
	
	if(self.isHost) {
		PNPeer* peer = [PNPeer createPeerWithUser:[PNUser currentUser]];
		NSString* peerId = [NSString stringWithFormat:@"%d",_PNGK_SESSION_SELF_PEER_NUMBER];
		peer.joinedNumber = 0;
		peer.address = peerId;
		[members setObject:peer forKey:peerId];
		
		if([roomDelegate respondsToSelector:@selector(room:didJoinUser:)])
			[roomDelegate room:currentRoom didJoinUser:peer.user];
		
		NSArray* sortedPeersList = [[members allValues] sortedArrayUsingSelector:@selector(compareAsc:)];
		
		NSMutableArray* userArray = [NSMutableArray array];
		for(PNPeer* ePeer in sortedPeersList) {
			[userArray addObject:ePeer.user];
		}
		if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
			[roomDelegate room:currentRoom didUpdateJoinedUsers:userArray];
	}	
	
	if(aIsHost) {
		peerMode = GKSessionModeServer;
		publishName = [NSString stringWithFormat:@"%@\t%@", self.currentRoom.roomName ,[PNUser currentUser].username];
	} else {
		peerMode = GKSessionModeClient;
	}
	
	unsigned int hashedKey = [[NSString stringWithFormat:@"%@%@%d",aGameKey,aVersion,lobby.lobbyId] hash];
	NSLog(@"hashKey:%d lobbyId:%d", hashedKey, lobby.lobbyId);
	NSString* hashedNetworkKey = [NSString stringWithFormat:@"n%d",hashedKey&0xFFFF];
	self.gksession = [[[GKSession alloc] initWithSessionID:hashedNetworkKey
											   displayName:publishName
											   sessionMode:peerMode] autorelease];
	
	self.gksession.delegate = self;
	[self.gksession setAvailable:YES];
	
	PNCLog(PNLOG_CAT_SESSION, @"Start Gamekit service");
	
	[gameKey release];
	[version release];
	gameKey = [aGameKey retain];
	version = [aVersion retain];
}

- (void)stop
{
	PNCLog(PNLOG_CAT_SESSION, @"%s", __FUNCTION__);
	
	[timeoutTimer invalidate];
	timeoutTimer = nil;
	
	if(self.gksession) {
		[self.gksession disconnectFromAllPeers];
		self.gksession.available = NO;
		[self.gksession setDataReceiveHandler:nil withContext:nil];
		self.gksession.delegate = nil;
		self.gksession = nil;
	}
}

- (void)leave
{
	[timeoutTimer invalidate];
	timeoutTimer = nil;
	
	if(self.gksession) {
		PNGKPacket* packet = [PNGKPacket create];
		packet.command = _PNGK_SESSION_PROTOCOL_LEAVE;
		NSMutableDictionary* params = [NSMutableDictionary dictionary];
		[packet setSourceData:[JsonHelper toData:params]];
		[self sendToAllPackingDataByReliableMode:packet];
	}
	[members removeAllObjects];
}



-(void)sendByGameKitSenderOnMainThread:(NSArray*)params
{
	PNCLog(PNLOG_CAT_SESSION, @"sendByGameKitSenderOnMainThread");
	NSData* data	= [params objectAtIndex:0];
	NSNumber* mode	= [params objectAtIndex:1];
	NSString* peer	= [params objectAtIndex:2];
	BOOL isSentErrorMessage = NO;
	NSError* error = nil;
	
	if([self.gksession sendData:data toPeers:[NSArray arrayWithObject:peer] withDataMode:GetConnectionMode([mode intValue]) error:&error]) {
		PNLog(@"GKSession sendData.");
	} else {
		isSentErrorMessage = YES;
		PNWarn(@"GKSession error. Can't send packet to opponent.(Queuing fail)");
		PNError* error = [PNNetworkError errorWithType:kPNUDPErrorUnknown message:@"GKSession send error."];
		if([self.delegate respondsToSelector:@selector(session:didSendError:opponentPeerID:data:)])
			[self.delegate session:self didSendError:error opponentPeerID:peer data:data];
	}
	if(error) {
		NSString* str = [NSString stringWithFormat:@"E:%@",error];
		PNWarn(@"E:%s",[str UTF8String]);
		
		PNError* error = [PNNetworkError errorWithType:kPNUDPErrorUnknown message:@"GKSession send error."];
		if(!isSentErrorMessage)
			if([self.delegate respondsToSelector:@selector(session:didSendError:opponentPeerID:data:)])
				[self.delegate session:self didSendError:error opponentPeerID:peer data:data];
	}
}

-(void)sendByGameKitSenderOnMainThreadAll:(NSArray*)params
{
	PNCLog(PNLOG_CAT_SESSION, @"sendByGameKitSenderOnMainThreadAll");
	NSData* data	= [params objectAtIndex:0];
	NSNumber* mode	= [params objectAtIndex:1];
	NSError* error = nil;
	BOOL isSentErrorMessage = NO;
	
	if([self.gksession sendDataToAllPeers:data withDataMode:GetConnectionMode([mode intValue]) error:&error]) {
		PNLog(@"GKSession sendDataToAll.");
	} else {
		isSentErrorMessage = YES;
		PNWarn(@"GKSession error. Can't send packet to opponent.(Queuing fail)");
		PNError* error = [PNNetworkError errorWithType:kPNUDPErrorUnknown message:@"GKSession send error."];
		for(NSString* peerID in [members allKeys]) {
			if([self.delegate respondsToSelector:@selector(session:didSendError:opponentPeerID:data:)])
				[self.delegate session:self didSendError:error opponentPeerID:peerID data:data];
		}
	}
	if(error) {
		NSString* str = [NSString stringWithFormat:@"E:%@",error];
		PNWarn(@"E:%s",[str UTF8String]);
		PNError* error = [PNNetworkError errorWithType:kPNUDPErrorUnknown message:@"GKSession send error."];
		if(!isSentErrorMessage)
			for(NSString* peerID in [members allKeys]) {
				if([self.delegate respondsToSelector:@selector(session:didSendError:opponentPeerID:data:)])
					[self.delegate session:self didSendError:error opponentPeerID:peerID data:data];
			}
	}
}

-(void)sendAll:(NSData*)data mode:(int)mode
{
	[self sendByGameKitSenderOnMainThreadAll:[NSArray arrayWithObjects:data,[NSNumber numberWithInt:mode],nil]];
}

-(void)send:(NSData*)data peer:(NSString*)peer mode:(int)mode
{
	[self sendByGameKitSenderOnMainThread:[NSArray arrayWithObjects:data,[NSNumber numberWithInt:mode],peer,nil]];
}

-(void)selectRoom:(PNRoom*)room
{
	PNCLog(PNLOG_CAT_SESSION, @"%s roomID:%@", __FUNCTION__, room.roomId);
	//入室命令が来てから接続する
	[self.gksession connectToPeer:room.roomId withTimeout:30];
}

- (void)sendJoinMessage:(PNRoom *)room {
	//入室処理
	PNLog(@"%s", __FUNCTION__);
	PNPeer* peer = [PNPeer createPeerWithUser:[PNUser currentUser]];
	peer.joinedNumber = joinCounter++;
	peer.address = [NSString stringWithFormat:@"%d",_PNGK_SESSION_SELF_PEER_NUMBER];
	[members setObject:peer forKey:peer.address];
	
	PNGKPacket* packet = [PNGKPacket create];
	packet.command = _PNGK_SESSION_PROTOCOL_REQUEST_JOIN;
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[self setPeerToParams:peer dstParams:params];
	[packet setSourceData:[JsonHelper toData:params]];
	[self sendToAllPackingDataByReliableMode:packet];
	PNLog(@"%s end", __FUNCTION__);
}

-(void)startGameSessionNotification
{
	PNLocalRoom* room = self.currentRoom;
	room.isHeartBeatNecessary = YES;
	[room heartbeat];
	
	if([roomDelegate respondsToSelector:@selector(room:didBeginGameSession:)])
		[roomDelegate room:currentRoom didBeginGameSession:currentRoom.gameSession];
}

// イベントドリブン式でマッチングを行います。
- (void)session:(GKSession *)session
		   peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)_state
{
	[session setDataReceiveHandler:self withContext:nil];
	NSString* peerData =[self.gksession displayNameForPeer:peerID];
	NSArray* peerArray = [peerData componentsSeparatedByString:@"\t"];
	NSString* name = [peerArray lastObject];
	
	PNCLog(PNLOG_CAT_SESSION, @"Opponent name is %@.",name);
	
	switch(_state) {
		case GKPeerStateAvailable:{ // not connected to session, but available for connectToPeer:withTimeout:
			PNCLog(PNLOG_CAT_SESSION, @"GKPeerStateAvailable:%@", peerData);
			PNLocalRoom* room;
			room				= [[[PNLocalRoom alloc] init] autorelease];
			room.roomId			= peerID;
			room.roomName		= [peerArray objectAtIndex:0];
			room.hostName		= [peerArray lastObject];
			room.gameKitSession = self;
			[rooms setObject:room forKey:peerID];
			
			NSArray * rs = [rooms allValues];
			if([roomManagerDelegate respondsToSelector:@selector(didFindActiveRooms:requestId:)])
				[roomManagerDelegate didFindActiveRooms:rs requestId:-1];
			
		}break;
		case GKPeerStateUnavailable:{ // no longer available
			PNCLog(PNLOG_CAT_SESSION, @"GKPeerStateUnavailable");
			
			int hostAvailable = self.isHost;
			
			for (NSString* i in [members allKeys]) {
				if ([[members objectForKey:i] isHost]) {
					hostAvailable = YES;
				}
			}
			
			if (!hostAvailable) {
				PNCLog(PNLOG_CAT_SESSION, @"Host is not found.");
			}
			
			PNNetworkError * e = [[[PNNetworkError alloc] init] autorelease];
			e.errorType = kPNPeerErrorDisconnected;
			e.message = @"Local room connection error";
			
			PNCLog(PNLOG_CAT_SESSION, @"roomManagerDelegate:%@", NSStringFromClass([roomManagerDelegate class]));
			
			if ( currentRoom.isJoined ) {
				if ([roomManagerDelegate respondsToSelector:@selector(room:didFailWithError:)]) {
					[roomManagerDelegate room:currentRoom didFailWithError:e];
				}
			} else {
				if ([roomManagerDelegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
					[roomManagerDelegate room:currentRoom didFailJoinWithError:e];
				}
			}
			
		}break;
		case GKPeerStateConnected:{ // connected to the session
			// Peerとの接続を確率できたので、すぐに入室処理に移る。
			PNCLog(PNLOG_CAT_SESSION, @"GKPeerStateConnected");
			if(!self.isHost) {
				PNLocalRoom* room	= [rooms objectForKey:peerID];
				room.roomId			= peerID;
				room.delegate		= roomDelegate;
				room.gameKitSession = self;
				
				//入室処理に進む
				[self sendJoinMessage:room];
			}
		}break;
		case GKPeerStateDisconnected:{ // disconnected from the session
			PNCLog(PNLOG_CAT_SESSION, @"GKPeerStateDisconnected");
			PNLocalRoom* room = self.currentRoom;
			PNPeer* peer = [members objectForKey:peerID];
			NSArray* sortedPeersList = [[members allValues] sortedArrayUsingSelector:@selector(compareAsc:)];
			
			if (peer) {
				if([room.gameSession.delegate respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
					[room.gameSession.delegate gameSession:room.gameSession didDisconnectPeer:peer];
				peer.isConnecting = NO;
				
				if(peer.isHost) {
					for(PNPeer* p in [members allValues]) {
						if([roomDelegate respondsToSelector:@selector(room:didLeaveUser:)])
							[roomDelegate room:currentRoom didLeaveUser:p.user];
					}
					if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
						[roomDelegate room:currentRoom didUpdateJoinedUsers:[NSArray array]];
					[members removeAllObjects];
					
					PNNetworkError* error = [PNNetworkError error];
					error.errorType = kPNPeerErrorDisconnected;
					error.message = @"Disconnected from host.";
					if([roomDelegate respondsToSelector:@selector(room:didFailJoinWithError:)])
						[roomDelegate room:currentRoom didFailJoinWithError:error];
				} else {
					
					//そのユーザーを削除する
					if([roomDelegate respondsToSelector:@selector(room:didLeaveUser:)])
						[roomDelegate room:currentRoom didLeaveUser:peer.user];
					if(peerID) [members removeObjectForKey:peerID];
					sortedPeersList = [[members allValues] sortedArrayUsingSelector:@selector(compareAsc:)];
					
					NSMutableArray* userArray = [NSMutableArray array];
					for(PNPeer* ePeer in sortedPeersList) {
						[userArray addObject:ePeer.user];
					}
					if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
						[roomDelegate room:currentRoom didUpdateJoinedUsers:userArray];
					
					if([members count] < currentRoom.minMemberNum) {
						currentRoom.isReady = NO;
						[self.gksession setAvailable:YES];
					}
				}
			}
			
			[self.gksession cancelConnectToPeer:peerID];
			
			//ホストの存在チェック
			int hostAvailable = self.isHost;
			
			for (NSString* i in [members allKeys]) {
				if ([[members objectForKey:i] isHost]) {
					hostAvailable = YES;
				}
			}
			
			if (!hostAvailable) {
				PNCLog(PNLOG_CAT_SESSION, @"Host is not found.");
				PNNetworkError * e = [[[PNNetworkError alloc] init] autorelease];
				e.errorType = kPNPeerErrorDisconnected;
				e.message = @"Local room connection error";
				if ( currentRoom.isJoined ) {
					if ([roomManagerDelegate respondsToSelector:@selector(room:didFailWithError:)]) {
						[roomManagerDelegate room:currentRoom didFailWithError:e];
					}
				} else {
					if ([roomManagerDelegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
						[roomManagerDelegate room:currentRoom didFailJoinWithError:e];
					}
				}
			}
			
		}break;
		case GKPeerStateConnecting:{ // waiting for accept, or deny response
			PNCLog(PNLOG_CAT_SESSION, @"GKPeerStateConnecting");
		}break;
		default:{
			PNCLog(PNLOG_CAT_SESSION, @"NONE");
		}break;
	}
	PNCLog(PNLOG_CAT_SESSION, @"didChangeState");
}


-(void)notifyStartingMessage
{
	if(isHost) {
		PNGKPacket* packet		= [PNGKPacket create];
		packet.command			= _PNGK_SESSION_PROTOCOL_INQUIRY_SYNC; // ゲーム開始のための同期を取る。
		packet.length			= 0;
		NSMutableArray* users	= [NSMutableArray array];
		NSMutableDictionary* params = [NSMutableDictionary dictionary];
		NSArray* sortedPeersList	= [[members allValues] sortedArrayUsingSelector:@selector(compareAsc:)];
		
		for(PNPeer* peer in sortedPeersList) {
			NSLog(@"JOINED NUMBER:%d:%@",peer.joinedNumber,peer.user.username);
			NSString* name			= peer.user.username;
			NSString* peerID		= peer.address;
			NSMutableDictionary* u	= [NSMutableDictionary dictionary];
			[u setObject:name	forKey:@"name"];
			[u setObject:peerID forKey:@"peer_id"];
			[users addObject:u];
		}
		[params setObject:users forKey:@"users"];
		PNCLog(PNLOG_CAT_SESSION, @"%@",params);
		[packet setSourceData:[JsonHelper toData:params]];
		[self sendToAllPackingDataByReliableMode:packet];
	}
}



- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	PNCLog(PNLOG_CAT_SESSION, @"GameKIT:receiveData");
	PNGKPacket* packet = [PNGKPacket create];
	[packet unpack:data];
	switch(packet.command) {
		case _PNGK_SESSION_PROTOCOL_DATA:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_DATA");
			PNCLog(PNLOG_CAT_SESSION, @"PN::%@",peer);
			PNPeer* p = [members objectForKey:peer];
			if(p) {
				if([delegate respondsToSelector:@selector(session:didReceiveWithData:from:)])
					[delegate session:self didReceiveWithData:[NSData dataWithBytes:packet.srcData length:packet.length] from:p];
			} else {
				PNCLog(PNLOG_CAT_SESSION, @"Unknown opponent packet.");
			}
		}break;
		case _PNGK_SESSION_PROTOCOL_REQUEST_JOIN:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_REQUEST_JOIN");
			// この通知を受け取ったら、リクエストしてきたユーザーを部屋に参加させる。
			NSDictionary* params = [packet convertToJSON];
			NSMutableDictionary* resParams = [NSMutableDictionary dictionary];
			
			packet.command = _PNGK_SESSION_PROTOCOL_RESPONSE_JOIN_OK;
			if(![members objectForKey:peer]) { //既に含まれている場合は無視する。
				PNPeer* p = [PNPeer createPeer];
				NSString* peerData =[self.gksession displayNameForPeer:peer];
				NSArray* peerArray = [peerData componentsSeparatedByString:@"\t"];
				p.user.username = [peerArray lastObject];
				p.address = peer;
				p.joinedNumber = joinCounter++;
				[self setParamToPeer:p srcParams:params];
				
				PNPeer* selfPeer = [PNPeer createPeerWithUser:[PNUser currentUser]];
				[self setPeerToParams:selfPeer dstParams:resParams];
				
				[members setObject:p forKey:peer];
				if([roomDelegate respondsToSelector:@selector(room:didJoinUser:)])
					[roomDelegate room:currentRoom didJoinUser:p.user];
				
				NSArray* sortedPeersList = [[members allValues] sortedArrayUsingSelector:@selector(compareAsc:)];
				
				NSMutableArray* userArray = [NSMutableArray array];
				for(PNPeer* ePeer in sortedPeersList) {
					[userArray addObject:ePeer.user];
				}
				if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
					[roomDelegate room:currentRoom didUpdateJoinedUsers:userArray];
				
				if(self.isHost)
					[resParams setObject:[NSNumber numberWithInt:1] forKey:@"is_host"];
				else
					[resParams setObject:[NSNumber numberWithInt:0] forKey:@"is_host"];
			}
			
			if(self.isHost) {
				if([members count] >= currentRoom.minMemberNum) {
					currentRoom.isReady = YES;
				}
				
				if([members count] == currentRoom.maxMemberNum) {
					[self.gksession setAvailable:NO];
					currentRoom.isReady = YES;
				}
			}
			
			// 参加が出来たことをPeerに通知。
			[packet setSourceData:[JsonHelper toData:resParams]];
			[self sendPackingDataByReliableMode:packet peer:peer];
		}break;
		case _PNGK_SESSION_PROTOCOL_RESPONSE_JOIN_OK:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_RESPONSE_JOIN_OK");
			// 相手の部屋に入室できた。
			NSDictionary* params = [packet convertToJSON];
			NSNumber* _is_host = [params objectForKey:@"is_host"];
			
			[timeoutTimer invalidate];
			timeoutTimer = nil;
			
			if(![members objectForKey:peer]) { //既に含まれている場合は無視する。
				PNPeer* p = [PNPeer createPeer];
				NSString* peerData =[self.gksession displayNameForPeer:peer];
				NSArray* peerArray = [peerData componentsSeparatedByString:@"\t"];
				p.user.username = [peerArray lastObject];
				p.address = peer;
				if ([_is_host intValue]) {
					PNCLog(PNLOG_CAT_SESSION, @"Set isHost YES to %@ (%@)", peer, [session displayNameForPeer:peer]);
					p.isHost = YES;
				}
				p.joinedNumber = [_is_host intValue] ? 0 : joinCounter++;
				[self setParamToPeer:p srcParams:params];
				
				[members setObject:p forKey:peer];
				if([roomDelegate respondsToSelector:@selector(room:didJoinUser:)])
					[roomDelegate room:currentRoom didJoinUser:p.user];
				
				NSArray* sortedPeersList = [[members allValues] sortedArrayUsingSelector:@selector(compareAsc:)];
				
				NSMutableArray* userArray = [NSMutableArray array];
				for(PNPeer* ePeer in sortedPeersList) {
					[userArray addObject:ePeer.user];
				}
				if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
					[roomDelegate room:currentRoom didUpdateJoinedUsers:userArray];
			}
		}break;
		case _PNGK_SESSION_PROTOCOL_INQUIRY_SYNC:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_INQUIRY_SYNC");
			// サーバーからゲーム開始用の同期処理を求められた時。
			if(self.isHost) {
				PNCLog(PNLOG_CAT_SESSION, @"Invalid request.");
			} else {
				NSDictionary* params = [packet convertToJSON];
				NSMutableDictionary* resParams = [NSMutableDictionary dictionary];
				
				NSArray* _users = [params objectForKey:@"users"];
				int counter = 1;
				for(NSDictionary* us in _users) {
					for(PNPeer* p in [members allValues]) {
						if([p.user.username isEqualToString:[us objectForKey:@"name"]]) {
							p.joinedNumber = counter++;
						}
					}
				}
				if([_users count] == [members count]) {
					packet.command = _PNGK_SESSION_PROTOCOL_SYNC_OK;
					[packet setSourceData:[JsonHelper toData:resParams]];
					[self sendPackingDataByReliableMode:packet peer:peer];
				} else {
					packet.command = _PNGK_SESSION_PROTOCOL_SYNC_NG;
					[packet setSourceData:[JsonHelper toData:resParams]];
					[self sendPackingDataByReliableMode:packet peer:peer];
				}
			}
		}break;
		case _PNGK_SESSION_PROTOCOL_SYNC_OK:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_SYNC_OK");
			if(self.isHost) {
				if(++checkCounter == [members count]-1) {
					// Publishを停止
					[self.gksession setAvailable:NO];
					// Timeout解除
					NSMutableDictionary* resParams = [NSMutableDictionary dictionary];
					packet.command = _PNGK_SESSION_PROTOCOL_START_MESSAGE;
					[packet setSourceData:[JsonHelper toData:resParams]];
					[self sendToAllPackingDataByReliableMode:packet]; // Broadcast.
					
					state = _PNGK_SESSION_STATE_STARTED;
					currentRoom.maxMemberNum = [members count];
					currentRoom.gameSession.room = currentRoom;
					currentRoom.gameSession.peers = members;
					
					int cnt = 0;
					for(PNPeer*p in [currentRoom.gameSession peerList]) {
						NSLog(@"%d:%@",cnt++,p.user.username);
					}
					
					currentRoom.isOwner = YES;
					currentRoom.gameSession.selfPeer = [members objectForKey:[NSString stringWithFormat:@"%d",_PNGK_SESSION_SELF_PEER_NUMBER]];
					currentRoom.gameSession.gameKitSession = self;
					for(PNPeer* peer in [self.currentRoom.gameSession.peers allValues]) {
						peer.isConnecting = YES;
					}
					[currentRoom.gameSession startGameSession:self sel:@selector(startGameSessionNotification)];
				}
			} else {
				PNCLog(PNLOG_CAT_SESSION, @"Invalid message at _PNGK_SESSION_PROTOCOL_SYNC_OK");
			}
		}break;
		case _PNGK_SESSION_PROTOCOL_SYNC_NG:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_SYNC_NG");
			if(self.isHost) {
				// NGを検出したらすぐ全員にFAILメッセージを飛ばす。
				NSMutableDictionary* resParams = [NSMutableDictionary dictionary];
				packet.command = _PNGK_SESSION_PROTOCOL_FAIL;
				[packet setSourceData:[JsonHelper toData:resParams]];
				[self sendToAllPackingDataByReliableMode:packet]; // Broadcast.
			} else {
				PNCLog(PNLOG_CAT_SESSION, @"Invalid message at _PNGK_SESSION_PROTOCOL_SYNC_NG");
			}
		}break;
		case _PNGK_SESSION_PROTOCOL_LEAVE:{
			if([members objectForKey:peer]) {
				PNPeer* p = [members objectForKey:peer];
				
				if(!p.isHost) {
					if([roomDelegate respondsToSelector:@selector(room:didLeaveUser:)])
						[roomDelegate room:currentRoom didLeaveUser:p.user];
					if(peer) [members removeObjectForKey:peer];
					NSArray* sortedPeersList = [[members allValues] sortedArrayUsingSelector:@selector(compareAsc:)];
					
					NSMutableArray* userArray = [NSMutableArray array];
					for(PNPeer* ePeer in sortedPeersList) {
						[userArray addObject:ePeer.user];
					}
					if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
						[roomDelegate room:currentRoom didUpdateJoinedUsers:userArray];
					
					
				} else {
					for(PNPeer* p in [members allValues]) {
						if([roomDelegate respondsToSelector:@selector(room:didLeaveUser:)])
							[roomDelegate room:currentRoom didLeaveUser:p.user];
					}
					if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
						[roomDelegate room:currentRoom didUpdateJoinedUsers:[NSArray array]];
					[members removeAllObjects];
					
					PNNetworkError* error = [PNNetworkError error];
					error.errorType = kPNPeerErrorDisconnected;
					error.message = @"Disconnected from host.";
					if([roomDelegate respondsToSelector:@selector(room:didFailJoinWithError:)])
						[roomDelegate room:currentRoom didFailJoinWithError:error];
				}
			}
			
			if([members count] < currentRoom.minMemberNum) {
				currentRoom.isReady = NO;
				[self.gksession setAvailable:YES];
			}
			
		}break;
		case _PNGK_SESSION_PROTOCOL_FAIL:{
			PNCLog(PNLOG_CAT_SESSION, @"Timeout or fail.");
			if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
				[roomDelegate room:currentRoom didUpdateJoinedUsers:[NSArray array]];
			[self stop];
		}break;
		case _PNGK_SESSION_PROTOCOL_START_MESSAGE:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_START_MESSAGE");
			state = _PNGK_SESSION_STATE_STARTED;
			// Publishを停止
			[self.gksession setAvailable:NO];
			PNRoom* room = currentRoom;
			room.isOwner = NO;
			room.maxMemberNum = [members count];
			room.gameSession.room = room;
			room.gameSession.peers = members;
			int cnt = 0;
			[room.gameSession peerList];
			for(PNPeer*p in [room.gameSession peerList]) {
				NSLog(@"%d:%@",cnt++,p.user.username);
			}
			
			room.gameSession.selfPeer = [members objectForKey:[NSString stringWithFormat:@"%d",_PNGK_SESSION_SELF_PEER_NUMBER]];;
			room.gameSession.gameKitSession = self;
			for(PNPeer* peer in [self.currentRoom.gameSession.peers allValues]) {
				peer.isConnecting = YES;
			}
			[room.gameSession startGameSession:self sel:@selector(startGameSessionNotification)];
		}break;
		case _PNGK_SESSION_PROTOCOL_ECHO:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_ECHO");
		}break;
		case _PNGK_SESSION_PROTOCOL_PING:{
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_PING");
			packet.command = _PNGK_SESSION_PROTOCOL_PONG;
			[packet setSourceData:[NSData dataWithBytes:"{}" length:2]];
			
			int dataLen = [packet pack];
			[self send:[NSData dataWithBytes:packet.dstData length:dataLen]
				  peer:peer
				  mode:kPNGameSessionUnreliable];
		}break;
		case _PNGK_SESSION_PROTOCOL_PONG:{
			PNGameSession* gameSession = currentRoom.gameSession;
			PNPeer* p = [gameSession.peers objectForKey:peer];
			PNCLog(PNLOG_CAT_SESSION, @"_PNGK_SESSION_PROTOCOL_PONG %@",p.user.username);
			if(p) p.packetTimeStamp = CFAbsoluteTimeGetCurrent();
			
		}break;
		case _PNGK_SESSION_PROTOCOL_FIN:{
			PNLocalRoom* room = self.currentRoom;
			PNGameSession* gameSession = room.gameSession;
			PNPeer* p = [gameSession.peers objectForKey:peer];
			if(p && p.isConnecting) {
				if([gameSession.delegate respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
					[gameSession.delegate gameSession:gameSession didDisconnectPeer:p];
				p.isConnecting = NO;
			}
		}break;
	}
	PNCLog(PNLOG_CAT_SESSION, @"receiveData : %s",(char*)data.bytes);
}



- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	[session acceptConnectionFromPeer:peerID error:nil];
	PNCLog(PNLOG_CAT_SESSION, @"didReceiveConnectionRequestFromPeer");
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	PNCLog(PNLOG_CAT_SESSION, @"connectionWithPeerFailed");
	
	PNCLog(PNLOG_CAT_SESSION, @"%p %@", roomManagerDelegate, [roomManagerDelegate class]);
	
	PNNetworkError * e = [[[PNNetworkError alloc] init] autorelease];
	e.errorType = kPNPeerErrorDisconnected;
	e.message = @"Local room connection error";
	
	if ( currentRoom.isJoined ) {
		if ([roomManagerDelegate respondsToSelector:@selector(room:didFailWithError:)]) {
			[roomManagerDelegate room:currentRoom didFailWithError:e];
		}
	} else {
		if(self.gksession) {
			[self.gksession disconnectFromAllPeers];
			self.gksession.available = NO;
			[self.gksession setDataReceiveHandler:nil withContext:nil];
			self.gksession.delegate = nil;
			self.gksession = nil;
		}
		if ([roomManagerDelegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
			[roomManagerDelegate room:currentRoom didFailJoinWithError:e];
		}
	}
}

- (void)receiveTimeout {
	PNCLog(PNLOG_CAT_SESSION, @"Receive Timeout");
	timeoutTimer = nil;
	
	if ( currentRoom.isJoined ) {
		PNCLog(PNLOG_CAT_SESSION, @"Already joined. Timeout action skip.");
		return;
	}
	
	if ([roomManagerDelegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
		PNNetworkError * e = [[[PNNetworkError alloc] init] autorelease];
		e.errorType = kPNPeerErrorDisconnected;
		e.message = @"Local room connection timeouted.";
		[roomManagerDelegate room:currentRoom didFailJoinWithError:e];
	}
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	PNCLog(PNLOG_CAT_SESSION, @"didFailWithError");
}

@end



static int pack(PNGKPacket *packet)
{
	int command = packet.command;
	int length = packet.length;
	int size = 0;
	size += sizeof(command);
	size += sizeof(length);
	size += length;
	unsigned char* data = (unsigned char*)malloc(size);
	unsigned char* p = data;
	memcpy(p,&command,sizeof(command));
	p += sizeof(command);
	memcpy(p,&length,sizeof(length));
	p += sizeof(length);
	memcpy(p,packet.srcData,length);
	if(packet.dstData) free(packet.dstData);
	packet.dstData = data;
	return size;
}

static int unpack(PNGKPacket* packet,unsigned char* data,int len)
{
	int command;
	int length;
	memcpy(&command,data,sizeof(command));
	data += sizeof(command);
	memcpy(&length,data,sizeof(length));
	data += sizeof(length);
	if(packet.srcData) free(packet.srcData);
	packet.srcData = (unsigned char*)malloc(length);
	packet.command = command;
	packet.length = length;
	memcpy(packet.srcData,data,length);
	
	return 1;
}

static int GetConnectionMode(int mode)
{
	switch(mode) {
		case kPNGameSessionReliable:
			return GKSendDataReliable;
		case kPNGameSessionUnreliable:
			return GKSendDataUnreliable;
	}
	return GKSendDataReliable;
}
