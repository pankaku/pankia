#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNUser.h"
#import "PNRoom.h"
#import "PNPeer.h"
#import "PNNetworkUtil.h"
#import "PNNetworkError.h"
#import "PNUDPConnectionService.h"
#import "PNPacket.h"
#import "IPAddress.h"
#import "PNGKSession.h"
#import "PNPacketFireWall.h"
#import "PNPeer+Package.h"
#import "PNLogger+Package.h"


extern NSNumber *inetToLongLong(const char* host,int port);


@interface PNGameSession(UDPLayer)
- (void)resendDataPacket:(NSArray*)params;
- (void)sendDataPacket:(PNPacket*)packet peer:(PNPeer*)peer;
- (void)onUdpSocket:(AsyncUdpSocket *)sock
didNotReceiveDataWithTag:(long)tag
		 dueToError:(NSError *)error;
- (void)send:(NSData*)data
		host:(NSString*)host
		port:(int)port;
-(void)sendPackedPackets;
-(void)pushSendQueue:(PNPacket*)packet peer:(PNPeer*)peer;
-(void)resendDataPacket:(NSArray*)params;
-(void)sendDataPacket:(PNPacket*)packet peer:(PNPeer*)peer;
-(void) setup:(AsyncUdpSocket*)udp
	  address:(NSString*)address
		 port:(int)port;
@end

@interface PNGameSession(NTP)
- (void)synchronousProcessing;
- (void)sync:(NSData*)data opponent:(PNPeer*)peer counter:(int)cnt;
- (void)recvData:(NSData*)data from:(PNPeer*)peer;
@end

@interface PNGameSession(GameSessionIO)
-(BOOL)sendData:(NSData *)data
		toPeers:(NSArray *)ps
	 connection:(int)aConnection
		   type:(int)aType
		command:(int)aCommand
		 method:(int)aMethod;
@end



@implementation PNGameSession(UDPLayer)

- (void)send:(NSData*)data
		host:(NSString*)host
		port:(int)port
{
	[peerSocket sendData:data toHost:host port:(UInt16)port withTimeout:30.0 tag:kPNStunUDPConnectionTagPacket];
}


// Notify
-(void)sendPackedPackets
{
	const static float LOOPDELAY = 0.070;
	if(self.isAlive && CFAbsoluteTimeGetCurrent() - latestSendTime > LOOPDELAY) {
		NSArray* ps = [peers allValues];
		for(PNPeer* p in ps) {
			if([p.sendQueue count]) {
				NSData* data = [PNPacket blockPack:p.sendQueue];
				[self send:data host:p.address port:p.udpPort];
				[p.sendQueue removeAllObjects];
			}
		}
		latestSendTime = CFAbsoluteTimeGetCurrent();
		[self performSelector:@selector(sendPackedPackets) withObject:nil afterDelay:LOOPDELAY];
	}
}

-(void)pushSendQueue:(PNPacket*)packet peer:(PNPeer*)peer
{
	[peer.sendQueue addObject:packet];
	[self sendPackedPackets];
}


-(void)resendDataPacket:(NSArray*)params
{
	PNPacket* packet;
	PNPeer* peer;
	packet	= [params objectAtIndex:0];
	peer	= [params objectAtIndex:1];
	if(!packet.ackFlag && self.isAlive) {
		double time = CFAbsoluteTimeGetCurrent() - packet.timestamp;
		if(time < kPNPeerToPeerPacketTimeout) {
			float rto;
			rto = MAX((1 << packet.resendCount) * peer.rto,0.200); // TCP同様、再送制御用RTOは200msが最低。
			PNNetworkLog(@"Reliable Packet. RESEND SEQ(%d) RTO:%f CNT(%d)\n",packet.sequence,peer.rto,packet.resendCount);
			packet.resendCount++;
			[self pushSendQueue:packet peer:peer];
			[self performSelector:@selector(resendDataPacket:) withObject:[NSArray arrayWithObjects:packet,peer,nil] afterDelay:MIN(rto,MAX(kPNPeerToPeerPacketTimeout-time,0.200))];
		} else {
			PNError *error;
			NSString* errorMessage;
			errorMessage = [NSString stringWithFormat:@"UDP connection time out. Timeout peer is %@",peer.address];			
			error = [PNNetworkError errorWithType:kPNPeerErrorTimeout
												message:errorMessage];
			
			NSObject* delegateObject = self.delegate;
			if([delegateObject respondsToSelector:@selector(gameSession:didSendError:opponent:data:)])
				[delegateObject performSelectorOnMainThread:@selector(gameSession:didSendError:opponent:data:)
												withObjects:[NSArray arrayWithObjects:self,error,peer,packet.data,nil]];
			
			PNNetworkLog(@"Packet timeout error. SEQ(%d)",packet.sequence);
		}
	}
}

-(void)sendDataPacket:(PNPacket*)packet peer:(PNPeer*)peer
{
	[packet pack];
	[peer.sentPackets addObject:packet];
	[self pushSendQueue:packet peer:peer];
	
	[self performSelector:@selector(resendDataPacket:) withObject:[NSArray arrayWithObjects:packet,peer,nil] afterDelay:MAX(peer.rto,0.200)];
}





-(void) setup:(AsyncUdpSocket*)udp
	  address:(NSString*)address
		 port:(int)port
{
	AsyncUdpSocket *udpSocket = udp;
	if(![udpSocket isBinded]) {
		PNNetworkLog(@"Bind UDP socket.");
		NSString *bindAddres = address ? address : [IPAddress getIPAddress];
		if([udpSocket bindToAddress:bindAddres port:port error:nil] == NO) {
			bindAddres = @"0.0.0.0";
			if([udpSocket bindToAddress:bindAddres port:port error:nil] == NO) {
				//				PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
				//				e.message = @"Can't bind address or port.";
				//				e.errorType = kPNUDPErrorUnknown;
				PNNetworkLog(@"Bind NG.");
			} else {
				self.isAlive = YES;
				PNNetworkLog(@"Bind OK.");
			}
		} else {
			self.isAlive = YES;
			PNNetworkLog(@"Bind OK.");
		}
	} else {
		PNNetworkLog(@"Allready binded.");
		self.isAlive = YES;
	}
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
		 dueToError:(NSError *)error
{
	PNNetworkLog(@"DidNotSend: %@", error);
}


// PNGKSessionDelegate
-(void)session:(PNGKSession*)session didReceiveWithData:(NSData*)data from:(PNPeer*)opponent
{
	if(isStarted) {
		if([self.delegate respondsToSelector:@selector(gameSession:didReceiveData:from:)])
			[self.delegate gameSession:self didReceiveData:data from:opponent];
	} else {
		[self recvData:data from:opponent];
	}
}

-(void)session:(PNGKSession*)aSession didSendError:(PNError*)aError opponentPeerID:(NSString*)aPeerId data:(NSData*)aData
{
	PNPeer* peer = [peers objectForKey:aPeerId];
	if([self.delegate respondsToSelector:@selector(gameSession:didSendError:opponent:data:)])
		[self.delegate gameSession:self didSendError:aError opponent:peer data:aData];
	
}


// PNGKSessionDelegate
-(void)session:(PNGKSession*)session didFailWithError:(PNError*)error
{
}

- (void)notifyReceivedPacket:(PNPeer*)aTarget
					  packet:(PNPacket*)aPacket
					delegate:(id)aDelegate
{
	if(self.gameSessionType == PNInternetSession) {
		// サーバーやallowされていないPeerからのパケットに対して、無効にする。
		if(![PNPacketFireWall isIPv4Allowed:aTarget.address port:aTarget.udpPort] || [PNPacketFireWall isServerAddress:aTarget.address]) {
			PNNetworkLog(@"Packet firewall. Invalid IP address : %@",aTarget.address);
			return;
		}
	}
	
	int theFlag = aPacket.theFlag;
	int type		= kPNGetPacketType(theFlag);
	int connection	= kPNGetpacketConnection(theFlag);
	int command		= kPNGetPacketCommand(theFlag);
	int method		= kPNGetPacketMethod(theFlag);
	(type);(connection); // Unused valiable
	
	switch (command) {
		case kPNPacketFlagCommandUser:{
			switch(method) {
				case kPNPacketFlagMethodUser:{
					NSObject* delegateObject = aDelegate;
					if([delegateObject respondsToSelector:@selector(gameSession:didReceiveData:from:)])
						[delegateObject performSelectorOnMainThread:@selector(gameSession:didReceiveData:from:)
														withObjects:[NSArray arrayWithObjects:self,aPacket.data, aTarget,nil]];
				}break;
				default:{
					PNNetworkLog(@"Unknown command.");
				}
			}
		}break;
		case kPNPacketFlagCommandSystem:{
			switch(method) {
				case kPNPacketFlagMethodPing:{
					PNNetworkLog(@"kPNPacketFlagMethodPing. %@", aTarget.user.username);
					[self sendData:[NSData dataWithBytes:"{}" length:2]
						   toPeers:[NSArray arrayWithObjects:aTarget,nil]
						connection:kPNGameSessionUnreliable
							  type:kPNPacketFlagData
						   command:kPNPacketFlagCommandSystem
							method:kPNPacketFlagMethodPong];
				}break;
				case kPNPacketFlagMethodPong:{
					PNNetworkLog(@"kPNPacketFlagMethodPong. %@", aTarget.user.username);
					aTarget.packetTimeStamp = CFAbsoluteTimeGetCurrent();
				}break;
				case kPNPacketFlagMethodRematch:{
					NSMutableDictionary* params = [NSMutableDictionary dictionary];
					[params setObject:aTarget forKey:@"from"];
					[params setObject:aPacket.data forKey:@"data"];
					[self performSelectorOnMainThread:@selector(onReceivedRematchPacket:)
										  withObject:params waitUntilDone:NO];
				}break;
				case kPNPacketFlagMethodSync:{
					PNNetworkLog(@"kPNPacketFlagMethodSync. %@", aTarget.user.username);
					[self recvData:aPacket.data from:aTarget];
				}break;
				case kPNPacketFlagMethodFin:{
					PNNetworkLog(@"kPNPacketFlagMethodFin. %@ %@:%d", aTarget.user.username,aTarget.address,aTarget.udpPort);
					PNLog(@"Received fin packet.");
					if(aTarget.isConnecting){
						NSObject* delegateObject = delegate;
						if([delegateObject respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
							[delegateObject performSelectorOnMainThread:@selector(gameSession:didDisconnectPeer:)
															withObjects:[NSArray arrayWithObjects:self,aTarget,nil]];
						
					}
					aTarget.isConnecting = NO;
					[PNPacketFireWall removeIPv4:aTarget.address port:aTarget.udpPort];
				}break;
				default:{
					PNNetworkLog(@"Unknown method.");
				}
			}
		}break;
	}
}


- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
	 didReceiveData:(NSData *)data
			withTag:(long)tag
		   fromHost:(NSString *)fromHost
			   port:(UInt16)fromPort
{
	PNPeer *target = [peers objectForKey:inetToLongLong([fromHost UTF8String],fromPort)];
	if(target) {
		NSArray* packets = [PNPacket blockUnpack:data];
		for(PNPacket* packet in packets) {
			packet.address		= fromHost;
			packet.port			= fromPort;
			
			int connection	= kPNGetpacketConnection(packet.theFlag);
			int command		= kPNGetPacketCommand(packet.theFlag);
			int method		= kPNGetPacketMethod(packet.theFlag);
			int type		= kPNGetPacketType(packet.theFlag);
			
			switch(connection) {
				case kPNPacketFlagConnectionRaw:{
					PNNetworkLog(@"Raw packet on PNPacket.");
				}break;
				case kPNPacketFlagConnectionUnreliable:{
					PNNetworkLog(@"Unreliable Packet. Packet Seq(-1) on PNPacket.");
					[self notifyReceivedPacket:target packet:packet delegate:delegate];
				}break;
				case kPNPacketFlagConnectionReliable:{
					switch (type) {
						case kPNPacketFlagData:{
							PNNetworkLog(@"Reliable Packet. RECV:DATA:Packet Seq(%d) on PNPacket.",packet.sequence);
							PNPacket *ack	= [PNPacket create];
							ack.sequence	= packet.sequence;
							ack.theFlag		= connection|command|method|kPNPacketFlagAck;
							ack.data		= [NSData dataWithBytes:"" length:0];
							ack.address		= fromHost;
							ack.port		= fromPort;
							
							[ack pack];
							PNNetworkLog(@"Reliable Packet. SEND:ACK:Packet Seq(%d) on PNPacket.",packet.sequence);
							[self pushSendQueue:ack peer:target];
							
							if(target.readSequenceCounter <= packet.sequence) {
								int isExist = 0;
								for(PNPacket* p in target.readPackets) {
									if(p.sequence == packet.sequence) {
										isExist = 1;
										break;
									}
								}
								
								if(!isExist) {
									if(target.readSequenceCounter == packet.sequence) {
										target.readSequenceCounter++;
										
										[self notifyReceivedPacket:target packet:packet delegate:delegate];
										
										// Sorted list.
										if([target.readPackets count]) {
											NSArray* sortedPackets = [target.readPackets sortedArrayUsingSelector:@selector(compareASC:)];
											for(PNPacket *p in sortedPackets) {
												if(target.readSequenceCounter == p.sequence) {
													target.readSequenceCounter++;
													[self notifyReceivedPacket:target packet:p delegate:delegate];
													[target.readPackets removeObject:p];
												} else {
													break;
												}
											}
										}
									} else {
										[target.readPackets addObject:packet];
									}
								} else {
									PNNetworkLog(@"Already received packet. SEQ:(%d) on PNPacket.",packet.sequence);
								}
							} else {
								PNNetworkLog(@"Already received packet. It's too late. SEQ:(%d) on PNPacket.",packet.sequence);
							}
						}break;
						case kPNPacketFlagAck:{
							PNPacket* deletePacket = nil;
							for(PNPacket* p in target.sentPackets) {
								if(p.sequence == packet.sequence) {
									p.ackFlag = 1;
									deletePacket = p;
									break;
								}
							}
							if(deletePacket) {
								PNNetworkLog(@"Reliable Packet. RECV:ACK:Packet Seq(%d) Host:%@ Port:%d  RTO:%f",packet.sequence,fromHost,fromPort,target.rto);
								PNNetworkLog(@"SEQ(%d) RTO:%f",packet.sequence,target.rto);
								PNNetworkLog(@"RTO:%f S(%d)\n",target.rto,[target.sentPackets count]);
								
								double rtt		= CFAbsoluteTimeGetCurrent() - deletePacket.timestamp;
								double delta	= target.srtt - rtt;
								static const float K = 1.0 / 8.0f;
								static const float A = 1.0 / 4.0f;
								target.srtt		= (1-A) * target.srtt + (A) * rtt;
								target.rto		= target.srtt + 4 * target.rttvar;
								target.rttvar	= (K) * target.rttvar + (K) * (fabs(delta) - target.rttvar);
								
								[target.sentPackets removeObject:deletePacket];
							}
						}break;
					}
				}break;
			}
		}
		
	} else {
		PNNetworkLog(@"Target is not found. Received packet from other member. %s %d",[fromHost UTF8String],fromPort);
	}
	
	// Don't stop receiving loop
	if(self.isAlive) {
		[peerSocket receiveWithTimeout:kPNUDPReceiveTimeout tag:kPNStunUDPConnectionTagPacket];
	}
	
	return YES;
}


- (void)onUdpSocket:(AsyncUdpSocket *)sock
didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
	switch(tag) {
		case kPNStunUDPConnectionTagPacket:{
			[peerSocket receiveWithTimeout:kPNUDPReceiveTimeout tag:kPNStunUDPConnectionTagPacket];
		}break;
			
	}
	PNNetworkLog(@"DidNotReceive: %@", error);
}

@end
