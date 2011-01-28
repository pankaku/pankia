//
//  PNMatchManager.m
//  PankakuNet
//
//  Created by sota on 10/08/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMatchManager.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNMatchRequestHelper.h"
#import "PNRequestKeyManager.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNGameSet.h"

static PNMatchManager* _sharedInstance;

@implementation PNMatchManager

- (void)finish:(PNGameSet*)aGameSet room:(PNRoom*)room delegate:(id)delegate 
   onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	
	NSString* session			= [PNUser session];
	NSMutableArray* users		= [NSMutableArray array];
	NSMutableArray* gradePoints = [NSMutableArray array];
	NSMutableArray* gameScores  = [NSMutableArray array];
	NSDictionary* gameSet		= aGameSet.pointmap;
	NSDictionary* gameScoresDic = aGameSet.scoremap;
	
	NSArray* keys = [gameSet allKeys];
	for(NSString* username in keys) {
		NSNumber* gradePoint = [gameSet objectForKey:username];
		[users addObject:username];
		[gradePoints addObject:gradePoint];
		
		NSNumber *gameScore = [gameScoresDic objectForKey:username];
		if (gameScore) {
			[gameScores addObject:gameScore];
		}
	}
	
	[PNMatchRequestHelper finish:session
							room:room.roomId
						   users:users
					 gradePoints:gradePoints
					 matchScores:gameScores
						delegate:self
						selector:@selector(defaultResponse:)
					  requestKey:requestKey];
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

+ (PNMatchManager *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}
@end
