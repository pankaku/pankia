//
//  PNPermanentImageCacheManager.m
//  PankiaLite
//
//  Created by sota2 on 10/10/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNPermanentImageCacheManager.h"

static PNPermanentImageCacheManager* _sharedInstance;

@implementation PNPermanentImageCacheManager
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

+ (PNPermanentImageCacheManager *)sharedObject
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
