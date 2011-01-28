#import "PNModel.h"

/**
 @brief Achievementの情報をゲーム側に受け渡すための構造体です。
 
 Achievementの情報が格納されます。
 */
@interface PNAchievement : PNModel {
@private
	int        achievementId;
	NSString*  title;
	NSString*  description;
	NSUInteger value;
	NSString*  iconUrl;
	BOOL       isSecret;
	BOOL       isUnlocked;
	int		   orderNumber;
}

@property (readonly) int id;
@property (assign, readonly) int        achievementId;
@property (retain, readonly) NSString*  title;
@property (retain, readonly) NSString*  description;
@property (assign, readonly) NSUInteger value;
@property (retain, readonly) NSString*  iconUrl;
@property (assign, readonly) BOOL       isSecret;
@property (assign, readonly) BOOL       isUnlocked;

@end
