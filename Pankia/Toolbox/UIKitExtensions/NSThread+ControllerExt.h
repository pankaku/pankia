
@interface NSThread(Controller)

// Thread type is queue(FIFO) with priority.
+(void)changeThreadModeToQueueWithPriority:(int)priority;

// Thread type is round robin. No priority.
+(void)changeThreadModeToRoundRobin;

+(NSString*)threadInformation;

@end
