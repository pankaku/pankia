
@interface PNRequestObject : NSObject {
	id delegate;
	SEL onSucceededSelector;
	SEL onFailedSelector;
	id object;
}

@property (retain) id delegate;
@property (retain) id object;
@property (assign) SEL onSucceededSelector;
@property (assign) SEL onFailedSelector;
@end

@interface PNRequestKeyManager : NSObject {
	NSMutableDictionary *requestDictionary;
	int requestNumber;
}

+ (PNRequestKeyManager *)sharedObject;

+ (NSString*)registerDelegate:(id)delegate 
		  onSucceededSelector:(SEL)onSucceededSelector
			 onFailedSelector:(SEL)onFailedSelector;

+ (NSString*)registerDelegate:(id)delegate 
		  onSucceededSelector:(SEL)onSucceededSelector
			 onFailedSelector:(SEL)onFailedSelector 
				   withObject:(id)anObject;

+ (void)removeDelegateAndSelectorsForRequestKey:(NSString*)requestKey;

+ (id)delegateForRequestKey:(NSString*)requestKey;

+ (SEL)onSucceededSelectorForRequestKey:(NSString*)requestKey;

+ (SEL)onFailedSelectorForRequestKey:(NSString*)requestKey;

+ (PNRequestObject*)requestForKey:(NSString*)requestKey;

+ (void)callOnSucceededSelectorAndRemove:(NSString*)requestKey withObject:(id)object;

+ (void)callOnFailedSelectorAndRemove:(NSString*)requestKey withObject:(id)object;

+ (void)callOnFailedSelectorAndRemove:(NSString*)requestKey withErrorFromResponse:(NSString*)response;

@end
