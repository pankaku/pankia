#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNLocalRoom.h"
#import <arpa/inet.h>
#import <netinet/in.h>

#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNNetworkError.h"
#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNHTTPRequestHelper.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "PNUDPConnectionService.h"
#import "PNNetworkUtil.h"
#import "PNRoomManager.h"
#import "PNManager.h"
#import "PNGKSession.h"
#import "NSObject+PostEvent.h"
#import "JsonHelper.h"
#import "PNGlobal.h"
#import "PNLogger+Package.h"
#import "PNGlobalManager.h"
#import "PNGameManager.h"

@implementation PNLocalRoom

@synthesize gameKitSession;
@synthesize isReady;

- (id) init {
	if (self = [super init]) {
		self.isReady = NO;
		self.gameKitSession  = nil;
		self.gameSession.gameSessionType = PNNearbySession;
	}
	return  self;
}

-(void)error:(NSError*)message errorType:(int)type
{
	PNLog(@"ERROR:%@ \tERROR TYPE:%d",message,type);
	switch(type) {
		case 0:
			break;
		default:
			break;
	}
}

-(void)clear
{
	if(gameSession) {
		[gameSession endGameSession];
		self.gameSession = nil;
	}
	
	for(PNPeer *p in [peers allValues]) {
		if([delegate respondsToSelector:@selector(room:didLeaveUser:)])
			[delegate room:self didLeaveUser:p.user];
	}
	
	[peers removeAllObjects];
	PNLog(@"-------------------remove------------------");
	if(selfPeer) {
		[selfPeer release];
		selfPeer = nil;
	}
	
	
	
	NSMutableArray* userArray = [NSMutableArray array];
	for(PNPeer* ePeer in [peers allValues]) {
		[userArray addObject:ePeer.user];
	}
	if([self.delegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
		[self.delegate room:self didUpdateJoinedUsers:userArray];
}

-(void)startNotifying
{
	[self.gameKitSession notifyStartingMessage];
}


-(void) startService
{
	self.gameKitSession.currentRoom = self;
	self.gameKitSession.delegate = (id<PNGKSessionDelegate>)self.gameSession;
	[self.gameKitSession start:YES gameKey:[PNGlobalManager sharedObject].gameKey version:[[PNGameManager sharedObject] currentVersionStringValue] lobby:lobby];
}

-(void) stopService
{
	if(self.gameKitSession) [self.gameKitSession stop];
}

-(void)join
{
	PNManager *manager = [PNManager sharedObject];
	self.gameKitSession.currentRoom = self;
	self.gameKitSession.delegate = (id<PNGKSessionDelegate>)self.gameSession;
	self.gameKitSession.roomDelegate = delegate;
	[self.gameKitSession selectRoom:self];
	
	manager.roomManager.currentRoom = self;

}

-(void)leave
{
	[self.gameKitSession leave];
	self.isHeartBeatNecessary = NO;
	if([self.delegate respondsToSelector:@selector(didLeaveRoom:)])
		[self.delegate didLeaveRoom:self];
}


- (void)heartbeat
{
	PNLocalRoom* room = self;
	const double HAERTBEAT_DELAY = 1.0f;
	double now = CFAbsoluteTimeGetCurrent();
	id<PNGameSessionDelegate> gameSessionDelegate = room.gameSession.delegate;
	if(room.isHeartBeatNecessary) {
		if(room.heartbeatLastTimeStamp == -1 || now - room.heartbeatLastTimeStamp >= HAERTBEAT_DELAY) {
			PNGKSession* gkSession = room.gameKitSession;
			PNGKPacket* packet = [PNGKPacket create];
			packet.command = _PNGK_SESSION_PROTOCOL_PING;
			[packet setSourceData:[NSData dataWithBytes:"{}" length:2]];
			int dataLen = [packet pack];
			
			room.heartbeatLastTimeStamp = CFAbsoluteTimeGetCurrent();
			BOOL isAliveAnyPeer = NO;
			for(PNPeer* p in [room.gameSession.peers allValues]) {
				if(!p.isConnecting || p == self.gameSession.selfPeer) continue;
				if(![p.address isEqualToString:[NSString stringWithFormat:@"%d",_PNGK_SESSION_SELF_PEER_NUMBER]]) {
					p.packetTimeStamp = p.packetTimeStamp == -1 ? now : p.packetTimeStamp;
					if(!self.isDisconnectDetectionNecessary)
						p.packetTimeStamp = now;
					if(now-p.packetTimeStamp > kPNHeartbeatTimeoutValue) {
						if(p.isConnecting)
							if([gameSessionDelegate respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
								[gameSessionDelegate gameSession:room.gameSession didDisconnectPeer:p];
						p.isConnecting = NO;
					} else {
						isAliveAnyPeer = YES;
						PNNetworkLog(@"Heart beart to %@",p.user.username);
						[gkSession send:[NSData dataWithBytes:packet.dstData length:dataLen]
								   peer:p.address
								   mode:kPNGameSessionUnreliable];
					}
				}
			}
			
			if(isAliveAnyPeer)
				[self performSelector:@selector(heartbeat) withObject:nil afterDelay:HAERTBEAT_DELAY+0.1f];
		}
	}
}

-(void)dealloc {
	self.isHeartBeatNecessary = NO;
	[self stopService];
	[self clear];
	[super dealloc];
}

@end

