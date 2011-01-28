// [NAT type]
typedef enum
{
	kPNUnknownNAT,
	kPNNoNAT,
	kPNFullConeNAT,
	kPNRestrectedConeNAT,
	kPNPortRestrectedConeNAT,
	kPNSymmetricNAT,
	kPNIPMasquerade
	
} PNNATType ;


// [Connection Level]
typedef enum
{
	kPNConnectionLevelHigh			= 1, // 高速な回線速度
	kPNConnectionLevelNormal		= 2, // 普通の回線速度
	kPNConnectionLevelLow			= 3, // 遅い回線速度
	kPNConnectionLevelNotRecommend	= 4, // プレイできないほど遅い回線速度
	kPNConnectionLevelUnknown		= 5, // 計測不能
	kPNConnectionLevelUnmeasurement	= 6  // 未計測
	
} PNConnectionLevel ;
