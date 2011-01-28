@class PNAchievement;
@class PNError;

/**
 @brief PNAchievementManager provides functions releated to Achievement feature.
 */
@interface PNAchievementManager : NSObject {
	NSArray *achievementDetails;
	int totalPoints;
	NSMutableDictionary* gameCenterAchievementDictionary;
}
@property (retain) NSArray* achievementDetails;
@property (readonly) int totalPoints;
@property (retain) NSMutableDictionary* gameCenterAchievementDictionary;
+ (PNAchievementManager *)sharedObject;

- (PNAchievement*)achievementById:(int)achievementId;
- (void)getUnlockedAchievementsOfUser:(NSString*)user gameId:(NSString*)gameId onSuccess:(void (^)(NSArray *unlockedAchievements))onSuccess onFailure:(void (^)(PNError *error))onFailure;
- (BOOL)hasDetailsForAchievementId:(int)achievementId;
- (BOOL)isAchievementUnlocked:(int)id;
- (void)unlockAchievementById:(int)achievementId;
- (void)unlockAchievements:(NSArray*)achievements;
- (NSArray*)unlockedAchievements;
- (void)syncWithServer;
- (int)valueOfAchievementById:(int)achievementId;

#pragma mark GameCenter related
-(void)uploadAchievementToGameCenter:(int)achievementId;
@end

