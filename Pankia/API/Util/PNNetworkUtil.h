#import "PNNetworkDefined.h"

@protocol PNSendPacketFilterDelegate;


@interface PNNetworkUtil : NSObject {
	
}

+(BOOL)isConnectedWifi;
+(void)sendPacketFilterWithDelegate:(id<PNSendPacketFilterDelegate>)aDelegate
						 isReliable:(BOOL)aIsReliable
							   data:(NSData*)aData
							   host:(NSString*)aHost
							   port:(NSNumber*)aPort;

@end

@protocol PNSendPacketFilterDelegate

-(void)filteringAndPacketIsTransmitted:(NSData*)aData host:(NSString*)aHost port:(NSNumber*)aPort;

@end

extern PNConnectionLevel getConnectionLevel(int rtt);

