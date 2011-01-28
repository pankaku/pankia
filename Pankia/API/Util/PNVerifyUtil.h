
@interface PNVerifyUtil : NSObject {

}

+(NSString*)verifierStringForAchievementId:(int)achievementId session:(NSString*)session secret:(NSString*)secret;

@end
