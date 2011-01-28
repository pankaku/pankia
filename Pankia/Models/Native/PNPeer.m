#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNPacket.h"
#import "PNMembershipModel.h"
#import "PNUDPConnectionService.h"
#import "PNGlobal.h"

extern PNConnectionLevel getConnectionLevel(int);

@implementation PNPeer(Package)
@dynamic user;
@dynamic address;
@dynamic rto;
@dynamic isHost;
@dynamic speedLevel;

-(void)setUser:(PNUser *)arg { PNSETPROP(user,arg); }
-(void)setAddress:(NSString *)arg { PNSETPROP(address,arg); }
-(void)setRto:(float)arg { PNPSETPROP(rto,arg); }
-(void)setIsHost:(BOOL)arg { PNPSETPROP(isHost,arg); }

-(PNUser*)user { PNGETPROP(PNUser*,user); }
-(NSString*)address { PNGETPROP(NSString*,address); }
-(float)rto { PNGETPROP(float,rto); }
-(BOOL)isHost { PNGETPROP(BOOL,isHost); }


-(PNConnectionLevel)speedLevel
{
	if(self.rtt != -1) {
		return getConnectionLevel(self.rtt);
	} else if(self.icmpRtt != -1) {
		return getConnectionLevel(self.icmpRtt);
	}
	return getConnectionLevel(-1);
}


@dynamic udpPort;
@dynamic rtt;
@dynamic srtt;
@dynamic rttvar;
@dynamic icmpRtt;
@dynamic packetTimeStamp;
@dynamic received_packets_for_rtt;
@dynamic saved_rtts;
@dynamic saved_NTPTimeStamps;
@dynamic subDeviceTime;
@dynamic joinedNumber;
@dynamic sendQueue;
@dynamic readQueue;
@dynamic sentPackets;
@dynamic readPackets;
@dynamic sendSequenceCounter;
@dynamic readSequenceCounter;
@dynamic syncPackets;
@dynamic isConnecting;
@dynamic rematchFlag;
@dynamic receivedRematchMessage;
@dynamic pairingNumber;

-(void)setUdpPort:(int)arg { PNPSETPROP(udpPort,arg); }
-(void)setRtt:(float)arg { PNPSETPROP(rtt,arg); }
-(void)setSrtt:(float)arg { PNPSETPROP(srtt,arg); }
-(void)setRttvar:(float)arg { PNPSETPROP(rttvar,arg); }
-(void)setIcmpRtt:(float)arg { PNPSETPROP(icmpRtt,arg); }
-(void)setPacketTimeStamp:(double)arg { PNPSETPROP(packetTimeStamp,arg); }
-(void)setSaved_rtts:(NSMutableArray *)arg { PNSETPROP(saved_rtts,arg); }
-(void)setReceived_packets_for_rtt:(NSMutableDictionary *)arg { PNSETPROP(received_packets_for_rtt,arg); }
-(void)setSaved_NTPTimeStamps:(NSMutableDictionary *)arg { PNSETPROP(saved_NTPTimeStamps,arg); }
-(void)setSubDeviceTime:(int)arg { PNPSETPROP(subDeviceTime,arg); }
-(void)setJoinedNumber:(int)arg { PNPSETPROP(joinedNumber,arg); }
-(void)setSendQueue:(NSMutableArray *)arg { PNSETPROP(sendQueue,arg); }
-(void)setReadQueue:(NSMutableArray *)arg { PNSETPROP(readQueue,arg); }
-(void)setSentPackets:(NSMutableArray *)arg { PNSETPROP(sentPackets,arg); }
-(void)setReadPackets:(NSMutableArray *)arg { PNSETPROP(readPackets,arg); }
-(void)setSendSequenceCounter:(int)arg { PNPSETPROP(sendSequenceCounter,arg); }
-(void)setReadSequenceCounter:(int)arg { PNPSETPROP(readSequenceCounter,arg); }
-(void)setSyncPackets:(NSMutableDictionary *)arg { PNSETPROP(syncPackets,arg); }
-(void)setIsConnecting:(BOOL)arg { PNPSETPROP(isConnecting,arg); }
-(void)setRematchFlag:(BOOL)arg { PNPSETPROP(rematchFlag,arg); }
-(void)setReceivedRematchMessage:(BOOL)arg { PNPSETPROP(receivedRematchMessage,arg); }
-(void)setPairingNumber:(int)arg { PNPSETPROP(pairingNumber,arg); }

-(int)udpPort { PNGETPROP(int,udpPort); }
-(float)rtt { PNGETPROP(float, rtt); }
-(float)srtt { PNGETPROP(float, srtt); }
-(float)rttvar { PNGETPROP(float, rttvar); }
-(float)icmpRtt { PNGETPROP(float, icmpRtt); }
-(double)packetTimeStamp { PNGETPROP(double, packetTimeStamp); }
-(NSMutableDictionary *)received_packets_for_rtt { PNGETPROP(NSMutableDictionary*, received_packets_for_rtt); }
-(NSMutableArray *)saved_rtts { PNGETPROP(NSMutableArray*, saved_rtts); }
-(NSMutableDictionary *)saved_NTPTimeStamps { PNGETPROP(NSMutableDictionary*, saved_NTPTimeStamps); }
-(int)subDeviceTime { PNGETPROP(int, subDeviceTime); }
-(int)joinedNumber { PNGETPROP(int, joinedNumber); }
-(NSMutableArray *)sendQueue { PNGETPROP(NSMutableArray*, sendQueue); }
-(NSMutableArray *)readQueue { PNGETPROP(NSMutableArray*, readQueue); }
-(NSMutableArray *)sentPackets { PNGETPROP(NSMutableArray*, sentPackets); }
-(NSMutableArray *)readPackets { PNGETPROP(NSMutableArray*, readPackets); }
-(int)sendSequenceCounter { PNGETPROP(int, sendSequenceCounter); }
-(int)readSequenceCounter { PNGETPROP(int, readSequenceCounter); }
-(NSMutableDictionary *)syncPackets { PNGETPROP(NSMutableDictionary*, syncPackets); }
-(BOOL)isConnecting { PNGETPROP(BOOL, isConnecting); }
-(BOOL)rematchFlag { PNGETPROP(BOOL, rematchFlag); }
-(BOOL)receivedRematchMessage { PNGETPROP(BOOL, receivedRematchMessage); }
-(int)pairingNumber { PNGETPROP(int, pairingNumber); }

+(PNPeer*)createPeer
{
	PNPeer *peer;
	PNUser *user;
	peer = [[[PNPeer alloc] init] autorelease];
	user = [[[PNUser alloc] init] autorelease];
	peer.user = user;
	return peer;
}

+(PNPeer*)createPeerWithUser:(PNUser *)user
{
	PNPeer*		peer;
	peer		= [[[PNPeer alloc] init] autorelease];
	peer.user	= user;
	return peer;
}

- (void) setMembershipModel:(PNMembershipModel*)aModel
{
	self.address = aModel.ip;
	self.user.publicSessionId = aModel.id;
	[self.user updateFieldsFromUserModel:aModel.user];
}
@end


@implementation PNPeer
@dynamic user;
@dynamic address;
@dynamic rto;
@dynamic isHost;
@dynamic speedLevel;
	
- (id) init {
	if (self = [super init]) {
		self.user			= nil;
		self.address		= nil;
		self.udpPort		= -1;
		self.rto			= kPNGameSessionDefaultRTO;
		self.rtt			= -1;
		self.srtt			= 0;
		self.rttvar			= 0;
		self.icmpRtt		= -1;

		self.packetTimeStamp = -1;

		
		self.received_packets_for_rtt	= [NSMutableDictionary dictionary];
		self.saved_NTPTimeStamps		= [NSMutableDictionary dictionary];
		self.saved_rtts					= [NSMutableArray array];
		self.subDeviceTime				= 0;
		
		self.isHost			= NO;
		
		self.joinedNumber	= -1;
		
		self.sendQueue		= [NSMutableArray array];
		self.readQueue		= [NSMutableArray array];
		self.sentPackets	= [NSMutableArray array];
		self.readPackets	= [NSMutableArray array];
		self.sendSequenceCounter	= 0;
		self.readSequenceCounter	= 0;
		self.syncPackets	= [NSMutableDictionary dictionary];
		
		self.isConnecting   = NO;
		self.rematchFlag	= NO;
		self.receivedRematchMessage = NO;
		self.pairingNumber	= 0;
		
		
	}
	return  self;
}

- (void)dealloc
{
	self.address		= nil;
	self.user			= nil;
	self.received_packets_for_rtt = nil;
	self.saved_NTPTimeStamps = nil;
	self.saved_rtts		= nil;
	
	
	self.sendQueue		= nil;
	self.readQueue		= nil;
	self.sentPackets	= nil;
	self.readPackets	= nil;
	self.syncPackets	= nil;
	self.isConnecting   = NO;
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:user forKey:@"user"];
}

- (NSComparisonResult)compareAsc:(PNPeer *)ac
{
	if (self.joinedNumber < ac.joinedNumber) {
		return NSOrderedAscending;
	} else if (self.joinedNumber > ac.joinedNumber) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}


@end
