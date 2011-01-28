//
//  PNNativeRequestManager.m
//  PankakuNet
//
//  Created by sota2 on 11/01/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNNativeRequestManager.h"

static PNNativeRequestManager* _sharedInstance;


@interface PNNativeRequestManager()
@property (nonatomic, retain) NSMutableArray* pendingRequests;
@end

@implementation PNNativeRequestManager
@synthesize pendingRequests;

- (void)pushRequest:(PNNativeRequest *)request
{
	[pendingRequests addObject:request];
}
- (void)pullRequest:(PNNativeRequest*)request
{
	[pendingRequests removeObject:request];
}
- (void)cancelAllRequests
{
	for (PNNativeRequest* request in pendingRequests) {
		[request cancel];
	}
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init {
	if (self = [super init]){			
		self.pendingRequests = [NSMutableArray array];
	}
	return self;
}

- (void) dealloc{
	self.pendingRequests = nil;
	[super dealloc];
}

+ (PNNativeRequestManager *)sharedObject
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
