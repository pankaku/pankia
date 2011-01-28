@class PNUserModel;

@interface PNFriend (Package)

@property (assign) BOOL      gradeEnabled;

@property (retain) NSString* userName;
@property (retain) NSString* iconUrl;
@property (retain) NSString* countryCode;
@property (retain) NSString* achievementPoint;
@property (retain) NSString* gradeName;
@property (retain) NSString* gradePoint;
@property (assign) BOOL      isFollowing;
@property (assign) BOOL			isBlocking;

- (id)initWithUserModel:(PNUserModel*)model;

@end
