#import "PNRunLoop.h"
#include <pthread.h>
#import "PNLogger+Common.h"

@implementation PNRunLoop
@synthesize shouldKeepRunning;

+(NSMutableDictionary*) getThreads
{
	static NSMutableDictionary* threadDictionary = nil;
	if(threadDictionary == nil) {
		threadDictionary = [[NSMutableDictionary alloc] init];
	}
	return threadDictionary;
}

+(NSMutableDictionary*) getRunLoops
{
	static NSMutableDictionary* runLoopDictionary = nil;
	if(runLoopDictionary == nil) {
		runLoopDictionary = [[NSMutableDictionary alloc] init];
	}
	return runLoopDictionary;
}

+(NSMutableDictionary*) getInstances
{
	static NSMutableDictionary* instances = nil;
	if(instances == nil) {
		instances = [[NSMutableDictionary alloc] init];
	}
	return instances;
}

+(NSThread*)createRunLoopWithKey:(NSString*)k
{
	return [PNRunLoop createRunLoopWithDelegate:@"" selector:nil withObject:@"" key:k];
}

+(NSThread*)createRunLoopWithDelegate:(id)delegate selector:(SEL)sel withObject:(id)obj key:(NSString*)k
{
	NSThread* thread;
	PNRunLoop* conThread;
	conThread		= [[[PNRunLoop alloc] init] autorelease];
	NSValue* v		= [NSValue valueWithPointer:sel];
	NSArray *params = [NSArray arrayWithObjects:delegate,v,obj,k,nil];
	thread			= [[NSThread alloc] initWithTarget:conThread
									   selector:@selector(threadfunc:)
										 object:params];
	[thread start];
	[[PNRunLoop getThreads] setObject:thread forKey:k];
	[[PNRunLoop getInstances] setObject:conThread forKey:k];
	
	return thread;
}

-(void)threadfunc:(id)obj
{
	
	NSAutoreleasePool* pool		= [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop			= [NSRunLoop currentRunLoop];
	NSArray* params				= obj;
	id<NSObject> delegate		= [params objectAtIndex:0];
	SEL selector				= (SEL)[(NSValue*)[params objectAtIndex:1] pointerValue];
	id arg						= [params objectAtIndex:2];
	NSString* key				= [params objectAtIndex:3];
	
	if(delegate && selector && [delegate respondsToSelector:selector]) [delegate performSelector:selector withObject:arg];
	
	[[PNRunLoop getRunLoops] setObject:runLoop forKey:key];
	
	self.shouldKeepRunning = YES; // Atomic
	while(self.shouldKeepRunning) {
#ifdef DEBUG
		NS_DURING
		[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		NS_HANDLER
		PNLog(@"Connection thread error.\nDescription:%@",[localException name]);
		PNLog(@"%@",[localException reason]);
		NS_ENDHANDLER
#else
		[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
#endif
		
	}
	
	[pool release];
}


+(void)releaseAllThread
{
	NSMutableDictionary* instances = [PNRunLoop getInstances];
	NSArray* arr = [instances allValues];
	for(PNRunLoop* ins in arr) {
		ins.shouldKeepRunning = NO;
	}
	[instances removeAllObjects];
	[[PNRunLoop getThreads] removeAllObjects];
	[[PNRunLoop getRunLoops] removeAllObjects];
}

@end
