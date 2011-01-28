#import "PNRoomManager.h"
#import "PNManager.h"
#import "PNRoom.h"
#import "PNRoom+Package.h"
#import "PNRoomDelegate.h"
#import "PNLocalRoom.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNPeer.h"
#import "PNPeer+Package.h"
#import "PNGKSession.h"
#import "PNGameSession.h"
#import "PNGameSession+Package.h"
#import "PNHTTPRequestHelper.h"
#import "PNServiceNotifyDelegate.h"
#import "JsonHelper.h"
#import "PNSubscription.h"
#import "PNUDPConnectionService.h"
#import "PNNetworkUtil.h"
#import "PNInvitationRequestHelper.h"
#import "PNRoomModel.h"
#import "PNEventModel.h"
#import "PNMembershipModel.h"
#import "PNMatchModel.h"
#import "PNMatchRequestHelper.h"
#import "PNRoomRequestHelper.h"
#import "PNMembershipModel.h"
#import "PNLogger+Package.h"
#import "PNGlobal.h"
#import "PNRequestKeyManager.h"
#import "PNLobbyModel.h"
#import "PNSettingManager.h"
#import "PNGlobalManager.h"
#import "PNGameManager.h"
#import "PNNotificationNames.h"

extern NSNumber *inetToLongLong(const char* host,int port);

@interface PNRoomManager ()
@property (nonatomic, retain) NSString* currentJoinRequestKey;
@end

@interface PNRoomManager (Private)
- (void)didReceiveMatchStartPacket:(NSString*)data userInfo:(id)userInfo eventModel:(PNEventModel*)eventModel;
- (void)startPairingWithPeers:(NSArray*)peers room:(PNRoom*)room;
- (void)pairingSucceeded;
- (void)pairingFailed:(PNError*)error;
- (void)requestJoinInternetRoom:(PNRoom*)room delegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector withObject:(id)object;
@end

@implementation PNRoomManager
@synthesize currentJoinRequestKey;
@synthesize delegate;
@synthesize rooms;
@synthesize currentRoom;
@synthesize currentRoomDelegate;
@synthesize gkSession;

- (id) init {
	if (self = [super init]) {
		delegate = nil;
		rooms = [[NSMutableDictionary dictionary] retain];
		self.currentRoom = nil;
		self.currentRoomDelegate = nil;
		self.gkSession = [PNGKSession create];
	}
	return  self;
}

-(int)createRoomWithMemberNumAndGrade:(int)memberNum
						  publishFlag:(BOOL)publishFlag
							 roomName:(NSString*)name
						   gradeRange:(NSString*)gradeRange
							  lobbyId:(int)lobbyId
						 roomDelegate:(id<PNRoomDelegate>)_roomDelegate
{
	self.currentRoomDelegate = _roomDelegate;
	[rooms removeAllObjects];
	NSString *session = [PNUser currentUser].sessionId;
	[PNRoomRequestHelper create:session
					publishFlag:publishFlag
					 maxMembers:memberNum
						   name:name
					 gradeRange:gradeRange
						lobbyId:lobbyId
					   delegate:self
					   selector:@selector(createResponse:)
					 requestKey:@"PNRoomCreate"
	 ];
	
	[PNUDPConnectionService rebind];
	return -1;
}

-(void)createAnInternetRoomWithMaxMemberNum:(int)memberNum
								  isPublic:(BOOL)isPublic
								  roomName:(NSString*)name
								gradeRange:(NSString*)gradeRange
									lobbyId:(int)lobbyId
								  delegate:(id)aDelegate
							   onSucceeded:(SEL)onSucceededSelector
								  onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate 
											 onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector
													  withObject:nil];
	NSString *session = [PNUser currentUser].sessionId;
	[PNRoomRequestHelper create:session
					publishFlag:isPublic
					 maxMembers:memberNum
						   name:name
					 gradeRange:gradeRange
						lobbyId:lobbyId
					   delegate:self
					   selector:@selector(createAnInternetRoomResponse:)
					 requestKey:requestKey];
	[PNUDPConnectionService rebind];
}
- (void)createAnInternetRoomResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSDictionary*	json = [response jsonDictionary];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onFailedSelector = request.onFailedSelector;
	
	if(response.isValidAndSuccessful) {
		PNRoom* room				= [[[PNRoom alloc] init] autorelease];
		NSDictionary* roomDic		= [json objectForKey:@"room"];
		NSString* roomId			= [roomDic objectForKey:@"id"];
		NSString* maxMembers		= [roomDic objectForKey:@"max_members"];
		NSString* name				= [roomDic objectForKey:@"name"];
		NSString* publishFlag		= [roomDic objectForKey:@"is_public"];
		
		room.roomId				= roomId;
		room.roomName			= name;
		room.maxMemberNum			= [maxMembers intValue];
		room.isPublished		= [publishFlag boolValue];
		room.isOwner			= YES;
		
		if ([aDelegate respondsToSelector:request.onSucceededSelector]){
			[aDelegate performSelector:request.onSucceededSelector withObject:room];
		}
		
		
		PNPeer* peer;
		PNUDPConnectionService* stun;
		
		stun			= [PNUDPConnectionService sharedObject];
		peer			= stun.selfPeer;
		peer.joinedNumber = room.joinCount++;
		
		
		// Stun check is not over yet.
		if(!peer.address) {
			// TODO エラーハンドリング
			//			if([delegate respondsToSelector:@selector(didFailCreateRoom:requestId:)])
			//				[delegate didFailCreateRoom:room requestId:-1];
			
			return;
		}
		
		
		room.gameSession.selfPeer	= peer;
		room.gameSession.room		= room;
		
		[room.peers setObject:peer forKey:inetToLongLong([peer.address UTF8String], peer.udpPort)];
		
		if([room.delegate respondsToSelector:@selector(room:didJoinUser:)])
			[room.delegate room:room didJoinUser:peer.user];
		PNLogMethod(@"-(void)createResponse:(NSNotification*)n");
		if([room.delegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
			[room.delegate room:room didUpdateJoinedUsers:[NSArray arrayWithObjects:peer.user,nil]];
		
		
		
		[rooms removeAllObjects];
		[rooms setObject:room forKey:room.roomId];
		[PNUDPConnectionService sharedObject].currentRoom = room;
		
		
		self.currentRoom = room;
		
		if([delegate respondsToSelector:@selector(didCreateRoom:requestId:)])
			[delegate didCreateRoom:room requestId:-1];
	} else {
		if ([aDelegate respondsToSelector:onFailedSelector]){
			[aDelegate performSelector:onFailedSelector withObject:nil];
		}
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}


-(void)createResponse:(PNHTTPResponse*)response
{
	
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"createResponse %@",resp);
	
	if(response.isValidAndSuccessful) {
		PNRoom* room				= [[[PNRoom alloc] init] autorelease];
		NSDictionary* roomDic		= [json objectForKey:@"room"];
		NSString* roomId			= [roomDic objectForKey:@"id"];
		NSString* maxMembers		= [roomDic objectForKey:@"max_members"];
		NSString* name				= [roomDic objectForKey:@"name"];
		NSString* publishFlag		= [roomDic objectForKey:@"is_public"];
		
		room.roomId				= roomId;
		room.roomName			= name;
		room.maxMemberNum			= [maxMembers intValue];
		room.isPublished		= [publishFlag boolValue];
		room.isOwner			= YES;
		room.delegate			= self.currentRoomDelegate;
		
		
		PNPeer* peer;
		PNUDPConnectionService* stun;
		
		stun			= [PNUDPConnectionService sharedObject];
		peer			= stun.selfPeer;
		peer.joinedNumber = room.joinCount++;
		
		
		// Stun check is not over yet.
		if(!peer.address) {
			// TODO エラーハンドリング
//			if([delegate respondsToSelector:@selector(didFailCreateRoom:requestId:)])
//				[delegate didFailCreateRoom:room requestId:-1];
			
			return;
		}
		
		
		room.gameSession.selfPeer	= peer;
		room.gameSession.room		= room;
		
		[room.peers setObject:peer forKey:inetToLongLong([peer.address UTF8String], peer.udpPort)];
		
		if([room.delegate respondsToSelector:@selector(room:didJoinUser:)])
			[room.delegate room:room didJoinUser:peer.user];
		PNLogMethod(@"-(void)createResponse:(NSNotification*)n");
		if([room.delegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
			[room.delegate room:room didUpdateJoinedUsers:[NSArray arrayWithObjects:peer.user,nil]];
		
		
		
		[rooms removeAllObjects];
		[rooms setObject:room forKey:room.roomId];
		[PNUDPConnectionService sharedObject].currentRoom = room;
		
		
		self.currentRoom = room;
		
		if([delegate respondsToSelector:@selector(didCreateRoom:requestId:)])
			[delegate didCreateRoom:room requestId:-1];
		
		NSString* session = [PNUser session];
		
		[PNRoomRequestHelper members:session
				   room:room.roomId
			   delegate:self
			   selector:@selector(showResponse:)
			 requestKey:@"showResponse"];
	} else {
		
		if([delegate respondsToSelector:@selector(didFailToCreateARoomWithError:)]){
			PNError* error = [PNError errorFromResponse:resp];
			NSString* errorSubcode = [[resp JSONValue] objectForKey:@"subcode"];
			if ([errorSubcode isEqualToString:@"coin"]) {
				error.errorType = kPNRoomErrorFailedNoCoins;
			}
			[delegate didFailToCreateARoomWithError:error];
		}
	}
}

-(void)showResponse:(PNHTTPResponse*)response
{
	NSDictionary*	json	= [response jsonDictionary];
	if(response.isValidAndSuccessful) {
		PNUser *selfUser = [PNUser currentUser];
		NSArray* ms = [json objectForKey:@"members"];
		selfUser.publicSessionId = [[ms objectAtIndex:0] objectForKey:@"session"];
	}
}

-(void)subscriptionAddRoomResponse:(PNHTTPResponse*)response
{
	NSDictionary *json = [response jsonDictionary];
	PNLog(@"%@",json);
	if(response.isValidAndSuccessful)
	{
		
	}
}

-(void)showRoom:(NSString*)roomId
{
	NSString* session = [PNUser currentUser].sessionId;
	
	[PNRoomRequestHelper show_room:session
							roomId:roomId
						  delegate:self
						  selector:@selector(showRoomResponse:)
						requestKey:@"PNShowRoom"];
}

- (void)showRoomResponse:(NSNotification*)n
{
	NSString *resp = n.object;
	NSDictionary *json = [resp JSONValue];

	NSDictionary* roomDic = [json objectForKey:J_ROOM];
	if (roomDic) {		
		PNRoomModel* roomModel = [PNRoomModel dataModelWithDictionary:roomDic];
		PNRoom* room = [[[PNRoom alloc] init] autorelease];
		[room setRoomModel:roomModel];
		room.lobby = [[[PNLobby alloc] init] autorelease];
		room.lobby.lobbyId = roomModel.lobby_id;
		
		if ([delegate respondsToSelector:@selector(didGetShowRoom:requestId:)]) {
			[delegate didGetShowRoom:room requestId:-1];
		}
		
	}
}
#pragma mark -
- (void)joinInternetRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate 
											 onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector
													  withObject:room];
	PNSplitLog(PNLOG_CAT_LIMITED_MATCHLOG);
	PNSplitLog(PNLOG_CAT_INTERNET_MATCH);
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Joining internet room...");
	// NATチェックが終了していなければ、ネットワークのチェックが終わってないことをユーザーに通知する。
	PNUDPConnectionService* udpservice = [PNUDPConnectionService sharedObject];
	if(udpservice.isChecked) {
//TODO:		room.cancelJoiningFlag = NO;
		room.isRequestingJoining = YES;
		self.currentRoom = room;
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Getting members of the room...");
		[[PNManager roomManager] getMembersOfRoom:room delegate:self
									  onSucceeded:@selector(getMembersSucceeded:requestKey:) 
										 onFailed:@selector(getMembersFailed:requestKey:)
									   withObject:requestKey];
	}
}
/**
 * ルームメンバーの取得に成功した場合に呼ばれます。
 * ルームが既に削除されていた場合は、getMembersFailed:requestKey:が呼ばれます。
 */
- (void)getMembersSucceeded:(NSArray*)peers requestKey:(NSString*)requestKey
{
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onFailedSelector = request.onFailedSelector;
	PNRoom* room = (PNRoom*)(request.object);
	
	//定員に達していたらJOINをキャンセルします
	if (room.maxMemberNum <= [peers count]){
		[room cancelJoining];
		
		//定員に達していてJOINできないことを通知します
		if ([aDelegate respondsToSelector:onFailedSelector]){
			PNError* error = [[[PNError alloc] init] autorelease];
			error.errorType = kPNRoomErrorFailedAlreadyStarted;
			[aDelegate performSelector:onFailedSelector withObject:error];
		}
		[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
		return;
	}
	
	self.currentJoinRequestKey = requestKey;
	self.currentRoom = room;
	[self startPairingWithPeers:peers room:room];
}
- (void)getMembersFailed:(PNError*)error requestKey:(NSString*)requestKey
{
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onFailedSelector = request.onFailedSelector;
	
	if ([aDelegate respondsToSelector:onFailedSelector]){
		PNError* error = [[[PNError alloc] init] autorelease];
		error.errorType = kPNRoomErrorFailedAlreadyDeleted;
		[aDelegate performSelector:onFailedSelector withObject:error];
	}
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
- (void)startPairingWithPeers:(NSArray *)peers room:(PNRoom *)room
{
	PNCLog(PNLOG_CAT_INTERNET_MATCH,@"Starting pairing with peers... Current:%@",currentJoinRequestKey);
	PNUDPConnectionService* udpservice = [PNUDPConnectionService sharedObject];
	PNPeer* selfPeer			= udpservice.selfPeer;
	room.gameSession.selfPeer	= selfPeer;
	room.gameSession.room		= room;
	
	
	// 初期化
	// ペアリングカウンターを初期化
	room.pairingCounter = 0;
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"PairingCounter cleared. Current value is...%d", room. pairingCounter);
	// 順番決め
	room.joinCount = 0;
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Cleaning pairing table...");
	[PNUDPConnectionService deletePairingTable:[room.pairingTable allValues]];	
	[room.peers removeAllObjects];
	PNLog(@"-------------------remove------------------");
	[room.pairingTable removeAllObjects];
	[room.roomMembers removeAllObjects];
	[PNPacketFireWall clear];
	
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Updating room member list...");
	for(PNPeer* peer in peers) {
		[room.roomMembers addObject:peer];
	}
	
	NSMutableArray* userArray = [NSMutableArray array];
	for(PNPeer* ePeer in room.roomMembers) {
		[userArray addObject:ePeer.user];
	}
	PNLogMethod(@"-(void)responseMembers:(NSNotification*)n");
	
	
	
	
	for(PNPeer* p in room.roomMembers) {
		p.joinedNumber		= room.joinCount++;
	}
	selfPeer.joinedNumber	= room.joinCount++;
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Your join number is %d.", selfPeer.joinedNumber);
	
	[room.peers setObject:selfPeer forKey:inetToLongLong([selfPeer.address UTF8String], selfPeer.udpPort)];
	
	//最新のユーザーリストをデリゲート先に渡しておきます
	PNRequestObject* request = [PNRequestKeyManager requestForKey:currentJoinRequestKey];
	if (request){
		id aDelegate = request.delegate;
		if([aDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)]){
			[aDelegate room:room didUpdateJoinedUsers:userArray];
		}
	}
	
	//対戦相手とのペアリングを開始します
	for(PNPeer *p in room.roomMembers) {
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@ registered to the pairing table.", p.user.publicSessionId);
		[room.pairingTable setObject:p forKey:p.user.publicSessionId];
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Start pairing with %@ (SessionId:%@)...", p.user.username, p.user.publicSessionId);
		[PNUDPConnectionService startPairingWithDelegate:(id<PNUDPConnectionServiceDelegate>)self
													room:room
											  ownSession:[PNUser session]
										 opponentSession:p.user.publicSessionId];
	}
}
/**
 * @brief ペアリングが正常に完了したときに呼ばれます
 */
- (void)pairingSucceeded
{
	//HTTP経由でJOINリクエストを発行します
	[self requestJoinInternetRoom:currentRoom delegate:self onSucceededSelector:@selector(joinFinallySucceeded:) 
				 onFailedSelector:@selector(joinFinallyFailed:requestKey:) withObject:currentJoinRequestKey];
}
/**
 * @brief ペアリングが失敗したときに呼ばれます。
 */
- (void)pairingFailed:(PNError*)error;
{
	PNWarn(@"Pairing failed");
		
	//ペアリングテーブル等を全部クリアします
	[PNUDPConnectionService deletePairingTable:[currentRoom.pairingTable allValues]];
	[PNPacketFireWall clear];
	[currentRoom.pairingTable removeAllObjects];
	
	//デリゲート先に失敗したことを通知します
	PNRequestObject *request = [PNRequestKeyManager requestForKey:currentJoinRequestKey];
	if ([request.delegate respondsToSelector:request.onFailedSelector]){
		[request.delegate performSelector:request.onFailedSelector withObject:error];
	}
	
	if(self.currentJoinRequestKey)
		[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:currentJoinRequestKey];
	self.currentJoinRequestKey = nil;
	currentRoom = nil;
}
#pragma mark -
- (void)joinFinallySucceeded:(NSString*)requestKey
{
	//デリゲート先に成功したことを通知します
	PNRequestObject *request = [PNRequestKeyManager requestForKey:currentJoinRequestKey];
	if ([request.delegate respondsToSelector:request.onSucceededSelector]){
		[request.delegate performSelector:request.onSucceededSelector];
	}
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:currentJoinRequestKey];
}
- (void)joinFinallyFailed:(PNError*)error requestKey:(NSString*)requestKey
{
	//ペアリングテーブル等を全部クリアします
	[PNUDPConnectionService deletePairingTable:[currentRoom.pairingTable allValues]];
	[PNPacketFireWall clear];
	[currentRoom.pairingTable removeAllObjects];
	
	//デリゲート先に失敗したことを通知します
	PNRequestObject *request = [PNRequestKeyManager requestForKey:currentJoinRequestKey];
	if ([request.delegate respondsToSelector:request.onFailedSelector]){
		[request.delegate performSelector:request.onFailedSelector withObject:error];
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:currentJoinRequestKey];
	self.currentJoinRequestKey = nil;
	currentRoom = nil;
}
#pragma mark -
#pragma mark STUN related methods
-(void)stunService:(PNUDPConnectionService*)service didError:(PNNetworkError*)error
{
	NSString* errorMessage = [NSString stringWithFormat:@"Stun service error: %@", error.message];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@", errorMessage);
	PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, errorMessage);
	
	if (currentRoom.isRequestingJoining == YES){	//入室処理中におこったエラーであれば通知し退室します
		PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Error while requesting joining");
		[currentRoom leave];
		
		// JOINに失敗したことを通知します。
		
		//TODO: エラー通知のへんこう
		/*
		if([delegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
			[delegate room:currentRoom didFailJoinWithError:error];
		}
		 */
		[self pairingFailed:error];
	}
	
}

-(void)stunService:(PNUDPConnectionService*)service didReport:(NSString*)report
{
}

-(void)stunService:(PNUDPConnectionService*)service willStartPairing:(PNPeer*)peer
{
}

-(void)stunService:(PNUDPConnectionService*)service didDonePairing:(PNPeer*)peer
{
	PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Pairing done.");
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@ とのペアリングに成功しました。", peer.user.username);
	
	if(peer.rtt <= service.connectionPermissibleRangeSpeed) {
		currentRoom.pairingCounter++;
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"現在、ルームメンバー %d 人中 %d 人とペアリングが完了しています。",[currentRoom.roomMembers count], currentRoom.pairingCounter);
		
		// すべてのユーザーとペアリングが終了していれば、JOINする。
		if(currentRoom.isJoined == NO && [currentRoom.roomMembers count] == currentRoom.pairingCounter) {
			// PNRoomManagerのTCP経由でゲームスタート
			[self performSelector:@selector(pairingSucceeded) withObject:nil afterDelay:1];
//			[currentRoom performSelector:@selector(lazyJoin) withObject:nil afterDelay:1];
		}
	} else {
		PNNetworkError *e = [[[PNNetworkError alloc] init] autorelease];
		e.message = @"Permissible range RTT speed is over.";
		e.errorType = kPNStunPunchingRTTOverrange;
		
		NSString* errorMessage = [NSString stringWithFormat:@"Stun service error: %@", e.message];
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@", errorMessage);
		PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, errorMessage);
		
		if (currentRoom.isRequestingJoining == YES){	//入室処理中におこったエラーであれば通知し退室します
			[self pairingFailed:e];
			/*
			PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Error while requesting joining");
			[currentRoom leave];
			
			// JOINに失敗したことを通知します。
			if([delegate respondsToSelector:@selector(room:didFailJoinWithError:)]) {
				[delegate room:currentRoom didFailJoinWithError:e];
			}*/
		}
	}
}

#pragma mark -
#pragma mark Primitive Requests / Responses
/**
 * ここから下のブロックは、基本的にPANKIAサーバAPIの呼び出しとその結果をパースしてデリゲートメソッドを呼ぶためのメソッド郡です。
 */
- (void)findRandomRooms:(int)maxCount delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
			   onFailed:(SEL)onFailedSelector
{
	[self findRooms:maxCount inLobby:-1 delegate:aDelegate onSucceeded:onSucceededSelector onFailed:onFailedSelector];
}

- (void)findRooms:(int)maxCount inLobby:(int)lobbyId delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
		 onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate 
											 onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector];
	[PNRoomRequestHelper find:[PNUser session] 
					   except:nil 
						limit:maxCount 
					  gradeId:[PNUser currentUser].gradeId 
					  lobbyId:lobbyId
					 delegate:self
					 selector:@selector(findRandomRoomsResponse:) 
				   requestKey:requestKey];
}
- (void)findRandomRoomsResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp = [response jsonString];
	NSDictionary*	responseDictionary = [response jsonDictionary];
	
	id aDelegate = [PNRequestKeyManager delegateForRequestKey:requestKey];
	SEL onSucceededSelector = [PNRequestKeyManager onSucceededSelectorForRequestKey:requestKey];
	SEL onFailedSelector = [PNRequestKeyManager onFailedSelectorForRequestKey:requestKey];

	if(response.isValidAndSuccessful) {
		NSMutableArray* roomArray = [NSMutableArray array];
		
		NSArray* rawRoomsArray = [PNRoomModel dataModelsFromArray:[responseDictionary objectForKey:J_ROOMS]];
		for (PNRoomModel* roomModel in rawRoomsArray) {
			if (roomModel.is_locked == NO	//ロックされていない部屋だけを追加します
			 	&& [roomModel.memberships count] < roomModel.max_members
				)	//最大人数より少ない場合のみ追加します
			{
				PNRoom* room			= [[[PNRoom alloc] init] autorelease];
				[room setRoomModel:roomModel];
				[roomArray addObject:room];
			}
		}
		
		if([aDelegate respondsToSelector:onSucceededSelector]){
			[aDelegate performSelector:onSucceededSelector withObject:roomArray];
		}		
	} else {
		PNError* error = [[PNError alloc] initWithResponse:resp];
		if([aDelegate respondsToSelector:onFailedSelector]){
			[aDelegate performSelector:onFailedSelector withObject:error];
		}				
	}	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
	
}
#pragma mark -
- (void)getMembersOfRoom:(PNRoom *)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	[self getMembersOfRoom:room delegate:aDelegate onSucceeded:onSucceededSelector 
				  onFailed:onFailedSelector withObject:nil];
}
- (void)getMembersOfRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
				onFailed:(SEL)onFailedSelector withObject:(id)object
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate 
											 onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector
													  withObject:object];
	[PNRoomRequestHelper members:[PNUser session] room:room.roomId delegate:self 
						selector:@selector(getMembersOfRoomResponse:) requestKey:requestKey];
}
- (void)getMembersOfRoomResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSDictionary* responseDictionary = [response jsonDictionary];
	NSString* resp = [response jsonString];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onSucceededSelector = request.onSucceededSelector;
	SEL onFailedSelector = request.onFailedSelector;
	id object = request.object;
	
	if(response.isValidAndSuccessful) {
		PNRoomModel *roomModel = [PNRoomModel dataModelWithDictionary:responseDictionary];
		NSMutableArray* peers = [NSMutableArray array];
		for (PNMembershipModel *membership in roomModel.memberships) {
			PNPeer *peer				= [PNPeer createPeer];
			PNUser* u					= [[[PNUser alloc] initWithUserModel:membership.user] autorelease];
			peer.user					= u;
			peer.user.publicSessionId	= membership.id;
			peer.address				= membership.ip;
			[peers addObject:peer];
		}
		
		if (object){
			if ([aDelegate respondsToSelector:onSucceededSelector]){
				[aDelegate performSelector:onSucceededSelector withObjects:[NSArray arrayWithObjects:peers, object, nil]];
			}
		} else {
			if([aDelegate respondsToSelector:onSucceededSelector]){
				[aDelegate performSelector:onSucceededSelector withObject:peers];
			}
		}	
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		NSDictionary*	responseDictionary = [resp JSONValue];
		if([[responseDictionary objectForKey:J_CODE] isEqualToString:@"not_found"]) {
			error.errorType = kPNRoomErrorFailedAlreadyDeleted;
		}
		
		if (object){
			if([aDelegate respondsToSelector:onFailedSelector]){
				[aDelegate performSelector:onFailedSelector withObjects:[NSArray arrayWithObjects:error, object, nil]];
			}
		} else {
			if([aDelegate respondsToSelector:onFailedSelector]){
				[aDelegate performSelector:onFailedSelector withObject:error];
			}
		}			
	}	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
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
	NSString* requestKey	= [response requestKey];
	NSString*		resp	= [response jsonString];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onSucceededSelector = request.onSucceededSelector;
	SEL onFailedSelector = request.onFailedSelector;
	
	if(response.isValidAndSuccessful) {
		if([aDelegate respondsToSelector:onSucceededSelector]){
			[aDelegate performSelector:onSucceededSelector];
		}		
	} else {
		PNError* error = [[PNError alloc] initWithResponse:resp];
		if([aDelegate respondsToSelector:onFailedSelector]){
			[aDelegate performSelector:onFailedSelector withObject:error];
		}				
	}	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
- (void)requestJoinInternetRoom:(PNRoom*)room delegate:(id)aDelegate onSucceededSelector:(SEL)onSucceededSelector onFailedSelector:(SEL)onFailedSelector withObject:(id)object
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:aDelegate onSucceededSelector:onSucceededSelector 
												onFailedSelector:onFailedSelector withObject:object];
	[PNRoomRequestHelper join:[PNUser session] room:room.roomId delegate:self selector:@selector(requestJoinInternetRoomResponse:) requestKey:requestKey];
}
- (void)requestJoinInternetRoomResponse:(PNHTTPResponse*)response
{
	NSString* requestKey	= [response requestKey];
	NSString* resp			= [response jsonString];
	NSDictionary* json		= [response jsonDictionary];
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	id aDelegate = request.delegate;
	SEL onSucceededSelector = request.onSucceededSelector;
	SEL onFailedSelector = request.onFailedSelector;
	id object = request.object;

	if(response.isValidAndSuccessful) {
		currentRoom.isJoined = YES;
		NSArray *memberships = [json objectForKey:J_MEMBERSHIPS];
		NSMutableArray *membershipModels = [NSMutableArray array];
		for (NSDictionary *membership in memberships){
			PNMembershipModel* membershipModel = [PNMembershipModel dataModelWithDictionary:membership];
			[membershipModels addObject:membershipModel];
		}
		
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Joined member count: %d", [membershipModels count]);
		for(PNMembershipModel *membershipModel in membershipModels) {
			PNCLog(PNLOG_CAT_INTERNET_MATCH,@"- %@ (SessionID: %@ )", membershipModel.user.username , membershipModel.id );
		}
		
		AsyncUdpSocket* socket = [PNUDPConnectionService sharedObject].udpSocket;
		for(PNPeer* peer in [currentRoom.pairingTable allValues])
			peer.isConnecting = YES;
		currentRoom.isHeartBeatNecessary = YES;
		
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Now Pairing..");
		for(PNPeer* peer in [currentRoom.pairingTable allValues]){
			PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@ (Sess.ID: %@)", peer.user.username, peer.user.publicSessionId);
		}
		
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Start heart beat.");
		[currentRoom heartbeatForP2PNATTable:socket];
		
		if ([aDelegate respondsToSelector:onSucceededSelector]){
			[aDelegate performSelector:onSucceededSelector withObject:object];
		}
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Join failed. response is %@", resp);
		
		NSString* errorSubcode = [json objectForKey:@"subcode"];
		if ([errorSubcode isEqualToString:@"locked"]){
			error.errorType = kPNRoomErrorFailedAlreadyStarted;
		} else if ([errorSubcode isEqualToString:@"coin"]) {
			error.errorType = kPNRoomErrorFailedNoCoins;
		} else {
			error.errorType = kPNRoomErrorFailedMemberChange;
		}
		
		if (object) {
			if([aDelegate respondsToSelector:onFailedSelector]){
				[aDelegate performSelector:onFailedSelector withObjects:[NSArray arrayWithObjects:error, object, nil]];
			}
		} else {
			if([aDelegate respondsToSelector:onFailedSelector]){
				[aDelegate performSelector:onFailedSelector withObject:error];
			}
		}	
	}
	
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
-(int)getActiveRooms {
	return -1;
}

-(void)lazyMatchRequest:(NSString*)value
{
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"HTTP Request match/start.");
	[PNMatchRequestHelper start:[PNUser session]
						   room:value
					   delegate:self
					   selector:@selector(matchStartResponse:)
					 requestKey:@"PNRoomManagerMatchStart"];
}

//room/joinのTCPパケットを受信したときにこのメソッドが呼ばれます
- (void)didReceiveRoomJoinPacket:(NSString*)data userInfo:(id)userInfo
					  eventModel:(PNEventModel*)eventModel value:(NSString*)value
{
	NSString *joinedUserSessionId = eventModel.data.membership.id;
	PNDebugNotice(PNLOG_CAT_INTERNET_MATCH, @"Join-packet(TCP) received.");
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"User join accepted. Joined user is %@", joinedUserSessionId);
	
	PNPeer* peer = [currentRoom.pairingTable objectForKey:joinedUserSessionId];
	if(peer == nil) {
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Peers in pairingTable (%d) are...", [[currentRoom.pairingTable allKeys] count]);
		for (NSString* key in [currentRoom.pairingTable allKeys]){
			PNCLog(PNLOG_CAT_INTERNET_MATCH, @"%@", key);
		}
	}
	// IPは上書きさせない。
	NSString* cacheAddress = [peer.address retain];
	[peer setMembershipModel:eventModel.data.membership];
	peer.address = cacheAddress;
	[cacheAddress release];

	// 部屋のメンバーリストに追加します
	if(peer) {
		[currentRoom addPeer:peer];
	} else {
		PNPeer* selfPeer = [PNUDPConnectionService sharedObject].selfPeer;
		if(![currentRoom.peers objectForKey:inetToLongLong([selfPeer.address UTF8String], selfPeer.udpPort)]) {
			if([selfPeer.user.username isEqualToString:eventModel.data.membership.user.username]) {
				[currentRoom addPeer:selfPeer];
			}
		}
	}
	
	// ユーザがJOINしたことを通知します
	[[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:kPNInternetMatchRoomStateChange object:currentRoom]];

	// 定員に達したら対戦を開始します
	if(eventModel.data.maxed_out) {
		currentRoom.gameSession.recommendRTO = eventModel.data.max_rtt / 1000.0f;
		// TODO 一番番号の若い人が始めるようにしたいが、エラーのハンドリングが難しい。なので今は作成したオーナーがスタートすることに。
		if(currentRoom.isOwner) {
			[self performSelector:@selector(lazyMatchRequest:) withObject:value afterDelay:1];
		}
	} else {
		PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Room is not full.");
	}
	
	
	
	currentRoom.isRequestingJoining = NO;	//入室完了したことをセットしておく
	
	id<PNRoomDelegate> roomDelegate = currentRoom.delegate;
	if([roomDelegate respondsToSelector:@selector(room:didJoinUser:)])
		[roomDelegate room:currentRoom didJoinUser:peer.user];
	
	NSMutableArray* userArray = [NSMutableArray array];
	for(PNPeer* ePeer in [currentRoom.peers allValues]) {
		[userArray addObject:ePeer.user];
	}
	PNLogMethod(@"- (void)didReceiveRoomJoinPacket:(NSString*)data userInfo:(id)userInfo eventModel:(PNEventModel*)eventModel value:(NSString*)value");
	if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)]) {
		[roomDelegate room:currentRoom didUpdateJoinedUsers:userArray];
	}
	
	AsyncUdpSocket* sock = [PNUDPConnectionService sharedObject].udpSocket;
	currentRoom.isHeartBeatNecessary = YES;
	for(PNPeer* peer in [currentRoom.peers allValues])
		peer.isConnecting = YES;
	
	[currentRoom heartbeatForP2PNATTable:sock];
}
- (void)didReceiveMatchStartPacket:(NSString*)data userInfo:(id)userInfo eventModel:(PNEventModel*)eventModel{
	[currentRoom verify];
	
	for(PNPeer* p in [currentRoom.peers allValues]) {
		p.rto = currentRoom.gameSession.recommendRTO;
		p.rtt = currentRoom.gameSession.recommendRTO;
	}
	
	currentRoom.gameSession.peers = currentRoom.peers;
	[currentRoom performSelector:@selector(startGame) withObject:nil afterDelay:2];
}
- (void)didReceiveRoomLeavePacket:(NSString*)data userInfo:(id)userInfo
					   eventModel:(PNEventModel*)eventModel value:(NSString*)value
{
	PNRoom* room = self.currentRoom;
	PNGameSession* gameSession = room.gameSession;
	PNPeer* peer = [room.pairingTable objectForKey:eventModel.data.membership.id];
	if(!peer) {
		PNWarn(@"Leave packet: Notice:Peer is null.");
		return;
	}
	if(eventModel.data.membership.id) [room.pairingTable removeObjectForKey:eventModel.data.membership.id];
	if(inetToLongLong([peer.address UTF8String], peer.udpPort)) {
		[room removePeer:peer];
//		[room.peers removeObjectForKey:inetToLongLong([peer.address UTF8String], peer.udpPort)];
	}
	
	id<PNRoomDelegate> roomDelegate = room.delegate;
	id<PNGameSessionDelegate> gameSessionDelegate = gameSession.delegate;
	if([roomDelegate respondsToSelector:@selector(room:didLeaveUser:)])
		[roomDelegate room:room didLeaveUser:peer.user];
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"TCPBACKCHANNEL:room/leave %@ IP:%@",peer.user.username,peer.address);
	
	// ユーザがLEAVEしたことを通知します
	[[NSNotificationCenter defaultCenter] postNotification:
	 [NSNotification notificationWithName:kPNInternetMatchRoomStateChange object:currentRoom]];
	
	
	NSObject* delegateObject = gameSessionDelegate;
	if([delegateObject respondsToSelector:@selector(gameSession:didDisconnectPeer:)])
		[delegateObject performSelectorOnMainThread:@selector(gameSession:didDisconnectPeer:)
										withObjects:[NSArray arrayWithObjects:gameSession,peer,nil]];
	
	peer.isConnecting = NO;
	[PNPacketFireWall removeIPv4:peer.address port:peer.udpPort];
	
	NSMutableArray* userArray = [NSMutableArray array];
	for(PNPeer* ePeer in [room.peers allValues]) {
		[userArray addObject:ePeer.user];
	}
	PNLogMethod(@"- (void) notify:(NSString*)data userInfo:(id)userInfo");
	if([roomDelegate respondsToSelector:@selector(room:didUpdateJoinedUsers:)])
		[roomDelegate room:room didUpdateJoinedUsers:userArray];
	
	// ホストがLeaveした場合は、入った人の順で一番若い人がホストに。
	PNPeer* host = nil;
	int num = 0x7FFFFFFF;
	for(PNPeer* p in [room.peers allValues]) {
		if(num > p.joinedNumber) {
			host	= p;
			num		= p.joinedNumber;
		}
	}
	if(host == gameSession.selfPeer) {
		room.isOwner = YES;
	}
	
}

// TCP通知はここで受け取る（マルチデリゲート形式）
- (void) notify:(NSString*)data userInfo:(id)userInfo
{
	NSDictionary *json = [data JSONValue];
	PNCLog(PNLOG_CAT_TCP, @"PNRoomManager Notify = %@",json);
	if([JsonHelper isValid:json]) {
		
		if([(NSString*)[json objectForKey:J_STATUS] isEqualToString:J_STATUS_OK] && [json objectForKey:J_EVENTS]) {
			PNCLog(PNLOG_CAT_TCP, @"Status OK %@",currentRoom);
			if(currentRoom) {
				PNCLog(PNLOG_CAT_TCP, @"CurrentRoom");
				NSArray*		events;
				events	= [json objectForKey:J_EVENTS];
				
				// Eventに対するコマンド名が無いと判断できない。
				for(NSDictionary* event in events) {
					PNEventModel* eventModel = [PNEventModel dataModelWithDictionary:event];
					NSString* topic = eventModel.topic;
					NSArray* separatedTopic = [topic componentsSeparatedByString:@"/"];
					if([separatedTopic count] < 4) {
						PNLog(@"Invalid topic\n");
					}
					
					NSString* blank			= [separatedTopic objectAtIndex:0];
					(blank);
					NSString* controller	= [separatedTopic objectAtIndex:1];
					NSString* value			= [separatedTopic objectAtIndex:2];//etc RoomID,UserName, and so on.
					NSString* action		= [separatedTopic objectAtIndex:3];
					if([controller isEqualToString:J_EVENTS_TOPIC_ROOM]) {
						if([action isEqualToString:J_EVENTS_TOPIC_JOIN]) {
							[self didReceiveRoomJoinPacket:data userInfo:userInfo eventModel:eventModel value:value];
						} else if([action isEqualToString:J_EVENTS_TOPIC_LEAVE]) {
							[self didReceiveRoomLeavePacket:data userInfo:userInfo eventModel:eventModel value:value];
						} else if([action isEqualToString:J_EVENTS_TOPIC_SAY]) {
							// 何か言われた。
						} else if([action isEqualToString:J_EVENTS_TOPIC_REMOVE]) {
							// TODO Rematchの実装：キックされたので、戻る処理を書く。
						} else if([action isEqualToString:J_EVENTS_TOPIC_MATCHSTART]) {
							PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"TCPBACKCHANNEL:match/start");
							//{"status":"ok","counter":426,"events":[{"topic":"/room/PAtoFQ/match_start","data":{"match":{"id":3,"room_id":"PAtoFQ","users":[{"id":126,"username":"Akihito","country":"JP","icon_url":"http://staging.pankia.com/images/twitter/missing.png","install":{"achievement_status":{"achievement_point":0,"achievement_total":35}}},{"id":131,"username":"asdfadf","country":"JP","icon_url":"http://staging.pankia.com/images/twitter/missing.png","install":{"achievement_status":{"achievement_point":0,"achievement_total":35}}}],"start_at":"2010-03-19T11:59:29Z","end_at":null}}}]}
							//eventModel.match;
							[self didReceiveMatchStartPacket:data userInfo:userInfo eventModel:eventModel];
						} else if([action isEqualToString:J_EVENTS_TOPIC_MATCHFINISH]) {
							PNCLog(PNLOG_CAT_UNIMPORTANT, @"Match Finish.");
							currentRoom.gameSession.isStarted = NO;
							PNEventModel* event = [PNEventModel dataModelWithDictionary:[events objectAtIndex:0]];
							for (PNUserModel* user in event.data.match.users) {
								PNRoom* room = self.currentRoom;
								for(PNPeer* p in [room.peers allValues]) {
									if([p.user.username isEqualToString:user.username] && ![user.username isEqualToString:[PNUser currentUser].username] ){
										if(p.user.gradeEnabled){
											p.user.gradePoint = user.install.grade_status.grade_point;
										}
									}
								}
								
								PNCLog(PNLOG_CAT_UNIMPORTANT, @"User name is %@",user.username);
								if ([user.username isEqualToString:[PNUser currentUser].username]) {
									if ([PNUser currentUser].gradeEnabled) {//finish時にグレードポイントがあるゲームの場合はnotifを表示する
										int nowGradePoint = [PNUser currentUser].gradePoint;
										int newGradePoint = user.install.grade_status.grade_point;
										int changePoint   = (newGradePoint - nowGradePoint);

										[PNUser currentUser].gradePoint = newGradePoint;
										
										// コイン枚数を1枚減らします
										PNCLog(PNLOG_CAT_ITEM, @"match/finish received. coins decreased from %d",[PNUser currentUser].coins);
										[PNUser currentUser].coins--;
										
										NSMutableDictionary* params = [NSMutableDictionary dictionary];
										[params setObject:[NSNumber numberWithInt:changePoint] forKey:@"changePoint"];
										[params setObject:[NSNumber numberWithInt:newGradePoint] forKey:@"newGradePoint"];
										
										if([asyncBehaviorDelegate respondsToSelector:@selector(didPushNotificationBehavior:name:params:)])
											[asyncBehaviorDelegate didPushNotificationBehavior:self name:@"MATCH/FINISH" params:params];
										
										PNCLog(PNLOG_CAT_UNIMPORTANT, @"PNNotificationService showTextNotice end.");
										
									}
								}
							}
						}else{
							PNCLog(PNLOG_CAT_TCP, @"TCP Packet. Unknown action: %@", action);
						}
					}
				}
				
				//parse...
				
				
			} else {
				// Nothing todo.
				PNCLog(PNLOG_CAT_TCP, @"Pushed TCP message is invalid.");
			}
		} else {
			//ここに到達するのは、eventのない正常なパケット(接続維持等のための無意味なパケット)です

		}
	}
}

- (void)matchStartResponse:(PNHTTPResponse*)response
{
	PNCLog(PNLOG_CAT_LIMITED_MATCHLOG,@"HTTP Response match/start.");
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Match start response.");
	NSString *resp		= [response jsonString];
	PNCLog(PNLOG_CAT_INTERNET_MATCH, @"Recv : \n HTTP > %@",resp);
	if(response.isValidAndSuccessful) {
		
	} else {
		// Nothing todo.
	}
}



- (void) error:(PNError*)message userInfo:(id)userInfo
{
	PNLog(@"PNRoomManager:TCP:Notify:%@",message.message);
}

// Local
-(void)createLocalRoomWithMinMemberNum:(int)aMinNumberNum maxMemberNum:(int)aMaxMemberNum roomName:(NSString*)aName 
								 lobby:(PNLobby*)lobby
							  delegate:(id<PNRoomDelegate>)aDelegate
{
	[rooms removeAllObjects];
	
	PNLocalRoom *room;
	room				= [[[PNLocalRoom alloc] init] autorelease];
	room.roomName		= aName;
	room.delegate		= aDelegate;
	room.maxMemberNum	= aMaxMemberNum;
	room.minMemberNum	= aMinNumberNum;
	room.lobby = lobby;
	
	if(self.gkSession) [self.gkSession stop];
	self.currentRoom = room;
	self.gkSession = [PNGKSession create];
	self.gkSession.currentRoom = room;
	self.gkSession.roomDelegate = aDelegate;
	room.gameKitSession = self.gkSession;
	room.gameKitSession.roomManagerDelegate = delegate;
	
	if([delegate respondsToSelector:@selector(didCreateRoom:requestId:)])
		[delegate didCreateRoom:room requestId:-1];
	[rooms setObject:room forKey:aName];
	[room startService];
	
}

-(void)findLocalRoomsWithLobby:(PNLobby*)lobby
{
	[rooms removeAllObjects];
	if(self.gkSession) [self.gkSession stop];
	self.gkSession = [PNGKSession create];
	self.gkSession.roomManagerDelegate = delegate;
	[self.gkSession start:NO gameKey:[PNGlobalManager sharedObject].gameKey version:[[PNGameManager sharedObject] currentVersionStringValue] lobby:lobby];
}

-(void)stopFindActiveRooms
{
	if(self.gkSession) {
		[self.gkSession stop];
		self.gkSession = nil;
	}
}

-(int)countActiveRooms
{
	return [rooms count];
}

-(int)getActiveInvitedRooms
{
	
	NSString* session = [PNUser session];
	[PNInvitationRequestHelper rooms:session
							delegate:self
							selector:@selector(showInvitedRoomsResponse:)
						  requestKey:@"PNRoomInvitedRooms"];
	
	
	return -1;
}

// It was invited. 
-(void)showInvitedRoomsResponse:(PNHTTPResponse*)response
{
	NSString*		resp = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	
	PNLog(@"Invited rooms = %@",resp);
	if(response.isValidAndSuccessful) {
		NSMutableArray* invitedRooms = [NSMutableArray array];
		NSArray* roomsDic;
		roomsDic = [json objectForKey:J_ROOMS];
		for(NSDictionary* e in roomsDic) {
			PNRoom* room = [[[PNRoom alloc] init] autorelease];
			PNRoomModel* roomModel = [PNRoomModel dataModelWithDictionary:[e objectForKey:J_ROOMS_ROOM]];

			// 招待した人の名前が欲しいところ。
			room.roomId			= roomModel.id;
			room.roomName		= roomModel.name;
			room.maxMemberNum	= roomModel.max_members;
			room.isPublished	= roomModel.is_public;
			[invitedRooms addObject:room];
		}
	} else {
		PNLog(@"Invalid message.");
	}
}

-(void)terminate
{
	PNRoom* room = self.currentRoom;
	if(room)
		[room terminate];
}

-(void)dealloc {
	self.delegate = nil;
	self.currentRoom = nil;
	self.currentJoinRequestKey = nil;
	PNSafeDelete(rooms);
	[super dealloc];
}


-(void)didCreateRoom:(PNRoom*)room requestId:(int)requestId{
}

@end
