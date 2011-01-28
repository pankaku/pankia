#import "NSThread+ControllerExt.h"

@interface PNRunLoop : NSObject {
	BOOL shouldKeepRunning;
}

+(NSThread*)createRunLoopWithDelegate:(id)delegate selector:(SEL)sel withObject:(id)obj key:(NSString*)k;
+(NSThread*)createRunLoopWithKey:(NSString*)k;
+(NSMutableDictionary*) getThreads;
+(NSMutableDictionary*) getRunLoops;
+(void)releaseAllThread;

@property(assign) BOOL shouldKeepRunning;
@end

