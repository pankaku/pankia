@interface NSObject(EventExecutioner)

- (void)performSelectorOnConnectionThread:(SEL)aSelector withObject:(id)anArgument;
- (void)performSelectorOnConnectionThread:(SEL)aSelector withObjects:(NSArray*)arguments;
- (void)performSelectorOnMainThread:(SEL)aSelector withObjects:(NSArray*)arguments;
- (void)performSelectorOnConnectionThreadSync:(SEL)aSelector withObject:(id)anArgument;
- (void)performSelector:(SEL)aSelector withObjects:(NSArray*)arguments;
- (void)performSelector:(SEL)aSelector withObjects:(NSArray*)arguments afterDelay:(double)aDelayTime;

- (void)invoke:(NSString*)aSelector withObjects:(NSArray*)arguments;

@end
