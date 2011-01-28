#import "PNGameSet.h"

@implementation PNGameSet
@synthesize pointmap, scoremap;

-(id)init
{
	if(self = [super init]) {
		pointmap = [[NSMutableDictionary dictionary] retain];
		scoremap = [[NSMutableDictionary dictionary] retain];
	}
	
	return self;
}

-(void)dealloc
{
	[scoremap release];
	[pointmap release];
	[super dealloc];
}

-(void)setGradePoint:(NSString*)aUsername point:(int)aPoint
{
	[pointmap setObject:[NSNumber numberWithInt:aPoint] forKey:aUsername];
}

-(void)setMatchScore:(NSString *)aUsername score:(int)score
{
	[scoremap setObject:[NSNumber numberWithInt:score] forKey:aUsername];
}

+(PNGameSet*)gameSet
{
	return [[[PNGameSet alloc] init] autorelease];
}

@end
