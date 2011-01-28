#import "IPAddress.h"
@implementation IPAddress

+ (NSString*)getIPAddress
{
	NSString *address = @"error";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0)
	{
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL)
		{
			if(temp_addr->ifa_addr->sa_family == AF_INET)
			{
				//NSLog(@"%@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
				{
					// Get NSString from C String
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
				// Only for iPhone Simulator, which often uses wifi instead of ethernet on the Mac
				else if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"] && [address isEqualToString:@"error"])
				{
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
				// Check if interface is pdp_ip0 which is the cellular connection on the iPhone
				else if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"] && [address isEqualToString:@"error"])
				{
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
			}
			
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	// Free memory
	freeifaddrs(interfaces);
	
	return address;
}

+ (NSString*)getNetmask
{
	NSString *netmask = @"error";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0)
	{
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL)
		{
			if(temp_addr->ifa_addr->sa_family == AF_INET)
			{
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"] && [netmask isEqualToString:@"error"])
				{
					netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
				}
			}
			
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	// Free memory
	freeifaddrs(interfaces);
	
	return netmask;
}

@end

NSString *getLocalAddress() {
	NSString *address = @"error";
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0)
	{
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL)
		{
			if(temp_addr->ifa_addr->sa_family == AF_INET)
			{
				//NSLog(@"%@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
				{
					// Get NSString from C String
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
				// Only for iPhone Simulator, which often uses wifi instead of ethernet on the Mac
				else if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"] && [address isEqualToString:@"error"])
				{
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
				// Check if interface is pdp_ip0 which is the cellular connection on the iPhone
				else if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"] && [address isEqualToString:@"error"])
				{
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
			}
			
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	
	// Free memory
	freeifaddrs(interfaces);
	[pool release];
	return address;
}
