@class PNRoom;

/**
 * @brief ルームマネージャのデリゲートのためのプロトコル
 */
@protocol PNRoomManagerDelegate <NSObject>

@optional

//-(void)fetchedRooms:(NSArray*)rooms;	//PNRoom
//-(void)fetchedMembers:(NSArray*)members;
//-(void)joinedUser:(PNUser*)aUser;		// (TCP)
//-(void)leavedUser:(PNUser*)aUser;		// (TCP)
//-(void)updatedMembers:(NSArray*)members;
//
//-(void)willGameStart:(PNGameSession*)aGameSession;
//-(void)beginGameStart:(PNGameSession*)aGameSession;
//-(void)endGameStart:(PNGameSession*)aGameSession;

-(void)roomError:(PNError*)anError;


/**
 * @brief Room IDからルームを取得完了した際呼ばれる
 * @param[in] room ルーム
 * @param[in] requestId リクエストに使用したキー
 */
-(void)didGetShowRoom:(PNRoom*)room requestId:(int)requestId;

/**
 * @brief ルームを作成完了した際呼ばれる
 * @param[in] room ルーム
 * @param[in] requestId リクエストに使用したキー
 */
-(void)didCreateRoom:(PNRoom*)room requestId:(int)requestId;
-(void)didFailToCreateARoomWithError:(PNError*)error;

/**
 * @brief アクティブローカルルームを検索完了した際呼ばれる
 * @param[in] rooms ルームの配列
 * @param[in] requestId リクエストに使用したキー
 */
-(void)didFindActiveRooms:(NSArray*)rooms requestId:(int)requestId;

/**
 * @brief エラー発生時に呼ばれる
 * @param[in] currentRoom 入室中または、入室しようとしているルーム
 * @param[in] e エラー
 */
-(void)room:(PNRoom*)currentRoom didFailWithError:(PNError*)e;

/**
 * @brief Joinエラー時に呼ばれる
 * @param[in] currentRoom 入室中または、入室しようとしているルーム
 * @param[in] e エラー
 */
-(void)room:(PNRoom*)currentRoom didFailJoinWithError:(PNError*)e;

@end


