#import "PNHTTPRequestHelper.h"

@interface PNRoomRequestHelper : PNHTTPRequestHelper {
	
}

+(void) remove:(NSString*)aSession
		  room:(NSString*)aRoom
		  user:(NSString*)aUser
	  delegate:(id)delegate
	  selector:(SEL)selector
	requestKey:(NSString*)key;

+(void) leave:(NSString*)session
		 room:(NSString*)room
	 delegate:(id)delegate
	 selector:(SEL)selector
   requestKey:(NSString*)key;

+(void) lock:(NSString*)aSession
		room:(NSString*)aRoom
	delegate:(id)delegate
	selector:(SEL)selector
  requestKey:(NSString*)key;

+(void) unlock:(NSString*)aSession
		  room:(NSString*)aRoom
	  delegate:(id)delegate
	  selector:(SEL)selector
	requestKey:(NSString*)key;


/** 
 * @brief ランダムにルームを探す
 * @param[in] session 対象セッション
 * @param[in] except 除外条件
 * @param[in] limit 上限数
 * @param[in] gradeId  roomを探す人のgradeID
 * @param[in] delegate デリゲートオブジェクト
 * @param[in] selector 取得が完了した際に呼ばれるメソッドのセレクタ
 * @param[in] key リクエストキー
 */
+(void) find:(NSString*)session
			 except:(NSString*)except
			  limit:(int)limit
			gradeId:(int)gradeId
	 lobbyId:(int)lobbyId
		   delegate:(id)delegate
		   selector:(SEL)selector
		 requestKey:(NSString*)requestKey;

+(void) findLobbiesWithDelegate:(id)delegate
					   selector:(SEL)selector
					 requestKey:(NSString*)key;

/**
 * @brief 　ルーム情報を取得する
 * @param[in] session 対象セッション
 * @param[in] roomId 対象ルームID
 * @param[in] delegate デリゲートオブジェクト
 * @param[in] selector 取得が完了した際に呼ばれるメソッドのセレクタ
 * @param[in] requestKey リクエストキー
 */
+(void) show_room:(NSString*)session
		   roomId:(NSString*)roomId
		 delegate:delegate
		 selector:(SEL)selector
	   requestKey:requestKey;


+(void)create:(NSString*)session
  publishFlag:(BOOL)publishFlag
   maxMembers:(int)maxMembers
		 name:(NSString*)name
   gradeRange:(NSString*)gradeRange
	  lobbyId:(int)lobbyId
	 delegate:(id)delegate
	 selector:(SEL)selector
   requestKey:(NSString*)requestKey;

/** 
 * @brief メンバー一覧を取得する
 * @param[in] session 対象セッション
 * @param[in] room 対象ルーム
 * @param[in] delegate デリゲートオブジェクト
 * @param[in] selector 取得が完了した際に呼ばれるメソッドのセレクタ
 * @param[in] key リクエストキー
 */
+(void) members:(NSString*)session
		   room:(NSString*)room
	   delegate:(id)delegate
	   selector:(SEL)selector
	 requestKey:(NSString*)key;

/** 
 * @brief ルームに入室する
 * @param[in] session 対象セッション
 * @param[in] room 対象ルーム
 * @param[in] delegate デリゲートオブジェクト
 * @param[in] selector 取得が完了した際に呼ばれるメソッドのセレクタ
 * @param[in] key リクエストキー
 */
+(void) join:(NSString*)session
		room:(NSString*)room
	delegate:(id)delegate
	selector:(SEL)selector
  requestKey:(NSString*)key;

@end
