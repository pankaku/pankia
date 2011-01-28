#import "PNUser.h"

/**
 @brief Friendの情報をゲーム側に受け渡すための構造体です。
 
 Friendの情報が格納されます。
 */
@interface PNFriend : NSObject {
@private
	NSString* userName;
	NSString* iconUrl;
	NSString* countryCode;
	NSString* achievementPoint;
	NSString* gradeName;
	NSString* gradePoint;
	BOOL      isFollowing;
	BOOL	  isBlocking;
	BOOL      gradeEnabled;
	PNUserIconType iconType;
	NSString* twitterId;
}

@property (retain, readonly) NSString* userName;
@property (retain, readonly) NSString* iconUrl;
@property (retain, readonly) NSString* countryCode;
@property (retain, readonly) NSString* achievementPoint;
@property (retain, readonly) NSString* gradeName;
@property (retain, readonly) NSString* gradePoint;
@property (assign, readonly) BOOL      isFollowing, isBlocking;
@property (nonatomic, retain) NSString* twitterId;
@property (assign) PNUserIconType iconType;

@end
