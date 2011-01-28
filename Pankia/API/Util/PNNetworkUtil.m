#import "PNNetworkUtil.h"

#include <arpa/inet.h>
#import "Reachability.h"
#import "NSObject+PostEvent.h"
#import "PNGlobal.h"

NSNumber *inetToLongLong(const char* host,int port)
{
	if(host)
		return [NSNumber numberWithLongLong:((long long int)(inet_addr(host))|((long long int)port)<<32)];
	else
		return nil;
}


@implementation PNNetworkUtil


+ (BOOL)isConnectedWifi
{
	return [Reachability isConnectedWifi];
}


+(void)sendPacketFilterWithDelegate:(id<PNSendPacketFilterDelegate>)aDelegate
						 isReliable:(BOOL)aIsReliable
							   data:(NSData*)aData
							   host:(NSString*)aHost
							   port:(NSNumber*)aPort
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
	
	if(!aIsReliable && kPNSoftwareSendPacketLossPercentage) {
		int rnd = rand() % 100;
		int g = rnd - kPNSoftwareSendPacketLossPercentage;
		if(g < 0) {
			return;
		}
	}

	NSObject<PNSendPacketFilterDelegate>* delegateObject = (NSObject*)aDelegate;
	if(r) {
		[delegateObject performSelector:@selector(filteringAndPacketIsTransmitted:host:port:)
					   withObjects:[NSArray arrayWithObjects:aData,aHost,aPort,nil]
						afterDelay:r/1000.0f];
	} else {
		[delegateObject filteringAndPacketIsTransmitted:aData host:aHost port:aPort];
	}
}



@end


#define kPNConnectionLevel1 100			//!< RTT0〜200ms
#define kPNConnectionLevel2 300			//!< RTT〜400ms
#define kPNConnectionLevel3 500			//!< RTT〜600ms
#define kPNConnectionLevel4 0x7FFFFFFF	//!< RTT600〜ms
#define kPNConnectionLevel5 -1			//!< 計測不能 

PNConnectionLevel getConnectionLevel(int rtt) {
	
	if(rtt==kPNConnectionLevel5) {
		return kPNConnectionLevelUnknown;
	}
	else if (rtt < kPNConnectionLevel1) {
		return kPNConnectionLevelHigh;
	}
	else if (rtt < kPNConnectionLevel2) {
		return kPNConnectionLevelNormal;
	}
	else if (rtt < kPNConnectionLevel3) {
		return kPNConnectionLevelLow;
	}
	else if (rtt < kPNConnectionLevel4) {
		return kPNConnectionLevelNotRecommend;
	}
	return kPNConnectionLevelUnmeasurement;
}
