@class PNError;
/**
 @brief PNTwitterManager provides methods related to Twitter service.
*/
@interface PNTwitterManager : NSObject {

}
+ (PNTwitterManager*)sharedObject;
- (void)linkWithAccountName:(NSString*)accountName password:(NSString*)password 
				  onSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)unlinkWithOnSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)postTweet:(NSString *)tweet onSuccess:(void (^)(void)) onSuccess onFailure:(void (^)(PNError *))onFailure;
- (void)importGraphWithOnSuccess:(void (^)(void))onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)verifyWithOnSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
@end

