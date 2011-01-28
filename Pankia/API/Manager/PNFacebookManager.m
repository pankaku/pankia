//
//  PNFacebookManager.m
//  PankakuNet
//
//  Created by pankaku on 10/08/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNFacebookManager.h"
#import "PNRequestKeyManager.h"
#import "PNFacebookRequestHelper.h"
#import "PankiaNetworkLibrary.h"
#import "PNUserModel.h"

static PNFacebookManager *_sharedInstance;
@implementation PNFacebookManager

#pragma mark Link
- (void)linkWithUid:(unsigned long long)uid sessionKey:(NSString*)sessionKey sessionSecret:(NSString*)sessionSecret delegate:(id)aDelegate
			   onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	
	[PNFacebookRequestHelper linkWithUid:uid sessionKey:sessionKey sessionSecret:sessionSecret delegate:self selector:@selector(linkResponse:) key:requestKey];
}
- (void)linkResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSDictionary* json = [response jsonDictionary];
	NSString* resp = [response jsonString];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onSucceededSelector = request.onSucceededSelector;
	SEL onFailedSelector = request.onFailedSelector;
	
	if(response.isValidAndSuccessful) {
		if([aDelegate respondsToSelector:onSucceededSelector]){
			PNUserModel* userModel = [PNUserModel dataModelWithDictionary:[json objectForKey:@"user"]];
			[aDelegate performSelector:onSucceededSelector withObject:userModel];
		}
	} else {
		PNError* error = [[[PNError alloc] initWithResponse:resp] autorelease];
		if([aDelegate respondsToSelector:onFailedSelector]){
			[aDelegate performSelector:onFailedSelector withObject:error];
		}				
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
- (void)unlinkWithDelegate:(id)aDelegate
			   onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate 
											 onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector];
	
	[PNFacebookRequestHelper unlinkWithDelegate:self selector:@selector(unlinkResponse:) key:requestKey];
}
- (void)unlinkResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString* resp = [response jsonString];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onSucceededSelector = request.onSucceededSelector;
	SEL onFailedSelector = request.onFailedSelector;
	
	if(response.isValidAndSuccessful) {
		if([aDelegate respondsToSelector:onSucceededSelector]){
			[aDelegate performSelector:onSucceededSelector];
		}
	} else {
		PNError* error = [[[PNError alloc] initWithResponse:resp] autorelease];
		if([aDelegate respondsToSelector:onFailedSelector]){
			[aDelegate performSelector:onFailedSelector withObject:error];
		}				
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

+ (PNFacebookManager *)sharedObject
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
