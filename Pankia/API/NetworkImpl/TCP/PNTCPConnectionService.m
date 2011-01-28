#include <sys/socket.h>
#import "PNTCPConnectionService.h"
#import "PNServiceNotifyDelegate.h"
#import "PNNetworkError.h"
#import "PNLogger+Package.h"
#import "PNGlobal.h"


#define kPNTCPServiceReadTag			0x01
#define kPNTCPServiceWriteTag			0x01
#define kPNTCPServiceConnectionTimeout	60
#define kPNTCPServiceReadTimeout		60
#define kPNTCPServiceWriteTimeout		60
#define kPNTCPServicePingAfterDelay		55

#define kPNTCPServiceCommandObserve		@"observe"
#define kPNTCPServiceCommandTouch		@"touch"
#define kPNTCPServiceCommandDelimiter	@"\0"


#define kPNTCPServicePingStateNone			0x00
#define kPNTCPServicePingStateStart			0x01
#define kPNTCPServicePingStateBussy			0x02


@implementation PNTCPConnectionService
@synthesize socket;
@synthesize delegates;
@synthesize pingState;
@synthesize transactionID;
@synthesize isAlive;

static PNTCPConnectionService *_sharedInstance = nil;

-(id)init
{
	if(self = [super init]) {
		self.socket = nil;
		self.delegates = [NSMutableDictionary dictionary];
		pingState = kPNTCPServicePingStateNone;
		heartbeatLastTimeStamp = 0;
		self.transactionID = 0;
		self.isAlive = NO;
	}
	return self;
}

+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone{return self;}

- (id)retain{return self;}

- (unsigned)retainCount{return UINT_MAX;}

- (void)release {}

- (id)autorelease {return self;}


+ (PNTCPConnectionService*)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (void) setObserver:(id)delegate key:(NSString*)key {
	[[PNTCPConnectionService sharedObject].delegates setObject:delegate forKey:key];
}

+ (void) removeAllObserver
{
	[[PNTCPConnectionService sharedObject].delegates removeAllObjects];
}

+ (void) removeObserver:(NSString*)key
{
	if(key) [[PNTCPConnectionService sharedObject].delegates removeObjectForKey:key];
}

static NSData *packMessage(NSString* mes) {
	NSString	*stream	= [NSString stringWithFormat:@"%@%@",
						   mes,
						   kPNTCPServiceCommandDelimiter];
	NSData		*data	= [stream dataUsingEncoding:NSUTF8StringEncoding];
	return data;
}

+ (BOOL) startWithSession:(NSString*)session
{
	PNTCPConnectionService *instance = [PNTCPConnectionService sharedObject];
	if(instance.socket) {
		[instance.socket setDelegate:nil];
		[instance.socket disconnect];
		instance.socket = nil;
	}
	instance.socket = [[[AsyncSocket alloc] initWithDelegate:instance] autorelease];
	BOOL isConnected = [instance.socket connectToHost:kPNPrimaryHost
						onPort:kPNTCPBackchannelPort
						withTimeout:kPNTCPServiceConnectionTimeout
						error:nil];
	if(!isConnected) return NO;
	instance.isAlive = YES;
	
	[instance.socket readDataToData:[AsyncSocket ZeroData] withTimeout:kPNTCPServiceReadTimeout tag:kPNTCPServiceReadTag];

	
	// Create observe message.
	NSString	*stream	= [NSString stringWithFormat:@"%@ %@",
						   kPNTCPServiceCommandObserve,
						   session];
	NSData		*startMessage = packMessage(stream);
	// Send observe command to server.

	[instance.socket writeData:startMessage
	 withTimeout:kPNTCPServiceConnectionTimeout
	 tag:kPNTCPServiceWriteTag];
	
	PNLog(@"Connected to TCP server.");
	PNLog(@"Send data : \n TCP < %@",stream);
	
	if(instance.pingState == kPNTCPServicePingStateNone || instance.pingState == kPNTCPServicePingStateBussy) {
		instance.pingState = kPNTCPServicePingStateStart;
		instance.transactionID++;
		[instance ping:[NSNumber numberWithInt:instance.transactionID]];
	}
	return YES;
}

-(void)ping:(NSNumber*)aTransactionID
{
	double now = CFAbsoluteTimeGetCurrent();
	if(self.isAlive && self.transactionID == [aTransactionID intValue] && now - heartbeatLastTimeStamp >= kPNTCPServicePingAfterDelay) {
		PNLog(@"TCP PING");
		if(pingState == kPNTCPServicePingStateBussy || pingState == kPNTCPServicePingStateNone)
			return;
		PNLog(@"Send PING");
		//touch
		NSData *touchMessage = packMessage(kPNTCPServiceCommandTouch);
		[self.socket writeData:touchMessage
				   withTimeout:kPNTCPServiceConnectionTimeout
						   tag:kPNTCPServiceWriteTag];
		
		heartbeatLastTimeStamp = CFAbsoluteTimeGetCurrent();
		[self performSelector:@selector(ping:) withObject:aTransactionID afterDelay:kPNTCPServicePingAfterDelay+0.1];
	}
}

-(void) stop
{
	self.isAlive = NO;
	transactionID++;
	[socket disconnect];
	self.socket = nil;
	pingState = kPNTCPServicePingStateNone;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	PNLog(@"willDisconnectWithError\n");
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	pingState = kPNTCPServicePingStateNone;
	NSArray *ds = [delegates allValues];
	for(id<PNTCPConnectionServiceDelegate,NSObject> delegate in ds) {
		if([delegate respondsToSelector:@selector(didDisconnectWithService:)])
			[delegate didDisconnectWithService:self];
	}
	
	PNLog(@"onSocketDidDisconnect\n");
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	PNLog(@"didAcceptNewSocket\n");
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket
{
	PNLog(@"wantsRunLoopForNewSocket\n");
	return nil;
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
	PNLog(@"onSocketWillConnect\n");
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSArray *ds = [delegates allValues];
	for(id<PNTCPConnectionServiceDelegate,NSObject> delegate in ds) {
		if([delegate respondsToSelector:@selector(didConnectWithService:)])
			[delegate didConnectWithService:self];
	}
	
	PNLog(@"didConnectToHost\n");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSArray *ds = [delegates allValues];
	for(id<PNServiceNotifyDelegate,NSObject> delegate in ds) {
		if([delegate respondsToSelector:@selector(notify:userInfo:)])
			[delegate notify:[NSString stringWithUTF8String:data.bytes] userInfo:nil];
	}
	
	
	[sock readDataToData:[AsyncSocket ZeroData] withTimeout:kPNTCPServiceReadTimeout tag:kPNTCPServiceReadTag];
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(CFIndex)partialLength tag:(long)tag
{
	PNLog(@"didReadPartialDataOfLength\n");
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	PNLog(@"didWriteDataWithTag\n");
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(CFIndex)length
{
	pingState = kPNTCPServicePingStateBussy;
	PNLog(@"TCP TIMEOUT ERROR : shouldTimeoutReadWithTag bytesDone %d\n",length);
	NSArray *ds = [delegates allValues];
	PNError* error = [PNNetworkError errorWithType:kPNTCPErrorTimeout message:@"Timeout error at reading method."];
	for(id<PNTCPConnectionServiceDelegate,NSObject> delegate in ds) {
		if([delegate respondsToSelector:@selector(service:didFailWithError:)]){
			[delegate service:self didFailWithError:error];
			PNLog(@"Check responds to selector service:didFailWithError: of %@.(TRUE)",[delegate class]);
		} else {
			PNLog(@"Check responds to selector service:didFailWithError: of %@.(FALSE)",[delegate class]);
		}
	}
	
	[sock disconnect];
	
	return 0;
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(CFIndex)length
{
	pingState = kPNTCPServicePingStateBussy;
	PNLog(@"TCP TIMEOUT ERROR : shouldTimeoutWriteWithTag bytesDone\n");
	
	NSArray *ds = [delegates allValues];
	PNError* error = [PNNetworkError errorWithType:kPNTCPErrorTimeout message:@"Timeout error at writing method."];
	for(id<PNTCPConnectionServiceDelegate,NSObject> delegate in ds) {
		if([delegate respondsToSelector:@selector(service:didFailWithError:)]){
			[delegate service:self didFailWithError:error];
			PNLog(@"Check responds to selector service:didFailWithError: of %@.(TRUE)",[delegate class]);
		} else {
			PNLog(@"Check responds to selector service:didFailWithError: of %@.(FALSE)",[delegate class]);
		}
	}
	
	[sock disconnect];
	
	return 0;
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
	PNLog(@"didSecure\n");
}

@end
