#import "PNLoggingConfig.h"
#import "PNLogger.h"

#ifdef DEBUG
#  define PNLog(...) PNCLog(PNLOG_CAT_UNDEFINED, __VA_ARGS__)
#  define PNNetworkLog(...) PNCLog(PNLOG_CAT_NETWORK_LOG, __VA_ARGS__) 
#  define PNLogMethod(msg) PNCLog(PNLOG_CAT_UNDEFINED, @"%s/%d::[%@]",__PRETTY_FUNCTION__, __LINE__,msg)
#else
#  define PNLog(...) ;
#  define PNLogMethod(msg) ;
#  define PNNetworkLog(...) ;
#endif