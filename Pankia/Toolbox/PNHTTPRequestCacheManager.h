//
//  PNHTTPRequestCacheManager.h
//  PankakuNet
//
//  Created by pankaku on 10/06/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PNHTTPRequestCacheManager : NSObject {
	NSMutableDictionary* storedCacheDictionary;
}
+ (PNHTTPRequestCacheManager *)sharedObject;
- (void)addCache:(NSString*)value url:(NSString*)url;
- (void)addCache:(NSString *)value url:(NSString *)url expireAt:(NSString*)expireAt;
- (BOOL)hasCacheForURL:(NSString*)url;
- (NSString*)cachedValueForURL:(NSString*)url;
- (void)clearAll;
@end
