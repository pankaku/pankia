/*
 *  PNDataModel.h
 *  PankakuNet
 *
 *  Created by Sota Yokoe on 10/02/25.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

/**
 @brief サーバーとクライアント間で通信されるモデル用のベースとなるクラス
 
 このデータモデル自体は一時オブジェクトとしての意味しかなさないため、
 Object* obj = [Object dataModelWithDictionary:hoge];
 としてautorelease行きの一時オブジェクトとして扱ってください。
 */
#import "NSDictionary+GetterExt.h"
#import "PNLogger+Common.h"

#define J_STATUS @"status"
#define J_STATUS_OK @"ok"
#define J_EVENTS @"events"
#define J_EVENTS_TOPIC_ROOM @"room"
#define J_EVENTS_TOPIC_JOIN @"join"
#define J_EVENTS_TOPIC_LEAVE @"leave"
#define J_EVENTS_TOPIC_SAY @"say"
#define J_EVENTS_TOPIC_REMOVE @"remove"
#define J_EVENTS_TOPIC_MATCHSTART @"match_start"
#define J_EVENTS_TOPIC_MATCHFINISH @"match_finish"
#define J_EVENTS_DATA @"data"
#define J_EVENTS_DATA_MATCH @"match"
#define J_EVENTS_DATA_MATCH_USERS @"users"
#define J_LOBBIES @"lobbies"
#define J_ROOMS @"rooms"
#define J_ROOMS_ROOM @"room"
#define J_ACHIEVEMENTS @"achievements"
#define J_LOCKS @"unlocks"
#define J_MEMBERSHIPS @"memberships"
#define J_CODE @"code"
#define J_MERCHANDISES @"merchandises"
#define J_PURCHASES @"purchases"
#define J_USER @"user"
#define J_OWNERSHIPS @"ownerships"
#define J_GAME @"game"
#define J_ROOM @"room"

@interface PNDataModel : NSObject {
	NSString* min_version;
	NSString* max_version;
}
@property (nonatomic, retain) NSString* min_version;
@property (nonatomic, retain) NSString* max_version;
- (id)initWithDictionary:(NSDictionary*)aDictionary;
+ (id)dataModelWithDictionary:(NSDictionary*)aDictionary;
+ (NSArray*)dataModelsFromArray:(NSArray*)anArray;
+ (NSArray*)availableDataModelsFromArray:(NSArray*)anArray inVersion:(int)version;
- (BOOL)isAvailableInVersion:(int)versionInt;
@end
