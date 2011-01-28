//
//  PNSimpleSessionManager.m
//  PankakuNet
//
//  Created by sota2 on 10/10/25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNSimpleSessionManager.h"
#import "PNRequestKeyManager.h"
#import "PNSessionRequestHelper.h"
#import "NSString+SBJSON.h"
#import "PNSessionModel.h"
#import "JsonHelper.h"

static PNSimpleSessionManager *_sharedInstance;


@implementation PNSimpleSessionManager

- (void)createSessionWithDelegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
						 onFailed:(SEL)onFailedSelector withObject:(id)anObject
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector withObject:anObject];
	[PNSessionRequestHelper createSessionWithDelegate:self selector:@selector(createSessionResponseForKey:response:) key:requestKey];
}
- (void)createSessionResponseForKey:(NSString*)requestKey response:(NSString*)response
{
	NSDictionary* json = [response JSONValue];
	id anObject = [PNRequestKeyManager requestForKey:requestKey].object;
	
	if ([JsonHelper isValid:json]) {
		PNSessionModel* sessionModel = [PNSessionModel dataModelWithDictionary:json];
		if (!anObject) {
			[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:sessionModel];
		} else {
			[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey 
													   withObject:[NSDictionary dictionaryWithObjectsAndKeys:sessionModel, @"session_model",
																   anObject, @"request_key", nil]];
		}
		
	} else {
		//TODO:
	}
}
- (void)httpRequestFailedWithError:(NSError *)error
{
	
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

+ (PNSimpleSessionManager *)sharedObject
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
