//
//  PNJSONCacheManager.m
//  PankakuNet
//
//  Created by sota2 on 10/12/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNJSONCacheManager.h"

#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNSettingManager.h"
#import "PNArchiveManager.h"

static PNJSONCacheManager* _sharedInstance;

@implementation PNJSONCacheManager

+ (NSString*)fileNameForCacheName:(NSString*)cacheName
{
	return [NSString stringWithFormat:@"user%d-lang%@-%@.json", [PNUser currentUser].userId, [[PNSettingManager sharedObject] preferedLanguage], cacheName];
}

- (void)saveCacheNamed:(NSString *)cacheName text:(NSString *)text
{
	[PNArchiveManager archiveString:text toFile:[PNJSONCacheManager fileNameForCacheName:cacheName]];
}

- (void)deleteCacheNamed:(NSString *)cacheName
{
	[PNArchiveManager deleteArchivedFile:[PNJSONCacheManager fileNameForCacheName:cacheName]];
}
- (NSString*)cacheNamed:(NSString *)cacheName
{
	return [PNArchiveManager unarchiveStringWithFile:[PNJSONCacheManager fileNameForCacheName:cacheName]];
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

+ (PNJSONCacheManager *)sharedObject
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
