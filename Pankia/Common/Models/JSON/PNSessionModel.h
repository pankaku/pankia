#import "PNDataModel.h"
#import "PankiaLite.h"

/**
 @brief Sessionに関する情報から作られる構造体
 */
@class PNUserModel;
@class PNGameModel;
@interface PNSessionModel : PNDataModel {
	NSString* _id;
#ifndef PANKIA_LITE
	PNUserModel *_user;
	PNGameModel *_game;
#endif
	NSArray* splashes;
}

@property (assign, nonatomic) NSString* id;
@property (retain, nonatomic) PNUserModel *user;
@property (retain, nonatomic) PNGameModel *game;
@property (retain, nonatomic) NSArray* splashes;
@end
