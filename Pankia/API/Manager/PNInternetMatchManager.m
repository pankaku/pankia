//
//  PNInternetMatchManager.m
//  no_dashboard
//
//  Created by sota2 on 10/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNInternetMatchManager.h"

#import "PNRequestKeyManager.h"
#import "Helpers.h"
#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNManager.h"
#import "PNPacketFireWall.h"
#import "PNRoomManager.h"
#import "PNRoomModel.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNRoomRequestHelper.h"
#import "PNUDPConnectionService.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNError.h"

static PNInternetMatchManager* _sharedInstance;

@implementation PNInternetMatchManager
#pragma mark Creating room
-(void) createAnInternetRoomWithMaxMemberNum:(int)memberNum isPublic:(BOOL)isPublic roomName:(NSString*)name
								  gradeRange:(NSString*)gradeRange lobbyId:(int)lobbyId delegate:(id)aDelegate
							 	 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector withObject:nil];
	NSString *session = [PNUser currentUser].sessionId;
	[PNRoomRequestHelper create:session publishFlag:isPublic maxMembers:memberNum name:name gradeRange:gradeRange
						lobbyId:lobbyId delegate:self selector:@selector(createAnInternetRoomResponse:) requestKey:requestKey];
}
- (void)createAnInternetRoomResponse:(PNHTTPResponse*)response
{
	if (response.isValidAndSuccessful) {
		PNRoom* room = [PNRoom modelFromDataModel:[PNRoomModel dataModelWithDictionary:[[response jsonDictionary] objectForKey:@"room"]]];
		room.isOwner = YES;	// 自分が作った部屋なので、自分がオーナーです
		
		// 作成した部屋をcurrentRoomにします。
		// ※PANKIAでは、一度に一つの部屋にしか入室できません。
		[PNManager sharedObject].roomManager.currentRoom = room;
	
		// 部屋に自身を追加します
		PNPeer* myPeer = [PNUDPConnectionService sharedObject].selfPeer;
		[room addPeer:myPeer];
		room.gameSession.selfPeer	= myPeer;
		room.gameSession.room		= room;
		
		[PNUDPConnectionService sharedObject].currentRoom = room;
		
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:response.requestKey withObject:room];
	} else {
		[PNRequestKeyManager callOnFailedSelectorAndRemove:response.requestKey withErrorFromResponse:response.jsonString];
	}
}
#pragma mark Finding rooms
- (void)findRooms:(int)maxCount inLobby:(int)lobbyId delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
		 onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate 
											 onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector];
	[PNRoomRequestHelper find:[PNUser session] except:nil limit:maxCount gradeId:[PNUser currentUser].gradeId 
					  lobbyId:lobbyId delegate:self selector:@selector(findRoomsResponse:) requestKey:requestKey];
}
- (void)findRoomsResponse:(PNHTTPResponse*)response
{
	if(response.isValidAndSuccessful) {
		NSArray* rooms = [PNRoom availableRoomsFromModels:[PNRoomModel dataModelsFromArray:[[response jsonDictionary] objectForKey:J_ROOMS]]];
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:response.requestKey withObject:rooms];
	} else {
		[PNRequestKeyManager callOnFailedSelectorAndRemove:response.requestKey withObject:[PNError errorFromResponse:response.jsonString]];
	}	
}
#pragma mark Leaving the room
- (void)leaveInternetRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
				 onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate 
											 onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector];
	[PNRoomRequestHelper leave:[PNUser session] room:room.roomId delegate:self 
					  selector:@selector(leaveInternetRoomResponse:) requestKey:requestKey];
	
	
	room.isJoined = NO;
	if(room.gameSession.isAlive) {
		[room.gameSession endGameSession];
	}
	
	room.isHeartBeatNecessary = NO;	//ハートビートをとめます
	[PNUDPConnectionService deletePairingTable:[room.pairingTable allValues]];	//ペアリング解除を依頼します
	[room.pairingTable removeAllObjects];	//ペアリングテーブルからピアを除外します
	[PNPacketFireWall clear];	//パケットファイアウォールをクリアします
}
- (void)leaveInternetRoomResponse:(PNHTTPResponse*)response
{
	if (response.isValidAndSuccessful) {
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:response.requestKey withObject:nil];
	} else {
		[PNRequestKeyManager callOnFailedSelectorAndRemove:response.requestKey withErrorFromResponse:response.jsonString];
	}
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

+ (PNInternetMatchManager *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}
@end
