#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "PNNetworkUtil.h"
#import "PNNetworkError.h"
#import "PNUDPConnectionService.h"
#import "PNPacket.h"
#import "IPAddress.h"
#import "PNGKSession.h"
#import "PNLocalizedString.h"
#import "PNLogger+Package.h"

#define kPNLocalMatchSynchronousTimeout			13.0f

#define kPNSynchronousMaxCount					10		// 同期処理の精度(10回の平均値)

#define kPNReliableProtocolCommandSync			0x0101
#define kPNSynchronousProcessingStart			0x01
#define kPNSynchronousProcessingSend			0x02
#define kPNSynchronousProcessingResponse		0x03
#define kPNSynchronousProcessingAck				0x04
#define kPNSynchronousProcessingEnd				0x05
#define kPNSynchronousProcessingDone			0x06
#define kPNSynchronousProcessingTimeoutCheck	0x07


typedef struct {
	int command;
	int state;
	int counter;
	double ts;
	double tr;
	double Ts;
	double Tr;
	double startTime;
} SyncData;

@interface PNGameSession(NTP)
- (void)synchronousProcessing;
- (void)sync:(NSData*)data opponent:(PNPeer*)peer counter:(int)cnt;
- (void)recvData:(NSData*)data from:(PNPeer*)peer;
- (void)sendSyncDataByReliable:(NSData*)data toPeers:(NSArray*)aPeers;
- (void)sendSyncDataByUnreliable:(NSData*)data toPeers:(NSArray*)aPeers;
@end

@interface PNGameSession(GameSessionIO)
-(BOOL)sendData:(NSData *)data
		toPeers:(NSArray *)ps
	 connection:(int)aConnection
		   type:(int)aType
		command:(int)aCommand
		 method:(int)aMethod;
@end

@implementation PNGameSession(NTP)

- (void)failSyncronousProcessing:(NSNumber*)syncCounter
{
	PNWarn(@"Check synchronous processing timeout. T(%d)",[syncCounter intValue]);
	if(synchronizationTransactionCounter == [syncCounter intValue]) {
		//完了したことがセットされていなければタイムアウトエラーを発生させます
		if (isSynchronousProcessingDone == NO && self.isStarted == NO){
			PNWarn(@"Error synchronous processing timeout.");
			PNError* e = [PNError errorWithType:kPNRoomErrorFailedSync
											  message:getTextFromTable(@"PNTEXT:Error:failed_in_synchronous.")];
			
//			NSObject* delegateObject = self.room.gameSession.delegate;
//			if([delegateObject respondsToSelector:@selector(room:didFailWithError:)])
//				[delegateObject performSelectorOnMainThread:@selector(room:didFailWithError:)
//												withObjects:[NSArray arrayWithObjects:self.room,e,nil]];
			
			//ビューに対してエラーを通知していくようにします。
			NSObject* roomDelegate = self.room.delegate;
			if([roomDelegate respondsToSelector:@selector(room:didFailWithError:)]){
				[roomDelegate performSelectorOnMainThread:@selector(room:didFailWithError:)
											  withObjects:[NSArray arrayWithObjects:self.room,e,nil]];
			}
			
			[self endGameSession];
		}
		isTimeoutCheckNecessary = NO;
	}
}


- (void)synchronousProcessing
{
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Start synchronous processing.");
	PNCLog(PNLOG_CAT_NTP, @"Device time synchronous processing started.");
	
	// 同期する前にGameSessionDelegateをセットする、ここでセットしてもらえれば確実に受信メソッドがコールされるようになる。
	NSObject *roomDelegateObject = self.room.delegate;
	if([roomDelegateObject respondsToSelector:@selector(room:willBeginGameSession:)])
		[roomDelegateObject performSelectorOnMainThread:@selector(room:willBeginGameSession:)
											withObjects:[NSArray arrayWithObjects:self.room,self,nil]];
	
	synchronizeCount	= 0;
	
	if(self.room.isOwner) {
		[self performSelector:@selector(startLazyNTPProcessing) withObject:nil];
	} else {
		[self performSelector:@selector(startLazyNTPProcessing) withObject:nil afterDelay:2];
	}
}

- (void)startLazyNTPProcessing
{
	SyncData syncData;
	NSData*	data;
	PNPeer* hostPeer;
	
	memset(&syncData, 0, sizeof(syncData));
	
	hostPeer			= [[self peerList] objectAtIndex:0];
	cachedCounter		= kPNSynchronousMaxCount;
	syncData.command	= kPNReliableProtocolCommandSync;
	
	isSynchronousProcessingDone = NO;	//SynchronousProcessingが完了していないことをセットしておきます
	isTimeoutCheckNecessary = YES;
	synchronizationTransactionCounter++;
	[self performSelector:@selector(failSyncronousProcessing:) withObject:[NSNumber numberWithInt:synchronizationTransactionCounter] afterDelay:kPNLocalMatchSynchronousTimeout];
	
	if(self.gameSessionType == PNInternetSession) {
		// Internet game session.
		PNLog(@"Direct start.");
		syncData.state = kPNSynchronousProcessingEnd;
		if(self.room.isOwner) {
			// 自分がホストの場合は待つ。
			PNLog(@"Self is host.");
		} else {
			PNLog(@"Self is client. Send to host(%@)",hostPeer.user.username);
			data = [NSData dataWithBytes:&syncData length:sizeof(syncData)];
			[self sendSyncDataByReliable:data toPeers:[NSArray arrayWithObjects:hostPeer,nil]];
		}
	} else {
		// Local game session.
		PNCLog(PNLOG_CAT_NTP,@"This is a local game session.");
		syncData.state = kPNSynchronousProcessingStart;
		if(self.room.isOwner) {
			// 自分がホストの場合は待つ。
			PNCLog(PNLOG_CAT_NTP, @"This is host. Wait for packet from clients.");
		} else {
			PNCLog(PNLOG_CAT_NTP, @"This is client. Send sync data to host.");
			data = [NSData dataWithBytes:&syncData length:sizeof(syncData)];
			[self sync:data opponent:hostPeer counter:kPNSynchronousMaxCount];
		}
	}
}

- (void)sendSyncDataByUnreliable:(NSData*)data toPeers:(NSArray*)aPeers
{
	[self sendData:data
		   toPeers:aPeers
		connection:kPNGameSessionUnreliable
			  type:kPNPacketFlagData
		   command:kPNPacketFlagCommandSystem
			method:kPNPacketFlagMethodSync];
}

- (void)sendSyncDataByReliable:(NSData*)data toPeers:(NSArray*)aPeers
{
	[self sendData:data
		   toPeers:aPeers
		connection:kPNGameSessionReliable
			  type:kPNPacketFlagData
		   command:kPNPacketFlagCommandSystem
			method:kPNPacketFlagMethodSync];
}

- (void) CALLBACK_SynchronousTimeoutCheck:(NSArray*)params
{
	NSData* data = [params objectAtIndex:0];
	PNPeer* peer = [params objectAtIndex:1];
	NSNumber* cnt = [params objectAtIndex:2];
	
	[self sync:data opponent:peer counter:[cnt intValue]];
}

- (void) syncTimeoutCheck:(NSData*)aData opponent:(PNPeer*)aPeer counter:(int)aCounter timeout:(double)aTimeout
{
	[self performSelector:@selector(CALLBACK_SynchronousTimeoutCheck:)
			   withObject:[NSArray arrayWithObjects:aData,aPeer,[NSNumber numberWithInt:aCounter],nil]
			   afterDelay:aTimeout];
}

- (void)sync:(NSData*)data opponent:(PNPeer*)peer counter:(int)cnt
{
	SyncData* syncData		= (SyncData*)data.bytes;
	int* command			= &(syncData->command);
	int* state				= &(syncData->state);
	int* counter			= &(syncData->counter);
	double* ts				= &(syncData->ts);
	double* tr				= &(syncData->tr);
	double* Ts				= &(syncData->Ts);
	double* Tr				= &(syncData->Tr);
	double* _startTime		= &(syncData->startTime);
	double time				= CFAbsoluteTimeGetCurrent();
	
	if(kPNReliableProtocolCommandSync == *command) {
		if(*state == kPNSynchronousProcessingStart) {
			PNCLog(PNLOG_CAT_NTP, @"PROCESSING_START");
			*counter	= cnt;
			*state		= kPNSynchronousProcessingSend;
			[self sync:data opponent:peer counter:cnt];
		} else if (*state == kPNSynchronousProcessingSend) {
			PNCLog(PNLOG_CAT_NTP, @"PROCESSING_SEND");
			SyncData sdata;
			memset(&sdata,0,sizeof(sdata));
			sdata.command		= kPNReliableProtocolCommandSync;
			sdata.state			= kPNSynchronousProcessingResponse;
			sdata.counter		= cnt;
			sdata.ts			= time;
			NSData *m			= [NSData dataWithBytes:&sdata length:sizeof(sdata)];
			[peer.syncPackets setObject:m forKey:[NSNumber numberWithInt:*counter]];
			[self sendSyncDataByUnreliable:m toPeers:[NSArray arrayWithObjects:peer,nil]];
			
			timeStamp = CFAbsoluteTimeGetCurrent();
			syncState = kPNSynchronousProcessingSend;
			cachedCounter = *counter;
			NSData *copiedData = [NSData dataWithBytes:&sdata length:sizeof(sdata)];
			SyncData *c = (SyncData *)copiedData.bytes;
			c->state = kPNSynchronousProcessingTimeoutCheck;
			[self syncTimeoutCheck:copiedData opponent:peer counter:cachedCounter timeout:2];
		} else if (*state == kPNSynchronousProcessingResponse) {
			PNCLog(PNLOG_CAT_NTP, @"PROCESSING_RESPONSE");
			*state			= kPNSynchronousProcessingAck;
			*Ts				= time;
			*Tr				= CFAbsoluteTimeGetCurrent();
			[self sendSyncDataByUnreliable:data toPeers:[NSArray arrayWithObjects:peer,nil]];
		} else if (*state == kPNSynchronousProcessingAck) {
			PNCLog(PNLOG_CAT_NTP, @"PROCESSING_ACK counter:%d",*counter);
			NSData* m			= [peer.syncPackets objectForKey:[NSNumber numberWithInt:*counter]];
			SyncData* cdata		= (SyncData*)m.bytes;
			*tr					= time;
			cdata->tr			= *tr;
			cdata->ts			= *ts;
			cdata->Tr			= *Tr;
			cdata->Ts			= *Ts;
			PNLog(@"ClientTime:%dms",(int)(((*Tr + *Ts)/2 - (*tr + *ts)/2) * 1000));
			syncState = kPNSynchronousProcessingAck;
			timeStamp = CFAbsoluteTimeGetCurrent();
			if(*counter > 0) {
				*state			= kPNSynchronousProcessingSend;
				--(*counter);
				[self sync:data opponent:peer counter:*counter];
			} else {
				int sub;
				sub	= 0;
				for(NSData *m in [peer.syncPackets allValues]) {
					SyncData* cdata	= (SyncData*)m.bytes;
					sub += (int)(((cdata->Tr + cdata->Ts)/2 - (cdata->tr + cdata->ts)/2) * 1000);
				}
				
				PNPeer* host		= [[self peerList] objectAtIndex:0];
				host.subDeviceTime	= sub/(int)[peer.syncPackets count];
				*state				= kPNSynchronousProcessingEnd;
				[self sendSyncDataByReliable:data toPeers:[NSArray arrayWithObjects:peer,nil]];
				
				PNLog(@"ClientTime:%dms %d %d",host.subDeviceTime,sub,[peer.syncPackets count]);
			}
		} else if (*state == kPNSynchronousProcessingEnd) {
			PNCLog(PNLOG_CAT_NTP, @"PROCESSING_END");
			PNLog(@"Room Maxmember num:%d  SynchronizeCount:%d",room.maxMemberNum,synchronizeCount);
			if(room.maxMemberNum - 1 == ++synchronizeCount) {
				PNLog(@"Notify done message.");
				*state			= kPNSynchronousProcessingDone;
				*_startTime		= time;
				[self sendSyncDataByReliable:data toPeers:[self peerList]];
				[self sync:data opponent:peer counter:*counter];
			}
		} else if (*state == kPNSynchronousProcessingDone) {
			PNCLog(PNLOG_CAT_NTP, @"PROCESSING_DONE");
			isSynchronousProcessingDone = YES;	//SynchronousProcessingが完了したことをセットしておきます
			syncState			= kPNSynchronousProcessingDone;
			PNPeer* host		= [[self peerList] objectAtIndex:0];
			self.startTime		= *_startTime;
			self.timeDifference = host.subDeviceTime / 1000.0;
			
			PNLog(@"ServerTime:%lldms DiffTime:%lldms DeviceTime:%lldms",
				  (long long int)(self.startTime*1000),
				  (long long int)(self.timeDifference*1000),
				  (long long int)(CFAbsoluteTimeGetCurrent()*1000));
			[self performSelector:@selector(CALLBACK_CallGameStartingMethod) withObject:nil afterDelay:1.0];
			
			PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Done synchronous processing.");
		} else if (*state == kPNSynchronousProcessingTimeoutCheck) {
			PNCLog(PNLOG_CAT_NTP, @"kPNSynchrounousProcessingTimeoutCheck");
			// 時間とstatus
			if(isTimeoutCheckNecessary && !isSynchronousProcessingDone && syncState == kPNSynchronousProcessingSend && CFAbsoluteTimeGetCurrent() - timeStamp >= 2.0) {
				PNLog(@"Timeout check.");
				*state = kPNSynchronousProcessingSend;
				--(*counter);
				[self sync:data opponent:peer counter:cachedCounter];
			}
		} else {
			PNCLog(PNLOG_CAT_NTP, @"Unknown Protocol.");
		}
	}
}

- (void)CALLBACK_CallGameStartingMethod
{
	self.isStarted = YES;
	isTimeoutCheckNecessary = NO;
	
	if(callbackGameStarting)
		[callbackGameStarting performSelectorOnMainThread:callbackGameStartingSel withObject:nil waitUntilDone:NO];
	
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"Start game session.");
}


- (void)recvData:(NSData*)data from:(PNPeer*)peer
{
	SyncData *syncData = (SyncData*)data.bytes;
	[self sync:data opponent:peer counter:syncData->counter];
}


@end
