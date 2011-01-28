#import "PNLogger+Package.h"
#import "PNError.h"
#import "PNNetworkError.h"
#import "PNManager.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNHTTPRequestHelper.h"
#import "PNUDPConnectionService.h"
#import "PNNetworkUtil.h"
#import "PNRoomManager.h"
#import "PNInvitationRequestHelper.h"
#import "PNMembershipModel.h"
#import "PNRoomModel.h"
#import "PNRoomRequestHelper.h"

#import "PNICMPManager.h"
#import "PNICMPRequest.h"
#import "PNPacket.h"

#import "NSObject+PostEvent.h"
#import "IPAddress.h"
#import "JsonHelper.h"

#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "PNGameSession.h"
#import "PNGameSession+Package.h"

#import "PNLogger+Package.h"
#import "PNGlobal.h"
#import "PNAPIHTTPDefinition.h"


#include <arpa/inet.h>
#include <netinet/in.h>
#include <time.h>
#include <sys/time.h>

extern NSNumber *inetToLongLong(const char* host,int port);

@interface PNRoom(Private)
- (void)startPairingWithPeers:(NSArray*)peers;
@end

@implementation PNRoom(Package)

@dynamic roomName;
@dynamic roomMembers;

-(void)setRoomName:(NSString *)arg { PNSETPROP(roomName,arg); }
-(void)setRoomMembers:(NSMutableArray *)arg { PNSETPROP(roomMembers,arg); }

-(NSString*)roomName { PNGETPROP(NSString*,roomName); }
-(NSMutableArray*)roomMembers { PNGETPROP(NSMutableArray*,roomMembers); }


@dynamic delegate;
@dynamic roomManager;
@dynamic roomId;
@dynamic isPublished;
@dynamic isInGame;
@dynamic maxMemberNum;
@dynamic minMemberNum;
@dynamic hostName;
@dynamic gameSession;
@dynamic peers;
@dynamic pairingCounter;
@dynamic pairingTable;
@dynamic isRequestingJoining;
@dynamic joinCount;
@dynamic heartbeatLastTimeStamp;
@dynamic speedLevel;
@dynamic isJoined;
@dynamic isLocked;
@dynamic isOwner;
@dynamic isHeartBeatNecessary;
@dynamic isDisconnectDetectionNecessary;

-(void)setDelegate:(id<PNRoomDelegate>)arg { PNSETPROP(delegate,arg); }
-(void)setRoomId:(NSString*)arg { PNSETPROP(roomId,arg); }
-(void)setHostName:(NSString*)arg { PNSETPROP(hostName,arg); }
-(void)setGameSession:(PNGameSession*)arg { PNSETPROP(gameSession,arg); }
-(void)setPeers:(NSMutableDictionary*)arg { PNSETPROP(peers,arg); }
-(void)setRoomManager:(PNRoomManager*)arg { PNSETPROP(roomManager,arg); }
-(void)setPairingTable:(NSMutableDictionary*)arg { PNSETPROP(pairingTable,arg); }
-(void)setSpeedLevel:(PNConnectionLevel)arg { PNPSETPROP(speedLevel,arg); }
-(void)setMaxMemberNum:(int)arg { PNPSETPROP(maxMemberNum,arg); }
-(void)setMinMemberNum:(int)arg { PNPSETPROP(minMemberNum,arg); }
-(void)setPairingCounter:(int)arg { PNPSETPROP(pairingCounter,arg); }
-(void)setJoinCount:(int)arg { PNPSETPROP(joinCount,arg); }
-(void)setHeartbeatLastTimeStamp:(double)arg { PNPSETPROP(heartbeatLastTimeStamp,arg); }
-(void)setIsLocked:(BOOL)arg { PNPSETPROP(isLocked,arg); }
-(void)setIsJoined:(BOOL)arg { PNPSETPROP(isJoined,arg); }
-(void)setIsRequestingJoining:(BOOL)arg { PNPSETPROP(isRequestingJoining,arg); }
-(void)setIsHeartBeatNecessary:(BOOL)arg { PNPSETPROP(isHeartBeatNecessary,arg); }
-(void)setIsOwner:(BOOL)arg { PNPSETPROP(isOwner,arg); }
-(void)setIsDisconnectDetectionNecessary:(BOOL)arg { PNPSETPROP(isDisconnectDetectionNecessary,arg); }

-(id<PNRoomDelegate>)delegate { PNGETPROP(id<PNRoomDelegate>,delegate); }
-(NSString*)roomId { PNGETPROP(NSString*,roomId); }
-(NSString*)hostName { PNGETPROP(NSString*,hostName); }
-(PNGameSession*)gameSession { PNGETPROP(PNGameSession*,gameSession); }
-(NSMutableDictionary*)peers { PNGETPROP(NSMutableDictionary*,peers); }
-(PNRoomManager*)roomManager { PNGETPROP(PNRoomManager*,roomManager); }
-(NSMutableDictionary*)pairingTable { PNGETPROP(NSMutableDictionary*,pairingTable); }
-(PNConnectionLevel)speedLevel { PNGETPROP(PNConnectionLevel,speedLevel); }
-(int)maxMemberNum { PNGETPROP(int,maxMemberNum); }
-(int)minMemberNum { PNGETPROP(int,minMemberNum); }
-(int)pairingCounter { PNGETPROP(int,pairingCounter); }
-(int)joinCount { PNGETPROP(int,joinCount); }
-(double)heartbeatLastTimeStamp { PNGETPROP(double,heartbeatLastTimeStamp); }
-(BOOL)isLocked { PNGETPROP(BOOL,isLocked); }
-(BOOL)isJoined { PNGETPROP(BOOL,isJoined); }
-(BOOL)isRequestingJoining { PNGETPROP(BOOL,isRequestingJoining); }
-(BOOL)isHeartBeatNecessary { PNGETPROP(BOOL,isHeartBeatNecessary); }
-(BOOL)isOwner { PNGETPROP(BOOL,isOwner); }
-(BOOL)isDisconnectDetectionNecessary { PNGETPROP(BOOL,isDisconnectDetectionNecessary ); }


-(void)setIsPublished:(BOOL)arg { PNPSETPROP(isPublished,arg); }
-(void)setIsInGame:(BOOL)arg { PNPSETPROP(isInGame,arg); }
-(BOOL)isPublished { PNGETPROP(BOOL,isPublished); }
-(BOOL)isInGame { PNGETPROP(BOOL,isInGame); }

-(void) addMembership:(PNMembershipModel*)aMembershipModel
{
	PNUser* user;
	PNPeer* peer;
	user = [PNUser user];
	peer = [PNPeer createPeerWithUser:user];
	[user updateFieldsFromUserModel:aMembershipModel.user];
	peer.address = aMembershipModel.ip;
	[self.roomMembers addObject:peer];
}

-(void) setRoomModel:(PNRoomModel*)aModel
{
	self.roomId				= aModel.id;
	self.roomName			= aModel.name;
	self.maxMemberNum			= aModel.max_members;
	self.isPublished		= aModel.is_public;
	self.isLocked			= aModel.is_locked;
	for(PNMembershipModel* membershipModel in aModel.memberships)
		[self addMembership:membershipModel];
	
	PNPeer* peer = [self.roomMembers count] ? [self.roomMembers objectAtIndex:0] : nil;
	self.hostName = peer != nil ? peer.user.username : @"";
}


-(void) leaveResponse:(PNHTTPResponse*)response
{
	NSString*		resp = [response jsonString];
	
	PNLog(@"leaveResponse: Members response \n%@",resp);
	
	if(response.isValidAndSuccessful) {
		if ([delegate respondsToSelector:@selector(room:didLeaveUser:)])
			[delegate room:self didLeaveUser:self.gameSession.selfPeer.user];
		if ([delegate respondsToSelector:@selector(didLeaveRoom:)])
			[delegate didLeaveRoom:self];
	} else {
		// Nothing todo
	}
}

-(BOOL)isGameRestarting
{
	return startCounter?YES:NO;
}

- (void)cancelJoining
{
	cancelJoiningFlag = YES;
}

-(void)join
{
	
}
- (void)startPairingWithPeers:(NSArray*)roomPeers
{
	
}
/*
-(void)stunService:(PNUDPConnectionService*)service didError:(PNNetworkError*)error
{
	NSString* errorMessage = [NSString stringWithFormat:@"Stun service error: %@", error.message];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@", errorMessage);
	PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, errorMessage);
	
	if (self.isRequestingJoining == YES){	//入室処理中におこったエラーであれば通知し退室します
		PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Error while requesting joining");
		[self leave];
		
		// JOINに失敗したことを通知します。
		if([delegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
			[delegate room:self didFailJoinWithError:error];
		}
	}
	
}

-(void)stunService:(PNUDPConnectionService*)service didReport:(NSString*)report
{
	if (delegate != nil && [delegate respondsToSelector:@selector(room:didReport:)]){
		[delegate room:self didReport:report];
	}
}

-(void)stunService:(PNUDPConnectionService*)service willStartPairing:(PNPeer*)peer
{
	if (delegate != nil && [delegate respondsToSelector:@selector(room:willStartPairing:)]){
		[delegate room:self willStartPairing:peer];
	}
}

-(void)stunService:(PNUDPConnectionService*)service didDonePairing:(PNPeer*)peer
{
	PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Pairing done.");
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@ とのペアリングに成功しました。", peer.user.username);
	
	if(peer.rtt <= service.connectionPermissibleRangeSpeed) {
		self.pairingCounter++;
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"現在、ルームメンバー %d 人中 %d 人とペアリングが完了しています。",[self.roomMembers count], self.pairingCounter);
		
		// すべてのユーザーとペアリングが終了していれば、JOINする。
		if(self.isJoined == NO && [self.roomMembers count] == self.pairingCounter) {
			// PNRoomManagerのTCP経由でゲームスタート
			[self performSelector:@selector(lazyJoin) withObject:nil afterDelay:1];
		}
	} else {
		PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
		e.message = @"Permissible range RTT speed is over.";
		e.errorType = kPNStunPunchingRTTOverrange;
		
		NSString* errorMessage = [NSString stringWithFormat:@"Stun service error: %@", e.message];
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@", errorMessage);
		PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, errorMessage);
		
		if (self.isRequestingJoining == YES){	//入室処理中におこったエラーであれば通知し退室します
			PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Error while requesting joining");
			[self leave];
			
			// JOINに失敗したことを通知します。
			if([delegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
				[delegate room:self didFailJoinWithError:e];
			}
		}
	}
}
*/
-(void)lazyJoin
{
	if(cancelJoiningFlag == YES){
		cancelJoiningFlag = NO;
		return;
	}
	
	NSString* session;
	NSString* rid;
	session	= [PNUser session];
	rid		= self.roomId;
	gameSession.selfPeer = [PNUDPConnectionService sharedObject].selfPeer;	//ここは必要ないかも? 横江
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"部屋への入室をサーバーに申請します...");
	[PNRoomRequestHelper join:session room:rid delegate:self selector:@selector(joinResponse:) requestKey:@"PNMemberShipJoin"];
}



-(void)CALLBACK_SendPacketOnUDPThread:(NSData*)data socket:(AsyncUdpSocket*)aUDPSocket peer:(PNPeer*)aPeer
{
	[aUDPSocket sendData:data toHost:aPeer.address port:(UInt16)aPeer.udpPort withTimeout:2.0 tag:kPNStunUDPConnectionTagPacket ttl:64];
}

// NATテーブルを維持する目的と相手との切断検知のためにハートビートを打ち続ける。
-(void)heartbeatForP2PNATTable:(AsyncUdpSocket*)aUDPSocket
{	
	NSArray* ps = [self.peers allValues];
	if(!self.isHeartBeatNecessary)
		return;
	const double HEARTBEAT_DELAY = 1.0f;
	
	double lasttime = self.heartbeatLastTimeStamp;
	double now = CFAbsoluteTimeGetCurrent();
	
	if(lasttime == -1 || now - lasttime >= HEARTBEAT_DELAY) {
		BOOL isExistOpponent = NO;
		
		for(PNPeer* aPeer in ps) {
			if([PNUDPConnectionService sharedObject].selfPeer == aPeer || !aPeer.isConnecting)
				continue;
			
			aPeer.packetTimeStamp = aPeer.packetTimeStamp == -1 ? now : aPeer.packetTimeStamp;
			
			
			if(!self.isDisconnectDetectionNecessary)
				aPeer.packetTimeStamp = now;
			
			if(now - aPeer.packetTimeStamp > kPNHeartbeatTimeoutValue)
			{
				if(aPeer.isConnecting)
					if([self.gameSession.delegate respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
						[self.gameSession.delegate gameSession:self.gameSession didDisconnectPeer:aPeer];
				aPeer.isConnecting = NO;
				[PNPacketFireWall removeIPv4:aPeer.address port:aPeer.udpPort];
				continue;
			}
			
			NSData* data	= [NSData dataWithBytes:"{}" length:2];
			int con			= kPNGameSessionUnreliable;
			int type		= kPNPacketFlagHeatbeat;
			int command		= kPNPacketFlagCommandSystem;
			int method		= kPNPacketFlagMethodPing;
			int theFlag		= con|type|command|method;
			
			PNPacket* packet	= [PNPacket create];
			double time			= CFAbsoluteTimeGetCurrent();
			packet.data			= data;
			packet.theFlag		= theFlag;
			packet.timestamp	= time;
			packet.address		= aPeer.address;
			packet.port			= aPeer.udpPort;
			
			[packet pack];
			
			PNCLog(PNLOG_CAT_HEARTBEAT, @"HEART BEAT");
			
			[self performSelectorOnConnectionThread:@selector(CALLBACK_SendPacketOnUDPThread:socket:peer:)
										withObjects:[NSArray arrayWithObjects:packet.packedData,aUDPSocket,aPeer,nil]];
			
			isExistOpponent = YES;
		}
		self.heartbeatLastTimeStamp = CFAbsoluteTimeGetCurrent();
		
		[self performSelector:@selector(heartbeatForP2PNATTable:)
				  withObjects:[NSArray arrayWithObjects:aUDPSocket,nil]
				   afterDelay:HEARTBEAT_DELAY+0.1];
		if(!isExistOpponent)
			self.isHeartBeatNecessary = NO;
		
	}
}

-(BOOL)verify
{
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Verifying current room...");
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Peers in pairing table are...");
	for(PNPeer* peer in [self.pairingTable allValues]){
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @" %@ (SessionId:%@, IP:%@)", peer.user.username, peer.user.publicSessionId, peer.address);
	}
	
	//部屋の人数とPeerの数が一致しているか確認します。
	//pairingTableには自分が含まれないので、
	//roomMemberの数 - 1 = pairingTableのpeerの数
	//となります。
	//もし今後部屋の人数に達しなくてもゲームを開始できる仕様になった場合
	//この部分のチェックも変更してください。
	if ([self.roomMembers count] - 1 != [self.pairingTable count]){
		PNWarn(@"Room members count - 1 (%d) doesn't match up to peers in pairing table (%d).", [roomMembers count] - 1, [self.pairingTable count]);
	}
	
	//PacketFireWallの状況をチェックする
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"PacketFireWall status are");
	NSDictionary* ipTable = [PNPacketFireWall getDynamicIptables];
	for (NSString* ipAddress in [ipTable allKeys]){
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @" %@", ipAddress);
	}
	
	//すべてのpeerのホストがPacketFireWallのテーブルに含まれているかチェックします
	for(PNPeer* peer in [self.pairingTable allValues]){
		if ([ipTable objectForKey:peer.address] == nil){
			PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Warning! %@ is not in allowed hosts.");
		}
	}
	
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Verifying current room OK.");
	return YES;
}

-(void)joinResponse:(PNHTTPResponse*)response
{
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Get a response for the join request");
	if(response.isValidAndSuccessful) {
		PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"joinResponse:Success");
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Join is correct!");
		self.isJoined = YES;
		NSArray *memberships = [json objectForKey:J_MEMBERSHIPS];
		NSArray *membershipModels = [PNMembershipModel dataModelsFromArray:memberships];
		
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Joined member count: %d", [membershipModels count]);
		for(PNMembershipModel *membershipModel in membershipModels) {
			PNCLog(PNLOG_CAT_INTERNET_MATCH,@"- %@ (SessionID: %@ )", membershipModel.user.username , membershipModel.id );
		}
		
		AsyncUdpSocket* socket = [PNUDPConnectionService sharedObject].udpSocket;
		for(PNPeer* peer in [self.pairingTable allValues])
			peer.isConnecting = YES;
		self.isHeartBeatNecessary = YES;
		
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Now Pairing..");
		for(PNPeer* peer in [self.pairingTable allValues]){
			PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@ (Sess.ID: %@)", peer.user.username, peer.user.publicSessionId);
		}
		
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Start heart beat.");
		[self heartbeatForP2PNATTable:socket];
		
	} else {
		PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"joinResponse:NG");
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Error:Join failed. Reason:%@", [[resp JSONValue] objectForKey:J_CODE]);
		self.isJoined = NO;
		[PNUDPConnectionService deletePairingTable:[self.pairingTable allValues]];
		[PNPacketFireWall clear];
		[self.pairingTable removeAllObjects];
		
		if(json) {
			NSString* errorCode = [json objectForKey:J_CODE];
			PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Error code is \"%@\"",errorCode);
			if([errorCode isEqualToString:@"not_allowed"]) {
				PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Join is not allowed. will retry...");
				//				[self join];
				//TODO: Retry join.
			}
		} else {
			PNLog(@"HTTP request failed at membership/join.");
		}
	}
}

-(void)destroyResponse:(PNHTTPResponse*)response
{
	PNLog(@"destroyResponse");
	PNLog(@"Recv : \n HTTP > %@", [response jsonString]);
}

- (void)synchronousLeave
{
	NSString* session = [PNUser session];
	NSString* room    = self.roomId;
	
	[PNHTTPRequestHelper synchronousRequestWithCommand:kPNHTTPRequestCommandRoomLeave
											parameters:[NSDictionary dictionaryWithObjectsAndKeys:
														session,		@"session",
														room,			@"room",
														nil]];
}

-(void)leave
{
	self.isJoined = NO;
	if(self.gameSession.isAlive) {
		[self.gameSession endGameSession];
	}
	
	NSString* session = [PNUser session];
	[PNRoomRequestHelper leave:session
						  room:self.roomId
					  delegate:self
					  selector:@selector(leaveResponse:)
					requestKey:@"PNRoomLeave"];
	
	self.isHeartBeatNecessary = NO;
	
	
	[PNUDPConnectionService deletePairingTable:[self.pairingTable allValues]];
	[self.pairingTable removeAllObjects];	
	[PNPacketFireWall clear];
}

-(void) lock
{
	NSString* session = [PNUser session];
	
	[PNRoomRequestHelper lock:session
						 room:self.roomId
					 delegate:self
					 selector:@selector(lockResponse:)
				   requestKey:@"PNRoomLock"];
}

-(void)lockResponse:(PNHTTPResponse*)response
{
}

-(void) unlock
{
	NSString* session = [PNUser session];
	
	[PNRoomRequestHelper unlock:session
						   room:self.roomId
					   delegate:self
					   selector:@selector(unlockResponse:)
					 requestKey:@"PNRoomUnlock"];
}

-(void)unlockResponse:(PNHTTPResponse*)response
{
	NSString*		resp = [response jsonString];
	PNLog(@"Unlock:%@",resp);
}

-(void)CALLBACK_LazyStart
{
	if(startCounter++) {
		if([delegate respondsToSelector:@selector(room:didRestartGameSession:)])
			[delegate room:self didRestartGameSession:self.gameSession];
	} else {
		if([delegate respondsToSelector:@selector(room:didBeginGameSession:)])
			[delegate room:self didBeginGameSession:self.gameSession];
	}
}

-(void)callbackdidBeginGameSessionMethod
{
	[self performSelector:@selector(CALLBACK_LazyStart) withObject:nil afterDelay:1.0];
}

-(void)startGame
{
	// LocalMatchであればNTP用のプロトコルシーケンスへ。
	// InternetMatchであればNTP用のプロトコルシーケンスはないので、そのままゲームをスタートさせる。
	[self.gameSession startGameSession:self sel:@selector(callbackdidBeginGameSessionMethod)];
}

-(void)roundTripTimeMeasurement:(NSArray*)members
{
	for(n_short i = 0; i<[members count]; i++) {
		PNPeer* p = [members objectAtIndex:i];
		PNICMPRequest* req = [[[PNICMPRequest alloc] init] autorelease];
		req.address = p.address;
		req.sequence = 0;
		req.icmpCode = 0;
		req.icmpType = ICMP_ECHO;
		req.context = p;
		req.identifier = i | roomIdentifier;
		PNCLog(PNLOG_CAT_ICMP, @"Identifier:%04x", req.identifier);
		[[PNICMPManager sharedObject] sendRequest:req];
	}
}

-(int) connectionLevel
{
	return speedLevel;
}

- (void) didReceiveICMPResponse: (NSNotification *)aNotification
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	NSData* aData = [[aNotification userInfo] objectForKey:@"ICMP"];
	struct icmp aICMP;
	[aData getBytes:&aICMP];
	if ((aICMP.icmp_id & 0xFFF0) == roomIdentifier) {
		PNCLog(PNLOG_CAT_ICMP, @"ICMP Received!");
		PNCLog(PNLOG_CAT_ICMP, @"Identifier:%04x, Chksum:%04x, Room Identifier:%04x", aICMP.icmp_id, aICMP.icmp_cksum, roomIdentifier);
		NSDictionary* timeDic = [icmpTimes objectForKey:[NSString stringWithFormat:@"%04x", aICMP.icmp_id]];
		struct timeval stv;
		[[timeDic objectForKey:@"TimeValue"] getBytes:&stv];
		PNCLog(PNLOG_CAT_ICMP, @"%ld.%06ld - %ld.%06ld", stv.tv_sec, stv.tv_usec, tv.tv_sec, tv.tv_usec);
		long longSpeed = (tv.tv_sec - stv.tv_sec) * 1000 * 1000 + (tv.tv_usec - stv.tv_usec);
		int intSpeed = longSpeed / 1000;
		PNCLog(PNLOG_CAT_ICMP, @"%d msec.", intSpeed);
		PNPeer* p = [[timeDic objectForKey:@"Request"] context];
		p.icmpRtt = intSpeed;
		
		PNCLog(PNLOG_CAT_ICMP, @"ICMP Peer ID:%x", (aICMP.icmp_id) & 0x000F);
		
		if (((aICMP.icmp_id) & 0x000F) == 0x0000) {
			PNCLog(PNLOG_CAT_ICMP, @"Set my speedLevel");
			speedLevel = getConnectionLevel(intSpeed);
		}
		
		if ([delegate respondsToSelector:@selector(room:finishGetSpeedLevelForPeer:)]) {
			[delegate room:self finishGetSpeedLevelForPeer:p];
		}
	}
}

- (void) finishSendICMPRequest: (NSNotification *)aNotification {
	
	NSDictionary* userInfo = [aNotification userInfo];
	if (((int)([[userInfo objectForKey:@"Request"] identifier]) & 0xFFF0) != roomIdentifier) {
		return;
	}
	
	struct timeval tv;
	gettimeofday(&tv, NULL);
	NSData* v = [NSData dataWithBytes:&tv length:sizeof(tv)];
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:2];
	PNICMPRequest* req = [userInfo objectForKey:@"Request"];
	[dict setObject:req forKey:@"Request"];
	[dict setObject:v forKey:@"TimeValue"];
	[icmpTimes setObject:dict forKey:[NSString stringWithFormat:@"%04x", req.identifier]];
	
	PNCLog(PNLOG_CAT_ICMP, @"Finish Send ICMP:%04x", [req identifier]);
}

-(void)terminate
{
	if(self.gameSession.isStarted) {
		[self.gameSession disconnect];
	}
	if (isJoined) {
		[self synchronousLeave];
	}
}

- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNLog(@"[ERROR]PNInternetRoom - %@ %08x",error.message,error.errorType);
	
}

- (void)addPeer:(PNPeer*)aPeer
{
	if (!inetToLongLong([aPeer.address UTF8String], aPeer.udpPort)) {
		PNWarn(@"Error. Peer address is nil! ip: %@", [aPeer.address UTF8String]);
		return;
	}
	
	aPeer.joinedNumber = self.joinCount++;
	[self.peers setObject:aPeer forKey:inetToLongLong([aPeer.address UTF8String], aPeer.udpPort)];
	
	// 2010.12.10追加 ルームメンバーの同期用
	BOOL hasPeerInRoomMembers = NO;
	for (PNPeer* roomMember in self.roomMembers) {
		if ([roomMember.user.username isEqualToString:aPeer.user.username]) {
			hasPeerInRoomMembers = YES;
			break;
		}
	}
	if (!hasPeerInRoomMembers) {
		[self.roomMembers addObject:aPeer];
	}
}

- (void)removePeer:(PNPeer*)aPeer
{
	if ([self.roomMembers containsObject:aPeer]) {
		[self.roomMembers removeObject:aPeer];
	}
	
	[self.peers removeObjectForKey:inetToLongLong([aPeer.address UTF8String], aPeer.udpPort)];
}

+ (NSArray*)availableRoomsFromModels:(NSArray*)dataModels
{
	NSMutableArray* models = [NSMutableArray array];
	for (PNRoomModel* roomModel in dataModels) {
		if (roomModel.is_locked == NO && [roomModel.memberships count] < roomModel.max_members) {
			[models addObject:[self modelFromDataModel:roomModel]];
		}
	}
	return models;
}

@end

@implementation PNRoom
@dynamic roomName;
@dynamic roomMembers;
@synthesize lobby;

- (id)initWithDataModel:(PNRoomModel *)dataModel
{
	if (self = [super initWithDataModel:dataModel]) {
		self.roomId				= dataModel.id;
		self.roomName			= dataModel.name;
		self.maxMemberNum		= dataModel.max_members;
		self.isPublished		= dataModel.is_public;
		self.isLocked			= dataModel.is_locked;
		for(PNMembershipModel* membershipModel in dataModel.memberships)
			[self addMembership:membershipModel];
		
		PNPeer* peer = [self.roomMembers count] ? [self.roomMembers objectAtIndex:0] : nil;
		self.hostName = peer != nil ? peer.user.username : @"";
	}
	return self;
}

- (id) init {
	if (self = [super init]) {
		startCounter		= 0;
		self.gameSession	= [[[PNGameSession alloc] init] autorelease];
		self.isInGame		= NO;
		self.isPublished	= YES;
		self.isOwner		= NO;
		self.roomId			= nil;
		self.hostName		= nil;
		self.roomName		= nil;
		self.peers			= [NSMutableDictionary dictionary];
		self.roomManager    = [PNManager roomManager];
		self.roomMembers	= [NSMutableArray array];
		self.pairingTable	= [NSMutableDictionary dictionary];
		self.isJoined		= NO;
		self.isRequestingJoining = NO;
		self.joinCount		= 0;
		self.isLocked		= NO;
		self.speedLevel		= kPNConnectionLevelUnmeasurement;
		pairingCounter		= 0;
		self.isDisconnectDetectionNecessary = YES;
		self.gameSession.gameSessionType = PNInternetSession;
		self.maxMemberNum = 2;
		self.minMemberNum = 2;
		self.lobby = nil;
		
		
		/* RTT計測用設定 */
		PNICMPManager* icmpManager = [PNICMPManager sharedObject];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveICMPResponse:) name:@"ICMPManagerDidGetResponse" object:icmpManager];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishSendICMPRequest:) name:@"ICMPManagerFinishSendRequest" object:icmpManager];
		icmpTimes = [[NSMutableDictionary alloc] init];
		
		roomIdentifier = (unsigned short)(rand() & 0x0FFF);
		roomIdentifier = roomIdentifier << 4;
		PNCLog(NO, @"RoomIdentifier:%04x", roomIdentifier);
		
	}
	return  self;
}

-(void)dealloc
{
	self.gameSession	= nil;
	self.peers			= nil;
	self.roomManager    = nil;
	self.roomMembers	= nil;
	self.roomId			= nil;
	self.hostName		= nil;
	self.roomName		= nil;
	self.pairingTable	= nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	PNSafeDelete(icmpTimes);
	
	[super dealloc];
}
@end
