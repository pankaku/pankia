
@interface PNPacketFireWall : NSObject {
@private
	NSMutableDictionary* fixedIptables;
	NSMutableDictionary* dynamicIptables;
}

+(void)initialize;
+(void)allowIPv4:(NSString*)aIPv4 port:(int)aPort;
+(BOOL)isServerAddress:(NSString*)aIPv4;
+(BOOL)isIPv4Allowed:(NSString*)aIPv4 port:(int)aPort;
+(void)removeIPv4:(NSString*)aIPv4 port:(int)aPort;
+(PNPacketFireWall*)sharedObject;
+(void)clear;
+(NSDictionary*)getDynamicIptables;

@end
