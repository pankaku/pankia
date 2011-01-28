//
//  PNHTTPRequestCacheManager.m
//  PankakuNet
//
//  Created by pankaku on 10/06/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNHTTPRequestCacheManager.h"
#import "PNLogger+Common.h"


#define kPNHTTPCacheDicKey @"PN_HTTP_CACHE_DIC"

static PNHTTPRequestCacheManager *_sharedInstance;

@implementation PNHTTPRequestCacheManager

- (void)synchronize
{
	[[NSUserDefaults standardUserDefaults] setObject:storedCacheDictionary forKey:kPNHTTPCacheDicKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	PNCLog(PNLOG_CAT_HTTP_CACHE, @"synchronized. %@", storedCacheDictionary);
}

- (BOOL)shouldStorePermanently:(NSString*)url
{
	//ここでキャッシュすべきURLかを判断する
	return YES;
}
- (BOOL)shouldBeUnique:(NSString*)url
{
	//パラメータに依存しない(パラメータが違うURLを別々にエントリさせない)URLは
	//ここでYESを返します。
	
	return NO;
}

- (void)removeEntryWithPrefix:(NSString*)prefix
{
	PNCLog(PNLOG_CAT_HTTP_CACHE, @"remove entry with: %@", prefix);
	
	NSArray* keys = [storedCacheDictionary allKeys];
	for (NSString *key in keys){
		if ([key hasPrefix:prefix]){
			PNCLog(PNLOG_CAT_HTTP_CACHE, @"Remove from cache: %@", key);
			[storedCacheDictionary removeObjectForKey:key];
		}
	}
}

- (void)removeExpiredEntries
{
	NSArray* keys = [storedCacheDictionary allKeys];
	for (NSString *key in keys){
		NSDictionary* entry = [storedCacheDictionary objectForKey:key];
		id expire_at = [entry objectForKey:@"expire_at"];
		
		BOOL shouldRemove = NO;
		if (expire_at == nil){
			shouldRemove = YES;
		} else if ([expire_at isKindOfClass:[NSString class]] && [(NSString*)expire_at isEqualToString:@"forever"]){
			shouldRemove = NO;
		} else if ([expire_at isKindOfClass:[NSDate class]]) {
			if ([[NSDate date] timeIntervalSinceDate:expire_at] > 0){
				shouldRemove = YES;
			}
		}
		
		if (shouldRemove){
			[storedCacheDictionary removeObjectForKey:key];
		}
	}
}

- (void)clearAll
{
	[storedCacheDictionary removeAllObjects];
	[self synchronize];
}

- (void)addCache:(NSString *)value url:(NSString *)url
{
	[self addCache:value url:url expireAt:@"forever"];
}
- (void)addCache:(NSString *)value url:(NSString *)url expireAt:(NSString*)expireAt
{
	NSMutableDictionary *cacheEntry = [NSMutableDictionary dictionary];
	[cacheEntry setObject:value forKey:@"value"];
	[cacheEntry setObject:[NSDate date] forKey:@"created_at"];
	[cacheEntry setObject:expireAt forKey:@"expire_at"];
	
	if ([self shouldBeUnique:url]){
		[self removeEntryWithPrefix:[[url componentsSeparatedByString:@"?"] objectAtIndex:0]];
	}
	
	if ([self shouldStorePermanently:url]) {
		[storedCacheDictionary setObject:cacheEntry forKey:url];
	}
	
	[self synchronize];
}
- (BOOL)hasCacheForURL:(NSString*)url{
	[self removeExpiredEntries];
	return ([storedCacheDictionary objectForKey:url] != nil);
}
- (NSString*)cachedValueForURL:(NSString*)url{
	NSDictionary *entry = [storedCacheDictionary objectForKey:url];
	if (entry){
		return [entry objectForKey:@"value"];
	}else{
		return nil;
	}
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		storedCacheDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kPNHTTPCacheDicKey];
		if (storedCacheDictionary == nil)
			storedCacheDictionary = [[NSMutableDictionary alloc] init];
		PNCLog(PNLOG_CAT_HTTP_CACHE, @"%@", storedCacheDictionary);
	}
	return self;
}

- (void) dealloc
{
	[storedCacheDictionary release];
	[super dealloc];
}

+ (PNHTTPRequestCacheManager *)sharedObject
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
