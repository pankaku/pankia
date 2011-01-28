// Programmatically retrieving IP Address of iPhone -  Zach Waugh
// http://zachwaugh.com/2009/03/programmatically-retrieving-ip-address-of-iphone/

#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface IPAddress : NSObject

+(NSString*)getIPAddress;
+(NSString*)getNetmask;

@end
