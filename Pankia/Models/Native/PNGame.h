@class PNInstallModel;

/**
 @brief Gameの情報をゲーム側に受け渡すための構造体です。
 
 Gameの情報が格納されます。
 */
@interface PNGame : NSObject {
	NSString* gameTitle;
	NSString* description;
	NSString* iconUrl;
	NSString* achievementPoint;
	NSString* achievementTotal;
	NSString* gradeName;
	NSString* gradePoint;
	NSString* gameId;
	BOOL	  gradeEnabled;
	NSArray* screenshotUrls;
	NSArray* thumbnailUrls;
	NSString* iTunesUrl;
	NSString* developerName;
	NSString* price;
}

@property (retain) NSString* gameTitle;
@property (retain) NSString* description;
@property (retain) NSString* iconUrl;
@property (retain) NSString* achievementPoint;
@property (retain) NSString* achievementTotal;
@property (retain) NSString* gradeName;
@property (retain) NSString* gradePoint;
@property (retain) NSString* gameId;
@property (assign) BOOL		 gradeEnabled;
@property (nonatomic, retain) NSArray* screenshotUrls;
@property (nonatomic, retain) NSArray* thumbnailUrls;
@property (nonatomic, retain) NSString* iTunesUrl;
@property (nonatomic, retain) NSString* developerName;
@property (nonatomic, retain) NSString* price;

- (id)initWithInstallModel:(PNInstallModel*)model;

@end
