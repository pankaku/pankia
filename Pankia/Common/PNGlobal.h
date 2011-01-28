// [Push token type]
#define kPNPushTokenDevelopment		0x01
#define kPNPushTokenDistribution	0x02

// [Push notification] 
#ifdef DEBUG
#define kPNPushToken		kPNPushTokenDevelopment		// DEBUGが定義してあるときは、開発用のPushTokenを使います。
#else
#define kPNPushToken		kPNPushTokenDistribution	// リリースの場合は、AppStore用のリクエストをサーバーに送ります。
#endif

// [Server setting]
#define kPNEndpointBase							@"http://staging.pankia.com/api"
#define kPNPrimaryHost							@"ip1.staging.pankia.com"
#define kPNSecondaryHost						@"ip2.staging.pankia.com"
#define kPNSwitchaccountForgetSiteAddr          @"http://pankia.com/user/forgot"
#define kPNHelpSiteAddr							@"http://pankia.com/help"
#define kPNHomeScreenURL						@"http://localhost:3000/ui/"

#define kPNTCPBackchannelPort					6603
#define kPNUDPPrimaryPort   					6603
#define kPNUDPSecondaryPort 					6604


// [Software delay] ソフトウェアでパケットのディレイとロス率をコントロールする定数値
#define kPNSoftwareSendDelayTypeNone			0x00 // ディレイ無し
#define kPNSoftwareSendDelayTypeRandom			0x01 // ランダムにディレイが発生
#define kPNSoftwareSendDelayTypeSinewaveSmooth	0x02 // 5秒周期のSin波でディレイ（ネットワークの遅延の波をSinで疑似表現）
#define kPNSoftwareSendDelayTypeSinewaveIntense	0x03 // １秒周期のSin波でディレイ（ネットワークの遅延の波をSinで疑似表現）
#define kPNSoftwareSendDelayMinimum				100	// 1ms単位　パケットのディレイの下限値
#define kPNSoftwareSendDelayMaximum				100	// 1ms単位　パケットのディレイの上限値
#define kPNSoftwareSendPacketLossPercentage		0	// 1%単位　パケットのロス率

#define kPNSoftwareSendDelayType				kPNSoftwareSendDelayTypeNone // NONEの場合は、ディレイの設定値は無視されます。

// [Error types]
#define kPNErrorTypeDisconnectToServer			4097

// [P2P setting]
#define kPNHeartbeatTimeoutValue				5.0 // 相手とパケットが通らなくなってから切断検知までの秒数 5秒

// [HTTP Request setting]
#define kPNHTTPRequestTimeout					20.0f

// [Rematch]
#define kPNWaitReasonCoinPurchase				@"coin_purchase"

// BEGIN - lerry added code
// [Facebook related]
#define FACEBOOK_APPLICATION_ID			@"113618918667976"
#define FACEBOOK_SECRET					@"859d8f0a7d4921b183d193a56f71f535"
#define FACEBOOK_API_KEY				@"1d7a71b630b815b771f151e53452224b"
// END - lerry added code

/******************************
 * For UserInterface definition.
 *******************************/

// [Default font]
#define kPNDefaultFontName @"Verdana-bold"

#define	kPNDefaultLeaderboardID					2


//weak link for os 3
#ifdef __IPHONE_3_0
#define OS_3_ENUM(enumName) (id)enumName
#else
#define OS_3_ENUM(enumName) (id)0
#endif

// Notification View Settings
#define kPNNotificationViewDefaultAppearTime		3.0f
#define kPNNotificationViewDebugAppearTime			1.2f

// [Login setting]
#define	kPNLoginDelay								15

//MACROS
void halt(const char* functionname, int line, const char* message);

#define HALT(msg) { halt(__PRETTY_FUNCTION__,__LINE__,#msg);}


#ifdef __OBJC__

// [Property helper]
#define PNSETPROP(f,a)\
@synchronized(self) { id _obj_ = (f); (f) = [(a) retain]; if(_obj_)[_obj_ release];}
#define PNPSETPROP(f,a)\
@synchronized(self) { (f) = (a);}
#define PNGETPROP(type,f)\
type _obj_;@synchronized(self) { _obj_ = (f);} return _obj_;

//#define PNSafeDelete(x) { @synchronized(self) { if((x)) [(x) release]; (x) = nil; }}
#define PNSafeDelete(x) { if((x)) [(x) release]; (x) = nil; }

#endif

