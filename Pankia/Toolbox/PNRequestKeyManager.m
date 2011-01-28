#import "PNRequestKeyManager.h"
#import "NSObject+PostEvent.h"
#import "PNLogger.h"
#import "PNError.h"
static PNRequestKeyManager* _sharedInstance;

@implementation PNRequestObject
@synthesize delegate, onSucceededSelector, onFailedSelector, object;
- (void)dealloc {
	self.delegate = nil;
	self.object = nil;
	[super dealloc];
}
@end


@interface PNRequestKeyManager(Private)
- (NSString*)newRequestKey;
- (NSString*)registerDelegate:(id)delegate onSucceededSelector:(SEL)onSucceededSelector
			 onFailedSelector:(SEL)onFailedSelector withObject:(id)anObject;
- (void)removeDelegateAndSelectorsForRequestKey:(NSString*)requestKey;
- (id)delegateForRequestKey:(NSString*)requestKey;
- (SEL)onSucceededSelectorForRequestKey:(NSString*)requestKey;
- (SEL)onFailedSelectorForRequestKey:(NSString*)requestKey;
- (PNRequestObject*)requestForKey:(NSString*)requestKey;
- (void)callOnSucceededSelectorAndRemove:(NSString*)requestKey withObject:(id)object;
- (void)callOnFailedSelectorAndRemove:(NSString*)requestKey withObject:(id)object;
@end

@implementation PNRequestKeyManager
+ (void)callOnSucceededSelectorAndRemove:(NSString *)requestKey withObject:(id)object
{
	return [[self sharedObject] callOnSucceededSelectorAndRemove:requestKey withObject:object];
}
+ (void)callOnFailedSelectorAndRemove:(NSString*)requestKey withObject:(id)object
{
	return [[self sharedObject] callOnFailedSelectorAndRemove:requestKey withObject:object];
}
+ (void)callOnFailedSelectorAndRemove:(NSString*)requestKey withErrorFromResponse:(NSString*)response
{
	return [[self sharedObject] callOnFailedSelectorAndRemove:requestKey withObject:[PNError errorFromResponse:response]];
}
+ (NSString*)registerDelegate:(id)delegate onSucceededSelector:(SEL)onSucceededSelector
			 onFailedSelector:(SEL)onFailedSelector{
	return [[self sharedObject] registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector withObject:nil];
}
+ (NSString*)registerDelegate:(id)delegate onSucceededSelector:(SEL)onSucceededSelector
			 onFailedSelector:(SEL)onFailedSelector withObject:(id)anObject{
	return [[self sharedObject] registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector withObject:anObject];
}
+ (void)removeDelegateAndSelectorsForRequestKey:(NSString*)requestKey{
	[[self sharedObject] removeDelegateAndSelectorsForRequestKey:requestKey];
}
+ (id)delegateForRequestKey:(NSString*)requestKey{
	return [[self sharedObject] delegateForRequestKey:requestKey];
}
+ (SEL)onSucceededSelectorForRequestKey:(NSString*)requestKey{
	return [[self sharedObject] onSucceededSelectorForRequestKey:requestKey];
}
+ (SEL)onFailedSelectorForRequestKey:(NSString*)requestKey{
	return [[self sharedObject] onFailedSelectorForRequestKey:requestKey];
}
+ (PNRequestObject*)requestForKey:(NSString*)requestKey
{
	return [[self sharedObject] requestForKey:requestKey];
}

#pragma mark Instance methods
- (void)callOnSucceededSelectorAndRemove:(NSString*)requestKey withObject:(id)object
{
	PNRequestObject* request = [self requestForKey:requestKey];	
	PNRequestObject* originalObject = request.object;
	
	if ([request.delegate respondsToSelector:request.onSucceededSelector]) {
		if (object && originalObject) {
			[request.delegate performSelector:request.onSucceededSelector withObjects:[NSArray arrayWithObjects:originalObject, object, nil]];
		} else if (object) {
			[request.delegate performSelector:request.onSucceededSelector withObject:object];
		} else if (request.object) {
			[request.delegate performSelector:request.onSucceededSelector withObject:request.object];
		} else {
			[request.delegate performSelector:request.onSucceededSelector];
		}
		
	}
	
	[self removeDelegateAndSelectorsForRequestKey:requestKey];
}
- (void)callOnFailedSelectorAndRemove:(NSString*)requestKey withObject:(id)object
{
	if (requestKey == nil) {
		PNWarn(@"Error in PNRequestKeyManager. requestKey is nil in callOnFailedSelectorAndRemove:withObject:");
		return;
	}
	
	PNRequestObject* request = [self requestForKey:requestKey];	
	
	if ([request.delegate respondsToSelector:request.onFailedSelector]) {
		if (object) {
			[request.delegate performSelector:request.onFailedSelector withObject:object];
		} else if (request.object) {
			[request.delegate performSelector:request.onFailedSelector withObject:request.object];
		} else {
			[request.delegate performSelector:request.onFailedSelector];
		}
	}
	
	[self removeDelegateAndSelectorsForRequestKey:requestKey];
}
- (NSString*)newRequestKey{
	NSString* newKey = nil;
	@synchronized(self){
		requestNumber++;
		newKey = [NSString stringWithFormat:@"PNRequest%d", requestNumber];
	}
	return newKey;
}
- (NSString*)registerDelegate:(id)delegate onSucceededSelector:(SEL)onSucceededSelector
			 onFailedSelector:(SEL)onFailedSelector withObject:(id)anObject{
	NSString* requestKey = [self newRequestKey];
	if (delegate != nil){
		PNRequestObject *request = [[[PNRequestObject alloc] init] autorelease];
		request.delegate = delegate;
		request.onSucceededSelector = onSucceededSelector;
		request.onFailedSelector = onFailedSelector;
		request.object = anObject;
		[requestDictionary setObject:request forKey:requestKey];
	}
	return requestKey;
}
- (void)removeDelegateAndSelectorsForRequestKey:(NSString*)requestKey{
	if(requestKey)
		[requestDictionary removeObjectForKey:requestKey];
}
- (PNRequestObject*)requestForKey:(NSString *)requestKey{
	return [requestDictionary objectForKey:requestKey];
}
- (id)delegateForRequestKey:(NSString*)requestKey{
	PNRequestObject* request = [self requestForKey:requestKey];
	if (request){
		return request.delegate;
	}else{
		return nil;
	}
}
- (SEL)onSucceededSelectorForRequestKey:(NSString*)requestKey{
	PNRequestObject* request = [self requestForKey:requestKey];
	if (request){
		return request.onSucceededSelector;
	}else{
		return nil;
	}
}
- (SEL)onFailedSelectorForRequestKey:(NSString*)requestKey{
	PNRequestObject* request = [self requestForKey:requestKey];
	if (request){
		return request.onFailedSelector;
	}else{
		return nil;
	}
}
#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		requestNumber = 0;
		requestDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[requestDictionary release];
	[super dealloc];
}

+ (PNRequestKeyManager *)sharedObject
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
