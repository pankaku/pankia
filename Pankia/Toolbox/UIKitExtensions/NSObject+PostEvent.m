#import "NSObject+PostEvent.h"
#import "PNThreadManager.h"

@implementation NSObject(EventExecutioner)

-(void)performSelectorOnConnectionThread:(SEL)select withObject:(id)arg
{
	NSThread* connectionThread = [PNThreadManager getConnectionThread];
	[self performSelector:select onThread:connectionThread withObject:arg waitUntilDone:NO];
}

-(void)performSelectorOnConnectionThread:(SEL)aSelector withObjects:(NSArray*)arguments
{
	NSThread* connectionThread = [PNThreadManager getConnectionThread];
	[self performSelector:@selector(invoke:) onThread:connectionThread withObject:[NSArray arrayWithObjects:NSStringFromSelector(aSelector),arguments,nil] waitUntilDone:NO];
}

-(void)performSelectorOnConnectionThreadSync:(SEL)select withObject:(id)arg
{
	NSThread* connectionThread = [PNThreadManager getConnectionThread];
	[self performSelector:select onThread:connectionThread withObject:arg waitUntilDone:YES];
}

- (void)performSelectorOnMainThread:(SEL)aSelector withObjects:(NSArray*)arguments
{
	[self performSelectorOnMainThread:@selector(invoke:) withObject:[NSArray arrayWithObjects:NSStringFromSelector(aSelector),arguments,nil] waitUntilDone:NO];
}

- (void)invoke:(NSArray*)arguments
{
	SEL selector;
    NSMethodSignature *signature;
    NSInvocation *invocation;
	NSArray* args;
	
	selector = NSSelectorFromString([arguments objectAtIndex:0]);
	args = [arguments objectAtIndex:1];
	
	
    
    signature = [[self class] 
				 instanceMethodSignatureForSelector:selector];
    
    if (signature) {
        invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:self];
        
		int cnt = 2;
		for(id arg in args) {
			[invocation setArgument:&arg atIndex:cnt++];
		}
        
        [invocation invoke];
    }
}

- (void)performSelector:(SEL)aSelector withObjects:(NSArray*)arguments
{
	[self performSelector:@selector(invoke:) withObject:[NSArray arrayWithObjects:NSStringFromSelector(aSelector),arguments,nil]];
}

- (void)performSelector:(SEL)aSelector withObjects:(NSArray*)arguments afterDelay:(double)aDelayTime
{
	[self performSelector:@selector(invoke:) withObject:[NSArray arrayWithObjects:NSStringFromSelector(aSelector),arguments,nil] afterDelay:aDelayTime];
}

- (void)invoke:(NSString*)aSelector withObjects:(NSArray*)arguments
{
	NSObject* target = self;
	SEL selector = NSSelectorFromString(aSelector);
	if([target respondsToSelector:selector]) {
		NSMethodSignature* signature	= [target methodSignatureForSelector:selector];
		NSInvocation *invocation		= [NSInvocation invocationWithMethodSignature:signature];
		[invocation setSelector:selector];
		[invocation setTarget:target];
		int cnt = 2;
		for(id arg in arguments)
			[invocation setArgument:arg atIndex:cnt++];
		[invocation invoke];
	}
}


@end
