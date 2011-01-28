#import "PNDeviceModel.h"

//Device
#define kPNDeviceDefaultUDID			@""
#define kPNDeviceDefaultName			@""
#define kPNDeviceDefaultOS				@""
#define kPNDeviceDefaultHardware		@""

@implementation PNDeviceModel

@synthesize udid = _udid;
@synthesize name = _name;
@synthesize os = _os;
@synthesize hardware = _hardware;


- (id) init{
	if (self = [super init]) {
		self.udid =		kPNDeviceDefaultUDID;
		self.name =		kPNDeviceDefaultName;
		self.os =		kPNDeviceDefaultOS;
		self.hardware = kPNDeviceDefaultHardware;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [self init]) {
		self.udid = [aDictionary stringValueForKey:@"udid" defaultValue:kPNDeviceDefaultUDID];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:kPNDeviceDefaultName];
		self.os = [aDictionary stringValueForKey:@"os" defaultValue:kPNDeviceDefaultOS];
		self.hardware = [aDictionary stringValueForKey:@"hardware" defaultValue:kPNDeviceDefaultHardware];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	self.udid		= nil;
	self.name		= nil;
	self.os		= nil;
	self.hardware	= nil;
	[super dealloc];

}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p>\n udid:%@\n name:%@\n os:%@\n hardware:%@",
			NSStringFromClass([self class]),self, _udid, _name, _os, _hardware];
}

@end
