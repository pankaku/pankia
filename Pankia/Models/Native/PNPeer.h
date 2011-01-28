/** @file
 *  @brief PNPeerクラスのヘッダファイルです。
 *  @author Pankaku, Inc.
 */

#import "PNNetworkDefined.h"

@class PNUser;

/**
 * @brief P2P間通信をするときの相手との通信情報を担います。
 * 
 * 信頼層の通信はここのPeer構造体単位で制御します。
 * 相手との通信間で得た情報、RTT/RTOもこの構造体に保持されます。
 */
@interface PNPeer : NSObject {
@private
	PNUser*					user;		/**< @brief ユーザー */
	NSString*				address;	/**< @brief IPアドレス */
	float					rto;		/**< @brief Retransmission Time Out. RTO default value is RTT. */
	BOOL					isHost;
	
	int						udpPort;	/**< @brief UDPポート番号 */
	int						joinedNumber; /**< @brief ジョイン番号 */
	int						pairingNumber;
	int						subDeviceTime;
	double					packetTimeStamp;
	BOOL					isConnecting;
	BOOL					rematchFlag;
	BOOL					receivedRematchMessage;

	float					rtt;		/**< @brief Round trip time. */
	float					srtt;		/**< @brief Smoothed RTT. */
	float					rttvar;		/**< @brief RTTの偏差？ */
	float					icmpRtt;	/**< @brief ICMPのRTT */
	NSMutableDictionary*	received_packets_for_rtt; /**< @brief 受信パケットのRTT一覧 */
	NSMutableArray*			saved_rtts; /**< @brief 保存されたRTT一覧 */
	NSMutableDictionary*	saved_NTPTimeStamps; /**< @brief NTPパケットやり取りした時間を保存しておくコンテナ */
	
	int						sendSequenceCounter;	/**< @brief シーケンス送信カウンタ */
	int						readSequenceCounter;	/**< @brief シーケンス受信カウンタ */
	NSMutableArray* 		sendQueue;	/**< @brief 送信キュー */
	NSMutableArray* 		readQueue;	/**< @brief 受信キュー */
	NSMutableArray* 		sentPackets;	/**< @brief 送信済みパケット */
	NSMutableArray* 		readPackets;	/**< @brief 受信パケット */
	NSMutableDictionary*	syncPackets;	/**< @brief 時間同期用のパケットプール */
}

@property(retain,readonly)	PNUser*				user;
@property(retain,readonly)	NSString*			address;
@property(assign,readonly)	float				rto;
@property(assign,readonly)	BOOL				isHost;
@property(assign,readonly,getter=speedLevel)	PNConnectionLevel speedLevel;

@end
