#import "PNSessionModel.h"
#import "PNSplashModel.h"

#ifndef PANKIA_LITE
#import "PNUserModel.h"
#import "PNGameModel.h"
#endif

@implementation PNSessionModel
@synthesize id = _id, user = _user, game = _game, splashes;

- (id) init{
	if (self = [super init]){
		self.id = nil;
		self.game = nil;
		self.user = nil;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		NSDictionary *sessionDictionary = [aDictionary objectForKey:@"session"];
		self.id = [sessionDictionary objectForKey:@"id"];
#ifndef PANKIA_LITE
		if ([sessionDictionary hasObjectForKey:@"user"]){
			self.user = [[[PNUserModel alloc] initWithDictionary:[sessionDictionary objectForKey:@"user"]] autorelease];
		}
		if ([sessionDictionary hasObjectForKey:@"game"]){
			self.game = [[[PNGameModel alloc] initWithDictionary:[sessionDictionary objectForKey:@"game"]] autorelease];
		}
#endif
		self.splashes = [PNSplashModel dataModelsFromArray:[sessionDictionary objectForKey:@"splashes"]];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void) dealloc{
#ifndef PANKIA_LITE
	self.game	= nil;
	self.user	= nil;
#endif
	self.splashes = nil;
	[super dealloc];
}

-(NSString*)description{
	return [NSString stringWithFormat:@"<%@ :%p ,id: %@>\n->user: %p\n->game: %p",
			NSStringFromClass([self class]),self,_id, _user, _game];
}



@end
