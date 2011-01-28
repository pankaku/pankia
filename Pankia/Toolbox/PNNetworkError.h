
#import "PNError.h"

#define kPNHTTPErrorFailed					0x1001 // サーバー接続に失敗した場合。
#define kPNHTTPErrorTimeout					0x1002 // タイムアウトした場合。
#define kPNHTTPErrorInvalid					0x1003 // レスポンスが４０４やサーバーエラー等Json以外のものである場合。
#define kPNHTTPErrorDisconnected			0x1004 // 接続がサーバーから切られた場合。

#define kPNTCPErrorFailed					0x1010 // サーバー接続に失敗した場合。
#define kPNTCPErrorTimeout					0x1011 // TCPのping/pongが帰ってこない場合。
#define kPNTCPErrorDisconnected				0x1012 // TCP接続がサーバーから切られた場合。
#define kPNTCPErrorAccept					0x1013 // クライアントソケットの作成に失敗した場合。
#define kPNTCPErrorRefused					0x1014 // 同じポートを占有していた場合。
#define kPNTCPErrorAlreadyClosed			0x1015 // 既にクローズされている場合。

#define kPNPeerErrorRefused					0x1021 // 同じポートを占有していた場合。
#define kPNPeerErrorTimeout					0x1022 // 接続にタイムアウトして失敗場合。
#define kPNPeerErrorDisconnected			0x1023 // パケットが途絶えた場合。

#define kPNUDPErrorFailed					0x1031 // UDPソケットが開けなかった場合。
#define kPNUDPErrorAlreadyClosed			0x1032 // UDPソケットが既に閉じていた場合。
#define kPNUDPErrorUnknown					0x1033 // その他のエラー
#define kPNUDPErrorAlreadyOpened			0x1034 // その他のエラー

#define kPNStunPunchingFailed				0x2051 // パンチに失敗した
#define kPNStunPunchingTimeout				0x2052 // パケットが通らなかった
#define kPNStunNatcheckFailed				0x2053 // NATチェックに失敗
#define kPNStunNatcheckTimeout				0x2054 // NATのタイプが判断出来ない場合
#define kPNStunPunchingRTTOverrange			0x2055 // RTTが規定値をオーバーした

#define kPNRoomErrorJoin					0x2001 // 参加出来なかった。

#define kPNSessionErrorInvalidUDID		0x3001	// UDIDが不正


@interface PNNetworkError : PNError {
	int requestId;
	int status;
}

@property(assign) int requestId;
@property(assign) int status;
+(PNNetworkError*)error;

@end
