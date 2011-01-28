/*
 *  LoggingConfig.h
 *  PankiaNet
 *
 *  コンソールにログとして表示するカテゴリの設定を記述するファイルです。
 *  YESにしたカテゴリのログのみがコンソールに表示されます。
 *  PNLogを使用した場合のカテゴリはPNLOG_CAT_UNDEFINEDです。
 */
#import "PNStandardLoggingConfig.h"

#define PNLOG_CAT_ACHIEVEMENT		NO
#define PNLOG_CAT_DB				NO
#define PNLOG_CAT_UI				YES
#define PNLOG_CAT_NIB_LOADER		NO
#define PNLOG_CAT_LEADERBOARDS		NO
#define PNLOG_CAT_TWITTER			NO
#define PNLOG_CAT_NOTIFICATION		NO
#define PNLOG_CAT_UPDATE_CHECK		NO
#define PNLOG_CAT_INTERNET_MATCH	NO
#define PNLOG_CAT_ENVIRONMENT		NO
#define PNLOG_CAT_ICMP				NO
#define PNLOG_CAT_LOCALMATCH		NO
#define PNLOG_CAT_NTP				NO
#define PNLOG_CAT_UHP				NO
#define PNLOG_CAT_UDP				NO
#define PNLOG_CAT_TCP				NO
#define PNLOG_CAT_HEARTBEAT			NO
#define PNLOG_CAT_PACKET_FIREWALL	NO
#define PNLOG_CAT_DASHBOARD			NO
#define PNLOG_CAT_LIMITED_MATCHLOG	NO
#define PNLOG_CAT_NETWORK_LOG		NO
#define PNLOG_CAT_LOCALDB			NO
#define PNLOG_CAT_ITEM				NO
#define PNLOG_CAT_GAME				NO
#define PNLOG_CAT_STORE				NO
#define PNLOG_CAT_FACEBOOK			NO

//-----------------------------------------------------------------------

// #define PNDEBUG_SHOW_RTT
