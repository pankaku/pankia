#import "PNUDPConnectionService.h"
#import "PNLogger+Package.h"
#import "PNThreadManager.h"
#import "NSThread+ControllerExt.h"
#import "PNNetworkError.h"
#import "PNNetworkUtil.h"
#import "NSObject+PostEvent.h"
#import "PNPacket.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNGameSession.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "Helpers.h"
#import "IPAddress.h"
#import <netdb.h>
#import "PNGlobal.h"
#import "PNSettingManager.h"


// TODO 逆参照
#import "PNManager.h"


#define kPNUDPPacketFirewall					true

#define kPNPunchMessageNoop						@"noop"	// パンチした穴を保持しておくためのダミーメッセージ。

#define kPNPunchMessageStunDummy				@"stun.dummy"
#define kPNPunchMessageStunStart				@"stun.start"
#define kPNPunchMessageStunAck					@"stun.ack"
#define kPNPunchMessageStunSymmetric			@"stun.symmetric"
#define kPNPunchMessageStunDone					@"stun.done"
#define kPNPunchMessageStunFail					@"stun.fail"

#define kPNPunchMessagePairStart				@"pair.start"
#define kPNPunchMessagePairReport				@"pair.report"
#define kPNPunchMessagePairDone					@"pair.done"
#define kPNPunchMessagePairFailed				@"pair.fail"
#define kPNPunchMessagePairDelete				@"pair.delete"
#define kPNPunchMessagePairAleadyStarted		@"pair.already_started"


#define kPNPunchMessagePeerToPeerSymmetricRespond		@"p2p.symmetric.respond"
#define kPNPunchMessagePeerToPeerSymmetricInitiate		@"p2p.symmetric.initiate"

#define kPNPunchMessagePeerToPeerPunchStart			@"p2p.punch.start"
#define kPNPunchMessagePeerToPeerPunchJab			@"p2p.punch.jab"
#define kPNPunchMessagePeerToPeerPunchJabNotify		@"p2p.punch.jab.notify"
#define kPNPunchMessagePeerToPeerPunchRequest		@"p2p.punch.request"
#define kPNPunchMessagePeerToPeerPunchResponse		@"p2p.punch.response"
#define kPNPunchMessagePeerToPeerPunchPing			@"p2p.punch.ping"
#define kPNPunchMessagePeerToPeerPunchPong			@"p2p.punch.pong"


#define kPNStringNatTypeNoNat					@"NO_NAT"
#define kPNStringNatTypeFullCone				@"FULL_CONE"
#define kPNStringNatTypeRestrictedCone			@"RESTRICTED_CONE"
#define kPNStringNatTypePortRestrictedCone		@"PORT_RESTRICTED_CONE"
#define kPNStringNatTypeSymmetric				@"SYMMETRIC"
#define kPNStringNatTypeIPMasquerade			@"IP_MASQUERADE"



AsyncUdpSocket* udpSocketForInternet = nil;


extern NSNumber *inetToLongLong(const char* host,int port);

NSNumber *getAbsoluteTime() {
	long long int time = (long long int)(CFAbsoluteTimeGetCurrent()*1000);
	return [NSNumber numberWithInt:time & 0x7FFFFFFF];
}

@interface PNUDPConnectionService(Private)

- (void)punching:(NSMutableDictionary*)params;
- (void)reportResult:(NSMutableDictionary*)params;
- (void)sendPacketForKeepingNatTable;
- (void)sendPacketToServer:(NSData*)aData host:(NSString*)aHost port:(int)aPort withTTL:(int)aTTL;
- (void)sendPacketToPeer:(NSData*)aData host:(NSString*)aHost port:(int)aPort withTTL:(int)aTtl;
- (void)sendToServerDeleteMessages:(NSNumber*)aCounter peers:(NSArray*)aPeers;

@end

@implementation PNUDPConnectionService
@synthesize delegate;
@synthesize udpSocket;
@synthesize natHost;
@synthesize natPort;
@synthesize selfPeer;
@synthesize opponentHost;
@synthesize opponentPort;
@synthesize natType;
@synthesize isAlive;
@synthesize opponents;
@synthesize currentRoom;
@synthesize bindAddress;
@synthesize bindPort;
@synthesize isChecked;
@synthesize checkCount;
@synthesize paringTableForSymmetric;
@synthesize connectionPermissibleRangeSpeed;

static PNUDPConnectionService *_sharedInstance = nil;

-(id)init
{
	if(self = [super init]) {
		self.delegate	= nil;
		self.udpSocket	= nil;
		self.natHost	= nil;
		self.natPort	= -1;
		self.selfPeer	= nil;
		self.opponentHost = nil;
		self.opponentPort = -1;
		self.natType	= kPNUnknownNAT;
		self.isAlive	= NO;
		self.isChecked	= NO;
		self.opponents	= [NSMutableDictionary dictionary];
		self.currentRoom = nil;
		self.paringTableForSymmetric = [NSMutableDictionary dictionary];
		self.bindAddress = nil;
		self.bindPort	= -1;
		self.checkCount = 0;
		self.connectionPermissibleRangeSpeed = [[PNSettingManager sharedObject] intValueForKey:@"RTTThreshold"];
		timestampForPortMapping = CFAbsoluteTimeGetCurrent() - kPNKeepNATTablePacketDelayTime;
		[PNPacketFireWall initialize];
		
	}
	return self;
}

-(void)dealloc
{
	self.opponents	= nil;
	self.delegate	= nil;
	self.udpSocket	= nil;
	self.natHost	= nil;
	self.selfPeer	= nil;
	self.opponentHost = nil;
	self.opponents	= nil;
	self.currentRoom = nil;
	self.paringTableForSymmetric = nil;
	self.bindAddress = nil;
	[super dealloc];
}

- (void)CALLBACK_CreateUDPSocketOnUDPThread:(id)obj
{
	PNLog(@"%@",[NSThread threadInformation]);
	// Thread mode is SCHED_FIFO(Queue) and priority is most high.
	[NSThread changeThreadModeToQueueWithPriority:100];
	PNLog(@"%@",[NSThread threadInformation]);
	
	if(!udpSocketForInternet)
		udpSocketForInternet = [[AsyncUdpSocket alloc] init];
}

+(BOOL) setup
{
	PNCLog(PNLOG_CAT_UDP, @"Setup UDP Socket.");
	PNUDPConnectionService *_instance = [PNUDPConnectionService sharedObject];
	id delegate = _instance.delegate;
	if(!_instance.udpSocket) {
		// Soket open.
		_instance.udpSocket = udpSocketForInternet;
		AsyncUdpSocket *udpSocket = _instance.udpSocket;
		udpSocket.delegate = _instance;
		_instance.bindAddress = [IPAddress getIPAddress];
		if([udpSocket bindToAddress:_instance.bindAddress port:0 error:nil] == NO) {
			_instance.bindAddress = @"0.0.0.0";
			if([udpSocket bindToAddress:_instance.bindAddress port:0 error:nil] == NO) {
				_instance.udpSocket = nil;
				PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
				e.message = @"Can't bind address and port.";
				e.errorType = kPNUDPErrorUnknown;
				if([delegate respondsToSelector:@selector(stunService:didError:)])
					[delegate stunService:self didError:e];
				return NO;
			}
		}
		_instance.bindPort = [udpSocket localPort];
		
		// Set lower TTL to fix port number
		//[_instance setTTL:kPNTTLDummyPacket];
		// Dummy - don't expect response - determine the NIC to use and check in didSendDataWithTag
		NSData *data = [kPNPunchMessageStunDummy dataUsingEncoding:NSUTF8StringEncoding];
		[udpSocket sendData:data toHost:kPNPrimaryHost port:(UInt16)kPNUDPPrimaryPort withTimeout:2.0 tag:kPNStunUDPConnectionTagDummyPacket ttl:kPNTTLDummyPacket];
		
		if([delegate respondsToSelector:@selector(didStartWithService:)])
			[delegate didStartWithService:self];
	} else {
		// Rebind AsyncUdpSocket delegate.
		_instance.udpSocket = udpSocketForInternet;
		AsyncUdpSocket *udpSocket = _instance.udpSocket;
		udpSocket.delegate = _instance;
	}
	
	return YES;
}

+(void)suspend
{
	
	PNUDPConnectionService *service = [PNUDPConnectionService sharedObject];
	service.natType = kPNUnknownNAT;
	service.opponentHost = nil;
	service.opponentPort = 0;
	service.isAlive = NO;
	service.isChecked = NO;
	service.checkCount = 0;
	service.bindAddress = nil;
	service.bindPort = 0;
	service.natHost = nil;
	service.natPort = 0;
	service.currentRoom = nil;
	service.selfPeer = nil;
	
	[PNUDPConnectionService clear];
	udpSocketForInternet.delegate = nil;
	[udpSocketForInternet close];
	[udpSocketForInternet release];
	udpSocketForInternet = nil;
	[PNUDPConnectionService sharedObject].isAlive = NO;
}

+(void)resume
{
	[_sharedInstance performSelectorOnConnectionThreadSync:@selector(CALLBACK_CreateUDPSocketOnUDPThread:)
												withObject:nil];
	
}

+(void)rebind
{
	[PNUDPConnectionService setup];
}

+(void)deletePairingTable:(NSArray*)aPeers
{
	PNUDPConnectionService* udpConnectionService = [PNUDPConnectionService sharedObject];
	[udpConnectionService performSelectorOnConnectionThread:@selector(sendToServerDeleteMessages:peers:)
												withObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:2],aPeers,nil]];
}

+(void)clear
{
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Clearing PNUDPConnectionService.");
	PNUDPConnectionService* udpConnectionService = [PNUDPConnectionService sharedObject];
	// すべてのキャッシュをクリアする。
	[udpConnectionService.opponents removeAllObjects];
	[udpConnectionService.paringTableForSymmetric removeAllObjects];
	// AllowしたIPもクリアする。
	[PNPacketFireWall clear];
}

-(void)sendToServerDeleteMessages:(NSNumber*)aCounter peers:(NSArray*)aPeers
{
	int counter = [aCounter intValue];
	if(counter > 0 && [aPeers count]) {
		counter--;
		NSString*			privateSession;
		NSMutableString*	pair_ids;
		NSString*			deleteMessage;
		NSData*				data;
		
		pair_ids		= [NSMutableString string];
		
		for(PNPeer* peer in aPeers) {
			[pair_ids appendFormat:@" %d",peer.pairingNumber];
		}
		
		privateSession	= [PNUser session];
		deleteMessage	= [NSString stringWithFormat:@"%@ %@%@",kPNPunchMessagePairDelete,privateSession,pair_ids];
		data			= [NSData dataWithBytes:[deleteMessage UTF8String] length:deleteMessage.length];
		
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Sending pairing delete request to server...(retry:%d) %@", aCounter, deleteMessage);
		
		PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"SendUDP:[%@] to %@:%d",deleteMessage,kPNPrimaryHost,kPNUDPPrimaryPort);
		
		[self sendPacketToServer:data host:kPNPrimaryHost port:kPNUDPPrimaryPort withTTL:kPNStunDefaultPacketTTL];
		
		aCounter = [NSNumber numberWithInt:counter];
		[self performSelector:@selector(sendToServerDeleteMessages:peers:)
				  withObjects:[NSArray arrayWithObjects:aCounter,aPeers,nil]
				   afterDelay:0.5];
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"pairing delete request sent.");
	}
}

-(void)sendPacketToPeerWithProxy:(NSData*)aData host:(NSString*)aHost port:(int)aPort
{
	[PNNetworkUtil sendPacketFilterWithDelegate:(id<PNSendPacketFilterDelegate>)self
									 isReliable:NO
										   data:aData
										   host:aHost
										   port:[NSNumber numberWithInt:aPort]];
}

// PNSendPacketFilterDelegate
-(void)filteringAndPacketIsTransmitted:(NSData*)aData host:(NSString*)aHost port:(NSNumber*)aPort
{
	[self sendPacketToPeer:aData host:aHost port:[aPort intValue] withTTL:kPNStunDefaultPacketTTL];
}


-(void)CALLBACK_StartWithDelegate:(NSArray*)params
{
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"__onUDPThread__startWithDelegate");
	id<PNUDPConnectionServiceDelegate> _delegate = (id<PNUDPConnectionServiceDelegate>)[params objectAtIndex:0];
	NSString* session = [params objectAtIndex:1];
	
	self.delegate = _delegate;
	PNUDPConnectionService *_instance = [PNUDPConnectionService sharedObject];
	
	if([PNUDPConnectionService setup]) {
		NSString *str;
		NSData *data;
		_instance.isAlive = YES;
		
		NSString* b_address = _instance.bindAddress;
		int port			= _instance.bindPort;
		udpSocket = _instance.udpSocket;
		str		= [NSString stringWithFormat:@"%@ %@:%hu %@",
				   kPNPunchMessageStunStart,
				   b_address,
				   port,
				   session];
		data	= [str dataUsingEncoding:NSUTF8StringEncoding];
		
		struct hostent* primary_host;
		struct hostent* secondary_host;
		primary_host	= gethostbyname([kPNPrimaryHost UTF8String]);
		
		if(primary_host) {
			for(char** p = primary_host->h_addr_list;*p;p++) {
				struct in_addr addr;
				bcopy( *p,&addr,primary_host->h_length );
				PNLog(@"PrimaryHost:%s",inet_ntoa( addr ));
			}
		}
		
		secondary_host	= gethostbyname([kPNSecondaryHost UTF8String]);
		if(secondary_host) {
			for(char** p = secondary_host->h_addr_list;*p;p++) {
				struct in_addr addr;
				bcopy( *p,&addr,secondary_host->h_length );
				PNLog(@"SecondaryHost:%s",inet_ntoa( addr ));
			}
		}
		[udpSocket sendData:data toHost:kPNPrimaryHost port:(UInt16)kPNUDPPrimaryPort withTimeout:2.0 tag:kPNStunUDPConnectionTagPacket];
		[udpSocket receiveWithTimeout:kPNUDPReceiveTimeout tag:kPNStunUDPConnectionTagPacket];
		[_instance sendPacketForKeepingNatTable];
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"SendUDP : \n %@",str);
	} else {
		PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
		e.message = @"Can't open UDP socket.";
		e.errorType = kPNUDPErrorFailed;
		
		NSObject* delegateObject = delegate;
		if([delegateObject respondsToSelector:@selector(stunService:didError:)])
			[delegateObject performSelectorOnMainThread:@selector(stunService:didError:)
											withObjects:[NSArray arrayWithObjects:self,e,nil]];
	}
}

-(void)checkTimeoutCheckingNATProc:(id<PNUDPConnectionServiceDelegate>)aDelegate session:(NSString*)aSession
{
	PNUDPConnectionService* udpService = [PNUDPConnectionService sharedObject];
	if(!udpService.isChecked && udpService.checkCount < 1) {
		udpService.checkCount++;
		[udpService performSelectorOnConnectionThread:@selector(CALLBACK_StartWithDelegate:)
										   withObject:[NSArray arrayWithObjects:aDelegate, aSession, nil]];
	}
}

// Check NAT.
+(void)checkNATWithDelegate:(id<PNUDPConnectionServiceDelegate>)delegate
					session:(NSString*)session
{
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Check NAT type.");
	PNUDPConnectionService *_instance = [PNUDPConnectionService sharedObject];
	_instance.isChecked = NO;
	_instance.checkCount = 0;
	[_instance performSelector:@selector(checkTimeoutCheckingNATProc:session:)
				   withObjects:[NSArray arrayWithObjects:delegate,session,nil]
					afterDelay:10];
	[_instance performSelectorOnConnectionThread:@selector(CALLBACK_StartWithDelegate:)
									  withObject:[NSArray arrayWithObjects:delegate, session, nil]];
}



-(void) CALLBACK_StartPairingWithDelegateOnUDPThread:(NSArray*)params
{
	PNCLog(PNLOG_CAT_UHP, @"__onUDPThread__startPairingWithDelegate");
	id<PNUDPConnectionServiceDelegate> _delegate = (id<PNUDPConnectionServiceDelegate>)[params objectAtIndex:0];
	NSString* session = [params objectAtIndex:1];
	PNRoom* room = [params objectAtIndex:2];
	NSString* opponentSession = [params objectAtIndex:3];
	PNUDPConnectionService* _instance = [PNUDPConnectionService sharedObject];
	_instance.delegate			= _delegate;
	_instance.currentRoom		= room;
	
	[PNUDPConnectionService clear];
	if([PNUDPConnectionService setup]) {
		NSString* str;
		NSData* data;
		_instance.isAlive = YES;
		udpSocket	= _instance.udpSocket;
		str			= [NSString stringWithFormat:@"%@ %@ %@",kPNPunchMessagePairStart,session,opponentSession];
		data		= [str dataUsingEncoding:NSUTF8StringEncoding];
		[udpSocket sendData:data toHost:kPNPrimaryHost port:(UInt16)kPNUDPPrimaryPort withTimeout:2.0 tag:kPNStunUDPConnectionTagPacket];
		[udpSocket receiveWithTimeout:kPNUDPReceiveTimeout tag:kPNStunUDPConnectionTagPacket];
	} else {
		PNCLog(PNLOG_CAT_UHP, @"__onUDPThread__startPairingWithDelegate failed.");
		PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
		e.message = @"Can't open UDP socket.";
		e.errorType = kPNUDPErrorFailed;
		if([delegate respondsToSelector:@selector(stunService:didError:)])
			[delegate stunService:self didError:e];
	}
	
}

// For client. (JOIN ROOM)
+(void) startPairingWithDelegate:(id<PNUDPConnectionServiceDelegate>)delegate
							room:(PNRoom*)room
					  ownSession:(NSString*)session
				 opponentSession:(NSString*)opponentSession
{
	
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Start pairing. Opponent session is %@.",opponentSession);
	PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, ([NSString stringWithFormat:@"Start pairing with %@.", opponentSession]));
	
	PNCLog(PNLOG_CAT_UHP, @"Start pairing with delegate.");
	PNUDPConnectionService* _instance	= [PNUDPConnectionService sharedObject];
	[_instance performSelectorOnConnectionThread:@selector(CALLBACK_StartPairingWithDelegateOnUDPThread:)
									  withObject:[NSArray arrayWithObjects:delegate, session, room, opponentSession, nil]];
}


- (void)sendPacketForKeepingNatTable
{
	if(isAlive) {
		if(CFAbsoluteTimeGetCurrent() - timestampForPortMapping >= kPNKeepNATTablePacketDelayTime) {
			PNCLog(PNLOG_CAT_UHP, @"Keep port mapping.");
			NSString* op = kPNPunchMessageNoop;
			NSData* data = [NSData dataWithBytes:[op UTF8String] length:[op length]];
			[self sendPacketToServer:data host:kPNPrimaryHost port:(UInt16)kPNUDPPrimaryPort withTTL:kPNStunDefaultPacketTTL];
			timestampForPortMapping = CFAbsoluteTimeGetCurrent();
			[self performSelector:@selector(sendPacketForKeepingNatTable)
					   withObject:nil
					   afterDelay:kPNKeepNATTablePacketDelayTime+0.5];
		}
	}
}


- (void)onUdpSocket:(AsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
		 dueToError:(NSError *)error
{
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"DidNotSend: %@", error);
}


- (void)sendPacketToServer:(NSData*)aData host:(NSString*)aHost port:(int)aPort withTTL:(int)aTTL
{
	[udpSocket sendData:aData toHost:aHost port:(UInt16)aPort withTimeout:2.0 tag:kPNStunUDPConnectionTagPacket ttl:aTTL];
}

- (void)sendPacketToPeer:(NSData*)aData host:(NSString*)aHost port:(int)aPort withTTL:(int)aTTL
{
	int theFlag = 0;
	theFlag |= kPNGameSessionUnreliable;
	theFlag |= kPNPacketFlagData;
	theFlag |= kPNPacketFlagCommandSystem;
	theFlag |= kPNPacketFlagMethodPairing;
	
	PNPacket* packet	= [PNPacket create];
	packet.data			= aData;
	packet.theFlag		= theFlag;
	packet.address		= aHost;
	packet.port			= aPort;
	[packet pack];
	[udpSocket sendData:packet.packedData toHost:aHost port:(UInt16)aPort withTimeout:2.0 tag:kPNStunUDPConnectionTagPacket ttl:aTTL];
}

- (void)recvLoop
{
	// Don't stop receive loop
	if(isAlive)
		[udpSocket receiveWithTimeout:kPNUDPReceiveTimeout tag:kPNStunUDPConnectionTagPacket];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
	 didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)fromHost port:(UInt16)fromPort
{
	PNRoom* cRoom = currentRoom;
	
	if(kPNUDPPacketFirewall) {
		if(![PNPacketFireWall isIPv4Allowed:fromHost port:fromPort]) {
			// 例外的にAllow状態になっていないユーザーに対して既にマッチングが完了していることを通知する機構。
			if(cRoom) {
				if(cRoom.maxMemberNum == [cRoom.roomMembers count]) { // 既に部屋の限界値までメンバーが入室していて無効なパケットを受信した。
					if(![PNPacketFireWall isServerAddress:fromHost]) { // サーバーのパケットではない場合はpair.already_startを送信し送信側に伝える。
						NSMutableDictionary *dict = [JsonHelper buildDoDictionary:kPNPunchMessagePairAleadyStarted];
						[self sendPacketToPeerWithProxy:[JsonHelper toData:dict] host:fromHost port:fromPort];
					}
				}
			}
			PNDebugNotice(PNLOG_CAT_INTERNET_MATCH,([NSString stringWithFormat:@"Received invalid packet from %@", fromHost]));
			PNNetworkLog(@"Received invalid packet from unknown host.");
			// Don't stop receive loop
			[self recvLoop];
			return YES;
		}
		
		if(![PNPacketFireWall isServerAddress:fromHost]) {
			PNPacket *packet = [PNPacket createWithPackedData:data];
			[packet unpack];
			if(kPNIsPacketCommand(packet.theFlag, kPNPacketFlagCommandUser)) {
				PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Received invalid packet");
				[self recvLoop];
				return YES;
			}
			
			if(kPNIsPacketType(packet.theFlag, kPNPacketFlagHeatbeat) && kPNIsPacketMethod(packet.theFlag, kPNPacketFlagMethodPing)) {
				NSData* data = [NSData dataWithBytes:"{}" length:2];
				int connection	= kPNGameSessionUnreliable;
				int type		= kPNPacketFlagHeatbeat;
				int command		= kPNPacketFlagCommandSystem;
				int method		= kPNPacketFlagMethodPong;
				int theFlag		= connection|type|command|method;
				
				PNPacket* packet	= [PNPacket create];
				double time			= CFAbsoluteTimeGetCurrent();
				packet.data			= data;
				packet.theFlag		= theFlag;
				packet.timestamp	= time;
				packet.address		= fromHost;
				packet.port			= fromPort;
				
				[packet pack];
				
				[self performSelectorOnConnectionThread:@selector(CALLBACK_SendPacketOnUDPThread:socket:host:port:)
											withObjects:[NSArray arrayWithObjects:packet.packedData,sock,fromHost,[NSNumber numberWithInt:fromPort],nil]];
				[self recvLoop];
				return YES;
			} else if (kPNIsPacketType(packet.theFlag, kPNPacketFlagHeatbeat) && kPNIsPacketMethod(packet.theFlag, kPNPacketFlagMethodPong)) {
				if(cRoom) {
					for(PNPeer* peer in [cRoom.peers allValues]) {
						if([peer.address isEqualToString:fromHost] && peer.udpPort == fromPort) {
							peer.packetTimeStamp = CFAbsoluteTimeGetCurrent();
						}
					}
				}
				[self recvLoop];
				return YES;
			}
			
			data = packet.data;
		}
	}
	
	NSString* received;
	NSDictionary* json;
	received	= [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	json		= [received JSONValue];
	
	
	PNCLog(PNLOG_CAT_UDP, @"DidReceive: %@", received);
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"RecvUDP:[%@]  from %@:%d",received,fromHost,fromPort);
	
	if ([JsonHelper isApiSuccess:json])
	{
		NSString *does = [json objectForKey:@"do"];
		if (does)
		{
			// NAT check protocol.
			if ([does isEqualToString:kPNPunchMessageStunAck]) // Server
			{
				PNLog(@"stun.ack");
				if (!self.natHost)
				{
					NSArray *nat = [[json objectForKey:@"you"] componentsSeparatedByString:@":"];
					self.natHost = [nat objectAtIndex:0];
					self.natPort = [[nat objectAtIndex:1] integerValue];
					
					self.selfPeer = [PNPeer createPeerWithUser:[PNUser currentUser]];
					self.selfPeer.address = self.natHost;
					self.selfPeer.udpPort = self.natPort;
				}
				
				NSData *data = [kPNPunchMessageStunAck dataUsingEncoding:NSUTF8StringEncoding];
				PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"SendUDP:[%@] to %@:%d",kPNPunchMessageStunAck,fromHost,fromPort);
				[self sendPacketToServer:data host:fromHost port:fromPort withTTL:kPNStunDefaultPacketTTL];
			}
			else if ([does isEqualToString:kPNPunchMessageStunSymmetric]) // Server
			{
				PNLog(@"stun.symmetric");
				NSString *command = [NSString stringWithFormat:@"%@ %@:%d",kPNPunchMessageStunSymmetric, natHost, natPort];
				NSData *data = [command dataUsingEncoding:NSUTF8StringEncoding];
				
				NSArray *to = [[json objectForKey:@"to"] componentsSeparatedByString:@":"];
				NSString *to_host = [to objectAtIndex:0];
				NSInteger to_port = [[to objectAtIndex:1] integerValue];
				
				PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"SendUDP:[%@] to %@:%d",command,to_host,to_port);
				
				
				// Dummy Symmetric Protocol.
				if(false) {
					int sock;
					
					{
						struct sockaddr_in addr;
						struct in_addr bindAddr;
						inet_aton([natHost UTF8String], &bindAddr);
						sock = socket(AF_INET, SOCK_DGRAM, 0);
						addr.sin_family = AF_INET;
						addr.sin_port = htons(12345);
						addr.sin_addr.s_addr = bindAddr.s_addr;
						bind(sock, (struct sockaddr *)&addr, sizeof(addr));
					}
					{
						
						struct sockaddr_in addr;
						memset(&addr, 0, sizeof(addr));
						addr.sin_addr.s_addr = inet_addr([to_host UTF8String]);
						addr.sin_port = htons(to_port);
						addr.sin_family = AF_INET;
						sendto(sock, (const void*)data.bytes, (size_t)data.length, 0, (const struct sockaddr*)&addr, (socklen_t)sizeof(addr));
					}
				} else {
					[self sendPacketToServer:data host:to_host port:to_port withTTL:kPNStunDefaultPacketTTL];
				}
			}
			else if ([does isEqualToString:kPNPunchMessageStunFail]) // Server
			{
				PNLog(@"stun.fail");
			}
			else if([does isEqualToString:kPNPunchMessageStunDone]) // Server
			{
				PNLog(@"stun.done");
				// Detected NAT.
				NSString* nat = [json objectForKey:@"verdict"];
				PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"NAT TYPE : %@",nat);
				
				if([nat compare:kPNStringNatTypeNoNat] == 0) {
					self.natType = kPNNoNAT;
				} else if ([nat compare:kPNStringNatTypeFullCone] == 0) {
					self.natType = kPNFullConeNAT;
				} else if ([nat compare:kPNStringNatTypeRestrictedCone] == 0) {
					self.natType = kPNRestrectedConeNAT;
				} else if ([nat compare:kPNStringNatTypePortRestrictedCone] == 0) {
					self.natType = kPNPortRestrectedConeNAT;
				} else if ([nat compare:kPNStringNatTypeSymmetric] == 0) {
					self.natType = kPNSymmetricNAT;
				} else if ([nat compare:kPNStringNatTypeIPMasquerade] == 0) {
					self.natType = kPNIPMasquerade;
				}
				
				
				NSObject<PNUDPConnectionServiceDelegate>* delegateObject = (NSObject*)delegate;
				if([delegateObject respondsToSelector:@selector(stunService:didDetecteNat:)])
					[delegateObject performSelectorOnMainThread:@selector(stunService:didDetecteNat:)
													withObjects:[NSArray arrayWithObjects:self,[NSNumber numberWithInt:self.natType],nil]];
				
				self.isChecked = YES;
				// TODO delegate経由に切り替える
				id<PNManagerDelegate> managerDelegate = [PNManager sharedObject].delegate;
				if (managerDelegate && [managerDelegate respondsToSelector:@selector(managerDidDoneNatCheck:)]){
					[managerDelegate managerDidDoneNatCheck:[PNManager sharedObject]];
				}
			}
			
			
			
			
			
			
			
			// Peer to Peer network protocol.
			// Self connection is symmetric NAT environment.
			else if ([does isEqualToString:kPNPunchMessagePeerToPeerSymmetricInitiate]) // Peer
			{
				PNLog(@"p2p.symmetric.initiate");
				NSString *endpoint = [[json objectForKey:@"responder"] objectForKey:@"endpoint"];
				NSArray *responder = [endpoint componentsSeparatedByString:@":"];
				NSMutableDictionary *dict = [JsonHelper buildDoDictionary:kPNPunchMessagePeerToPeerSymmetricRespond];
				NSString* opponentIp = [responder objectAtIndex:0];
				NSString* opponentUdpPort = [responder objectAtIndex:1];
				
				[dict setObject:[json objectForKey:@"responder"] forKey:@"responder"];
				[dict setObject:[json objectForKey:@"pair"] forKey:@"pair"];
				
				// TODO Protocol for symmetric NAT.ディレイを入れないと相手のパケットファイヤーウォールにブロックされる場合がある。
				[self sendPacketToPeerWithProxy:[JsonHelper toData:dict] host:[responder objectAtIndex:0] port:[[responder objectAtIndex:1] integerValue]];
				
				// 相手のパケットを受け付けるように。
				if(kPNUDPPacketFirewall)
					[PNPacketFireWall allowIPv4:opponentIp port:[opponentUdpPort intValue]];
			}
			// TODO SymmetricNATはまだ未対応（最後にパケットが通らなくなる不具合？がある）
			else if ([does isEqualToString:kPNPunchMessagePeerToPeerSymmetricRespond]) // Peer or Server
			{
				PNLog(@"p2p.symmetric.respond");
				NSMutableDictionary *dict;
				
				BOOL isReady			= NO;
				NSNumber* pairKey		= [json objectForKey:@"pair"];
				NSDictionary* initiator = [json objectForKey:@"initiator"];
				NSDictionary* responder = [json objectForKey:@"responder"];
				NSMutableDictionary* cacheInitiator = [paringTableForSymmetric objectForKey:pairKey];
				
				if(cacheInitiator && (NSNull*)cacheInitiator != [NSNull null]) {
					PNLog(@"isReady");
					isReady = YES;
				} else {
					PNLog(@"dummy");
					NSMutableDictionary* dmy = [NSMutableDictionary dictionary];
					[paringTableForSymmetric setObject:dmy forKey:pairKey];
				}
				
				if(initiator && (NSNull*)initiator != [NSNull null]) {
					PNLog(@"initiator");
					cacheInitiator = [paringTableForSymmetric objectForKey:pairKey];
					[cacheInitiator setObject:[initiator objectForKey:@"session"] forKey:@"session"];
					[paringTableForSymmetric setObject:cacheInitiator forKey:pairKey];
					
					if(kPNUDPPacketFirewall) {
						NSString* endpoint = [initiator objectForKey:@"endpoint"];
						NSArray* addressAndPort = [endpoint componentsSeparatedByString:@":"];
						NSString* address = [addressAndPort objectAtIndex:0];
						NSString* port = [addressAndPort objectAtIndex:0];
						[PNPacketFireWall allowIPv4:address port:[port intValue]];
					}
					
				} else {
					PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"[P2P punch start] received.");
					cacheInitiator = [paringTableForSymmetric objectForKey:pairKey];
					dict = [JsonHelper buildDoDictionary:kPNPunchMessagePeerToPeerPunchStart];
					[dict setObject:pairKey forKey:@"pair"];
					[dict setObject:responder forKey:@"opponent"];
					
					NSString* endpoint = [NSString stringWithFormat:@"%@:%d",fromHost,fromPort];
					[cacheInitiator setObject:endpoint forKey:@"endpoint"];
					
					// Send to opponent
					[udpSocket sendData:[JsonHelper toData:dict] toHost:fromHost port:fromPort withTimeout:10.0 tag:kPNStunUDPConnectionTagPacket];
					[self sendPacketToPeerWithProxy:[JsonHelper toData:dict] host:fromHost port:fromPort];
					
				}
				
				if(isReady) {
					PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"[P2P punch start] received.");
					
					cacheInitiator = [paringTableForSymmetric objectForKey:pairKey];
					dict = [JsonHelper buildDoDictionary:kPNPunchMessagePeerToPeerPunchStart];
					[dict setObject:pairKey forKey:@"pair"];
					[dict setObject:cacheInitiator forKey:@"opponent"];
					
					PNUDPConnectionService* udpService = [PNUDPConnectionService sharedObject];
					// Send to self.
					[self sendPacketToPeerWithProxy:[JsonHelper toData:dict] host:udpService.bindAddress port:[udpSocket localPort]];
				}
			}
			else if ([does isEqualToString:kPNPunchMessagePeerToPeerPunchStart]) // Peer or Server
			{
				PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"[P2P punch start] received.");
				
				PNLog(@"You received opponent hole punching request.");
				{
					// Opponent information.
					int pairId;
					
					NSString* host;
					int port;
					BOOL isJoined;
					BOOL isOwner;
					
					NSMutableDictionary* params;
					NSMutableDictionary* pairingTable;
					NSArray* opponentInformation;
					NSString* opponentEndpoint;
					NSString* opponentPublicSession;
					PNPeer* peer;
					
					params					= [[[NSMutableDictionary alloc] init] autorelease];
					pairId					= [[json objectForKey:@"pair"] intValue];
					opponentEndpoint		= [[json objectForKey:@"opponent"] objectForKey:@"endpoint"];
					opponentPublicSession	= [[json objectForKey:@"opponent"] objectForKey:@"session"];
					opponentInformation		= [opponentEndpoint componentsSeparatedByString:@":"];
					host					= [opponentInformation objectAtIndex:0];
					port					= [[opponentInformation objectAtIndex:1] integerValue];
					
					// サーバーから教えてもらったホストはAllow状態にする。
					if(kPNUDPPacketFirewall)
						[PNPacketFireWall allowIPv4:host port:port];
					
					// 部屋を作った人、あるいは昇格した人は自分をホストにする。それ以外はクライアントへ。
					self.selfPeer.isHost = cRoom.isOwner;
					
					[[NSNotificationCenter defaultCenter] postNotification:
					 [NSNotification notificationWithName:@"PNUHPEvent" object:[NSString stringWithFormat:@"Punching request with %@", opponentPublicSession]]];
					
					
					
					// セッションと紐づける。
					
					pairingTable			= cRoom.pairingTable;
					isOwner					= cRoom.isOwner;
					isJoined				= cRoom.isJoined;
					peer					= [pairingTable objectForKey:opponentPublicSession];
					if(peer == nil) {
						// 新しく入ってきた人はここでpeerを作る。
						peer = [PNPeer createPeer];
						[pairingTable setObject:peer forKey:opponentPublicSession];
					}
					
					
					peer.address			= host;
					peer.udpPort			= port;
					
					// アドレス・ポートのテーブルを作る。
					[opponents setObject:peer forKey:inetToLongLong([host UTF8String], port)];
					if(!isOwner && !isJoined) {
						[cRoom.peers setObject:peer forKey:inetToLongLong([host UTF8String], port)];
					}
					
					peer.pairingNumber	= pairId;
					
					
					// This is causing error so tentatively remove
					[params setObject:json forKey:@"json"];
					[params setObject:[NSNumber numberWithInt:1] forKey:@"count"];
					[params setObject:[NSNumber numberWithInt:kPNPunchingStart] forKey:@"state"];
					[params setObject:peer forKey:@"peer"];
					[params setObject:opponentEndpoint forKey:@"opponentEndpoint"];
					[params setObject:[NSNumber numberWithInt:pairId] forKey:@"pairId"];
					
					PNLog(@"%@", json);
					PNLog(@"Pair ID : %d", pairId);
					
					if([delegate respondsToSelector:@selector(stunService:willStartPairing:)])
						[delegate stunService:self willStartPairing:peer];
					
					// Send packet to opponent for RTT calculation.
					[self punching:[params retain]];
					
				}
			}
			// 相手からのPunchingリクエストパケット要求にたいして返信する
			else if ([does isEqualToString:kPNPunchMessagePeerToPeerPunchRequest]) // Peer
			{
				PNLog(@"p2p.punch.request");
				NSMutableDictionary *dict = [JsonHelper buildDoDictionary:kPNPunchMessagePeerToPeerPunchResponse];
				[dict setObject:[json objectForKey:@"number"]		forKey:@"number"];
				[dict setObject:selfPeer.user.username				forKey:@"name"];
				[dict setObject:getAbsoluteTime()					forKey:@"deviceTime"];
				[dict setObject:[NSNumber numberWithBool:cRoom.isOwner] forKey:@"isOwner"];
				[self sendPacketToPeerWithProxy:[JsonHelper toData:dict] host:fromHost port:fromPort];
				
				
				PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"SendUDP:[%@] to %@:%d",[dict JSONRepresentation],fromHost,fromPort);
			}
			// 相手に飛ばしたパケット要求に対してのレスポンス
			else if ([does isEqualToString:kPNPunchMessagePeerToPeerPunchResponse]) // Peer
			{
				PNLog(@"p2p.punch.response");
				NSNumber*	number; // カウンター
				PNPeer*		peer;
				NSNumber*	start;
				int			timePassed_ms;
				int			rttHalfTime,opponentDeviceTime,selfDeviceTime,subDeviceTime;
				
				// Calculate RTT
				number				= [NSNumber numberWithInt:[[json objectForKey:@"number"] intValue]];
				peer				= [opponents objectForKey:inetToLongLong([fromHost UTF8String], fromPort)];
				peer.user.username	= [json objectForKey:@"name"];
				start				= [peer.received_packets_for_rtt objectForKey:number];
				timePassed_ms		= [getAbsoluteTime() intValue] - [start intValue];
				[peer.saved_rtts addObject:[NSNumber numberWithInt:timePassed_ms]];
				
				if(!cRoom.isOwner) {
					rttHalfTime			= timePassed_ms / 2;
					opponentDeviceTime	= [[json objectForKey:@"deviceTime"] intValue];
					selfDeviceTime		= [getAbsoluteTime() intValue];
					subDeviceTime		= (opponentDeviceTime + rttHalfTime) - selfDeviceTime; // デバイス同士の時間のずれ。
					[peer.saved_NTPTimeStamps setObject:[NSNumber numberWithInt:subDeviceTime] forKey:number];
					peer.isHost		= [[json objectForKey:@"isOwner"] boolValue];
				}
			}
			else if([does isEqualToString:kPNPunchMessagePairFailed])// Server
			{
				PNNetworkError* e	= [[[PNNetworkError alloc] init] autorelease];
				e.errorType			= kPNStunPunchingFailed;
				e.message			= @"Punching failed.";
				
				NSObject* delegateObject = delegate;
				if([delegateObject respondsToSelector:@selector(stunService:didError:)])
					[delegateObject performSelectorOnMainThread:@selector(stunService:didError:) withObjects:[NSArray arrayWithObjects:self,e,nil]];
			}
			else if([does isEqualToString:kPNPunchMessagePairDone])// Server
			{
				NSString* opponentPublicSession = [json objectForKey:@"with"];
				PNPeer* peer = [cRoom.pairingTable objectForKey:opponentPublicSession];
				
				[[NSNotificationCenter defaultCenter] postNotification:
				 [NSNotification notificationWithName:@"PNUHPEvent" object:[NSString stringWithFormat:@"Punching done with %@", opponentPublicSession]]];
				
				NSObject* delegateObject = delegate;
				if([delegateObject respondsToSelector:@selector(stunService:didDonePairing:)])
					[delegateObject performSelectorOnMainThread:@selector(stunService:didDonePairing:) withObjects:[NSArray arrayWithObjects:self,peer,nil]];
			}
			else if([does isEqualToString:kPNPunchMessagePairAleadyStarted]) // 相手のペアリング作業が終わっていた場合。
			{
				// 自分がメッセージを飛ばした分だけ連続で通知されるので注意。
				PNWarn(@"%@",kPNPunchMessagePairAleadyStarted);
				//				NSObject* delegateObject = delegate;
				//				if([delegateObject respondsToSelector:@selector(stunService:didDonePairing:)])
				//					[delegateObject performSelectorOnMainThread:@selector(stunService:didDonePairing:) withObjects:[NSArray arrayWithObjects:self,peer,nil]];
			}
			else
			{
				PNLog(@"Received unknown message.");
			}
		}
	}
	
	// Don't stop receive loop
	[self recvLoop];
	return YES;
}

- (void)punching:(NSMutableDictionary*)params
{
	NSNumber* state = [params objectForKey:@"state"];
	NSNumber* count = [params objectForKey:@"count"];
	PNPeer* peer	= [params objectForKey:@"peer"];
	switch([state intValue])
	{
		case kPNPunchingStart:{
			NSMutableDictionary *dict = [JsonHelper buildDoDictionary:kPNPunchMessagePeerToPeerPunchJab];
			[self sendPacketToPeer:[JsonHelper toData:dict] host:peer.address port:peer.udpPort withTTL:kPNTTLSpiblock];
			PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"SendUDP JAB:[%@] to %@:%d TTL:(%d)",[dict JSONRepresentation],peer.address,peer.udpPort,kPNTTLSpiblock);
			
			[params setObject:[NSNumber numberWithInt:kPNPunchingSendPacket] forKey:@"state"];
			[self performSelector:@selector(punching:) withObject:[params retain] afterDelay:kPNPunchingTTLDelayTime];
		}break;
		case kPNPunchingSendPacket:{
			if([count intValue] <= kPNPunchingPacketCount) {
				NSMutableDictionary *dict = [JsonHelper buildDoDictionary:kPNPunchMessagePeerToPeerPunchRequest];
				[dict setObject:count forKey:@"number"];
				[self sendPacketToPeerWithProxy:[JsonHelper toData:dict] host:peer.address port:peer.udpPort];
				PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"SendUDP:[%@] to %@:%d",[dict JSONRepresentation],peer.address,peer.udpPort);
				[peer.received_packets_for_rtt setObject:getAbsoluteTime() forKey:[NSNumber numberWithInt:[count intValue]]];
				
				[params setObject:[NSNumber numberWithInt:[count intValue]+1] forKey:@"count"];
				[params setObject:[NSNumber numberWithInt:kPNPunchingSendPacket] forKey:@"state"];
				[self performSelector:@selector(punching:) withObject:[params retain] afterDelay:kPNPunchingRTTDelayTime];
			} else {
				[params setObject:[NSNumber numberWithInt:kPNPunchingEnd] forKey:@"state"];
				[self performSelector:@selector(punching:) withObject:[params retain] afterDelay:kPNPunchingReportDelayTime];
			}
		}break;
		case kPNPunchingEnd:{
			[self reportResult:params];
		}break;
	}
	[params release];
}

- (void)reportResult:(NSMutableDictionary*)params
{
	PNPeer* peer = [params objectForKey:@"peer"];
	NSArray* rttTimes = peer.saved_rtts;
	int rttAverage = -1;
	int averageSubDeviceTime = 0;
	NSNumber* rtt;
	NSMutableDictionary *dict;
	
	// RTTの平均値を求める
	if([rttTimes count]) {
		for(NSNumber *rtt in rttTimes) {
			rttAverage += [rtt intValue];
		}
		rttAverage /= (int)[rttTimes count];
		peer.rto = peer.rtt = rttAverage;
	}
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"RTT is %dms, user:%@ %@:%d",rttAverage,peer.user.username,peer.address,peer.udpPort);
	
	// デバイスのい時間差を平均で求める。
	if([peer.saved_NTPTimeStamps count]) {
		int count = [peer.saved_NTPTimeStamps count];
		for(NSNumber* time in [peer.saved_NTPTimeStamps allValues])
			averageSubDeviceTime += [time intValue];
		peer.subDeviceTime = averageSubDeviceTime / count;
		int d = peer.subDeviceTime%1000;
		d = d<0 ? -d : d;
		PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Time difference between devices is %d.%03dsec, user:%@ %@:%d",peer.subDeviceTime/1000,d,peer.user.username,peer.address,peer.udpPort);
	}
	
	
	
	// サーバーに対してレポートを行う。
	rtt = [NSNumber numberWithInteger:rttAverage];
	dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[rttTimes count] > 0 ? @"ok" : @"ng", @"status", nil];
	[dict setObject:[params objectForKey:@"opponentEndpoint"] forKey:@"with"];
	[dict setObject:[NSNumber numberWithInt:[rttTimes count]] forKey:@"count"];
	if([rtt intValue] > self.connectionPermissibleRangeSpeed){
		[dict setObject:[NSNumber numberWithInt:-1] forKey:@"rtt"];	
	} else {
		[dict setObject:rtt forKey:@"rtt"];	
	}
	[dict setObject:[params objectForKey:@"pairId"] forKey:@"pair"];
	[dict setObject:[PNUser session] forKey:@"session"];
	
	NSString *report = [dict JSONRepresentation];
	NSData *data = [[NSString stringWithFormat:@"%@ %@",kPNPunchMessagePairReport,report] dataUsingEncoding:NSUTF8StringEncoding];
	[self sendPacketToServer:data host:kPNPrimaryHost port:kPNUDPPrimaryPort withTTL:kPNStunDefaultPacketTTL];
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"SendUDP:[%@] to %@:%d",[NSString stringWithFormat:@"%@ %@",kPNPunchMessagePairReport,report],kPNPrimaryHost,kPNUDPPrimaryPort);
	
	
	peer.rtt = [rtt intValue];
	
	// 使ったコンテナはここでクリア
	[peer.received_packets_for_rtt removeAllObjects];
	[peer.saved_rtts removeAllObjects];
	[peer.saved_NTPTimeStamps removeAllObjects];
	
//	[PNLogger logRttValue:peer.rtt forTarget:[NSString stringWithFormat:@"%@(%@)",peer.user.username, peer.address]];
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Sending UHP Result to server...%@", report);
	
	NSObject* delegateObject = delegate;
	if([delegateObject respondsToSelector:@selector(stunService:didReport:)])
		[delegateObject performSelectorOnMainThread:@selector(stunService:didReport:)
										withObjects:[NSArray arrayWithObjects:self,report,nil]];
}

-(void)CALLBACK_SendPacketOnUDPThread:(NSData*)data socket:(AsyncUdpSocket*)aUDPSocket host:(NSString*)aHost port:(NSNumber*)aPort
{
	[aUDPSocket sendData:data toHost:aHost port:[aPort intValue] withTimeout:5.0 tag:kPNStunUDPConnectionTagPacket];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock
didNotReceiveDataWithTag:(long)tag
		 dueToError:(NSError *)error
{
	NSObject* delegateObject = delegate;
	switch(tag) {
		case kPNStunUDPConnectionTagDummyPacket:{
			PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
			e.message = (NSString*)error;
			e.errorType = kPNUDPErrorUnknown;
			
			if([delegateObject respondsToSelector:@selector(stunService:didError:)])
				[delegateObject performSelectorOnMainThread:@selector(stunService:didReport:)
												withObjects:[NSArray arrayWithObjects:self,e,nil]];
		}break;
		case kPNStunUDPConnectionTagPacket:{
			[udpSocket receiveWithTimeout:kPNUDPReceiveTimeout tag:kPNStunUDPConnectionTagPacket];
		}break;
		default:{
			PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
			e.message = (NSString*)error;
			e.errorType = kPNUDPErrorUnknown;
			
			if([delegateObject respondsToSelector:@selector(stunService:didError:)])
				[delegateObject performSelectorOnMainThread:@selector(stunService:didReport:)
												withObjects:[NSArray arrayWithObjects:self,e,nil]];
		}break;
			
	}
	PNCLog(PNLOG_CAT_UDP, @"PNUDPConnectionService DidNotReceive: %@", error);
}





+ (PNUDPConnectionService*)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init];
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			[_sharedInstance performSelectorOnConnectionThreadSync:@selector(CALLBACK_CreateUDPSocketOnUDPThread:)
														withObject:nil];
			return _sharedInstance;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;
}

- (void)release
{
}

- (id)autorelease
{
	return self;
}


@end

