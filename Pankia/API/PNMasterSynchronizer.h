//
//  PNMasterSynchronizer.h
//  PankakuNet
//
//  Created by sota on 10/11/22.
//  Copyright 2010 Pankaku. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PNMasterRevision;

@protocol PNMasterSynchronizerDelegate
/**! マスター情報の同期が完了した時にこのメソッドが呼ばれます。同期の必要がなく、変更がなかった場合にもこのメソッドが呼ばれます。 **/
- (void)masterSynchronizationDone;
/**! マスター情報の同期に失敗した時にこのメソッドが呼ばれます。 **/
- (void)masterSynchronizationFailed;
@end

/*! \brief マスター情報の同期を行うクラス
 *
 * サーバー負荷を減らし、アプリケーションリリース後でもマスター情報を更新できるようにするために用意されている機能です。
 * アチーブメントやアイテムのマスター情報がサーバー上で更新された場合に、
 * データをダウンロードしてきて、ローカルに保存します。
 * ローカルにリビジョン情報を保存しておき、必要がないと判断された場合はデータのダウンロードは行いません。
 * このオブジェクトはdelegateオブジェクトをretainします。相互参照に注意してください。
 *
 * 2010.11.22時点ではMerchandisesデータのみが同期されています。(負荷対策のため、優先度が高い)
 * Leaderboards, Lobbiesなどについては今後他の作業との兼ね合いをみながら実装していく予定です。
 */
@interface PNMasterSynchronizer : NSObject {
	id<NSObject, PNMasterSynchronizerDelegate> delegate;	/**! 注意:このdelegateはretainされます。 **/
	PNMasterRevision* currentRevision;						/**! 同期開始時点でのローカルのリビジョン情報が保持されます。 **/
	PNMasterRevision* revisionInfo;							/**! サーバーからダウンロードされたリビジョン情報が保持されます。 **/
}
/**! サーバーとの同期処理を開始し、処理が終わったらdelegateに結果を通知します。この処理は非同期です。 **/
+ (id)startWithDelegate:(id<PNMasterSynchronizerDelegate>)delegate;
@end
