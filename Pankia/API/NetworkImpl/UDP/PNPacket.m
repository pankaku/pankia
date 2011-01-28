#import "PNPacket.h"
#import "PNLogger+Package.h"


@implementation PNPacket

@synthesize sequence;
@synthesize address;
@synthesize port;
@synthesize theFlag;
@synthesize data;
@synthesize packedData;
@synthesize ackFlag;
@synthesize timestamp;
@synthesize resendCount;

-(id) init
{
    if (self = [super init]) {
        // Initialization code
		self.sequence		= -1;
		self.address		= nil;
		self.port			= 0;
		self.theFlag		= 0;
		self.data			= nil;
		self.ackFlag		= 0;
		self.timestamp		= 0;
		self.resendCount	= 0;
    }
	
    return self;
}

-(void) dealloc
{
	self.address		= nil;
	self.data			= nil;
	self.packedData		= nil;
	[super dealloc];
}


+(PNPacket*)create
{
	PNPacket *packet = [[[PNPacket alloc] init] autorelease];
	return packet;
}

+(PNPacket*)createWithPackedData:(NSData*)data
{
	PNPacket *packet = [[[PNPacket alloc] init] autorelease];
	packet.packedData = data;
	return packet;
}

+(NSData*)blockPack:(NSArray*)packets
{
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	for(PNPacket* p in packets) {
		[p pack];
		[data appendData:p.packedData];
	}
	return data;
}

+(NSArray*)blockUnpack:(NSData*)data
{
	int off;
	unsigned char* stream;
	NSMutableArray* packets;
	
	off			= 0;
	stream		= (unsigned char*)data.bytes; 
	packets		= [[[NSMutableArray alloc] init] autorelease];
	
	while(data.length > off) {
		int begin;
		int size;
		int seq;
		int theFlag;
		int length;
		PNPacket* p;
		
		begin	= off;
		size	= 0;
		
		seq		= *((int*)&stream[off]);
		off		+= sizeof(int);
		theFlag = *((int*)&stream[off]);
		off		+= sizeof(int);
		length	= *((int*)&stream[off]);
		off		+= sizeof(int);
		size	= sizeof(int)*3 + sizeof(unsigned char)*length;
		off		+= length;
		p		= [PNPacket createWithPackedData:[NSData dataWithBytes:&stream[begin] length:size]];
		[p unpack];
		[packets addObject:p];

	}
	return packets;
}


-(void)pack
{
	if(data) {
		int size;
		unsigned char *d;
		d						= (unsigned char*)malloc(sizeof(int)+sizeof(int)+sizeof(int)+sizeof(unsigned char)*data.length);
		size					= 0;
		(*((int*)&d[size]))		= self.sequence;
		size					+= sizeof(int);
		(*((int*)&d[size]))		= self.theFlag;
		size					+= sizeof(int);
		(*((int*)&d[size]))		= self.data.length;
		size					+= sizeof(int);
		memcpy(&d[size],self.data.bytes,self.data.length);
		size					+= sizeof(unsigned char)*self.data.length;
		self.packedData = [NSData dataWithBytes:d length:size];
		free(d);
	} else {
		PNLog(@"Packet was not able to pack.");
	}
}

-(void)unpack
{
	if(packedData) {
		int i;
		int length;
		unsigned char *p;
		unsigned char *dst;
		
		p				= (unsigned char*)packedData.bytes;
		i				= 0;
		self.sequence	= (*((int*)&p[i]));
		i				+= sizeof(int);
		self.theFlag	= (*((int*)&p[i]));
		i				+= sizeof(int);
		length			= (*((int*)&p[i]));
		i				+= sizeof(int);
		
		dst = (unsigned char*)malloc(sizeof(unsigned char)*length);
		memcpy(dst, &p[i], sizeof(unsigned char)*length);
		self.data = [NSData dataWithBytes:dst length:length];
		free(dst);
	} else {
		PNLog(@"Packet was not able to unpack.");
	}
}

// ASC
- (NSComparisonResult)compareASC:(PNPacket *)e {
	if (self.sequence < e.sequence ){
		return NSOrderedAscending;
	} else if (self.sequence > e.sequence){
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

// DESC
- (NSComparisonResult)compareDESC:(PNPacket *)e {
	if (self.sequence > e.sequence ){
		return NSOrderedAscending;
	} else if (self.sequence < e.sequence){
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

@end
