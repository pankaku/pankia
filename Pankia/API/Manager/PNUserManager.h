#import "PNUser.h"
#import "PNAbstractManager.h"

@interface PNUserManager : PNAbstractManager {

}
+ (PNUserManager*) sharedObject;
#pragma mark actions
- (void)changeName:(NSString*)name onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)switchAccountByTwitterID:(NSString*)account password:(NSString*)password 
					   onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (void)switchAccountByUsername:(NSString*)account password:(NSString*)password 
					  onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;


- (void)secureOrUpdateUser:(PNUser*)user
					  name:(NSString*)name
					 email:(NSString*)email
				  password:(NSString*)password
				  delegate:(id)delegate
			   onSucceeded:(SEL)onSucceededSelector
				  onFailed:(SEL)onFailedSelector;

- (void)followUserById:(NSString*)user
			  delegate:(id)delegate
		   onSucceeded:(SEL)onSucceededSelector
			  onFailed:(SEL)onFailedSelector;
- (void)unfollowUserById:(NSString*)user
				delegate:(id)delegate
			 onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector;
- (void)blockUser:(NSString*)userName delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector withObject:(id)object;
- (void)unblockUser:(NSString*)userName delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector withObject:(id)object;
- (void)pushToUser:(NSString*)userName withText:(NSString *)aString delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector withObject:(id)object;
- (void)pushToUser:(NSString *)userName withText:(NSString *)aString onSuccess:(void (^)(NSString *))succeedCallback onFailure:(void (^)(PNError *))failedCallback;
#pragma mark get actions
- (void)findByName:(NSString*)name
		   include:(NSString*)include
			offset:(int)offset
			 limit:(int)limit
		  delegate:(id)delegate
	   onSucceeded:(SEL)onSucceededSelector
		  onFailed:(SEL)onFailedSelector;

- (void)getFolloweesOfUser:(NSString*)user
					offset:(int)offset
					 limit:(int)limit
				  delegate:(id)delegate
			   onSucceeded:(SEL)onSucceededSelector
				  onFailed:(SEL)onFailedSelector;
- (void)getFolloweesInCurrentGameOfUser:(NSString*)user
					offset:(int)offset
					 limit:(int)limit
				  delegate:(id)delegate
			   onSucceeded:(SEL)onSucceededSelector
				  onFailed:(SEL)onFailedSelector;

- (void)getFollowersOfUser:(NSString*)user
					offset:(int)offset
					 limit:(int)limit
				  delegate:(id)delegate
			   onSucceeded:(SEL)onSucceededSelector
				  onFailed:(SEL)onFailedSelector;

- (void)getDetailsOfUser:(NSString*)user
				 include:(NSString*)include
				delegate:(id)delegate
			 onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector;



// BEGIN - lerry added code
- (void)switchAccountByFacebookSessionKey:(NSString*)sessionKey 
								   secret:(NSString*)secret
								 delegate:(id)delegate 
							  onSucceeded:(SEL)onSucceededSelector 
								 onFailed:(SEL)onFailedSelector;
// END - lerry added code

@end
