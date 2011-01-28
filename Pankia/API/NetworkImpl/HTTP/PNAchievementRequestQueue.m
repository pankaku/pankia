#import "PNAchievementRequestQueue.h"
#import "PNAchievementRequestHelper.h"
#import "PNAchievementManager.h"
#import "PNLogger+Package.h"

PNAchievementRequestQueue* _sharedInstance;

@implementation PNAchievementRequestQueue

- (void)addUnlockRequest:(NSArray*)achievements
{
	@synchronized (self) {
		[unlockRequests addObjectsFromArray:achievements];
		if (!isRequestRunning) {
			//リクエストが実行中でなければすぐに実行します
			PNCLog(PNLOG_CAT_ACHIEVEMENT, @"request not running.");
			
			if ([unlockRequests count] > 0) {
				PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Unlock %d achievements...", [unlockRequests count]);
				[PNAchievementRequestHelper unlockAchievements:unlockRequests 
													  delegate:self
													  selector:@selector(unlockAchievementResponse:) 
													requestKey:[NSString stringWithFormat:@"PNAchievementUnlock:%d",[achievements componentsJoinedByString:@","]]];
				[unlockRequests removeAllObjects];			
				isRequestRunning = YES;
			} else {
				PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Queue is empty.");
			}
		} else {
			//まちます
			PNCLog(PNLOG_CAT_ACHIEVEMENT, @"request is running. wait.");
			PNCLog(PNLOG_CAT_ACHIEVEMENT, @"queue: %@", unlockRequests);
		}
	}
}

- (void)clearAllRequests
{
	@synchronized(self)
	{
		PNCLog(PNLOG_CAT_ACHIEVEMENT, @"Clear all queued requests");
		[unlockRequests removeAllObjects];
		isRequestRunning = NO;
	}
}

- (void)unlockAchievementResponse:(PNHTTPResponse*)response
{
	[[PNAchievementManager sharedObject] performSelector:@selector(unlockAchievementResponse:) withObject:response];
	isRequestRunning = NO;
	//キューにたまっているものがあれば次のリクエストをおくります
	[self addUnlockRequest:nil];
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		unlockRequests = [[NSMutableArray alloc] initWithCapacity:1];
		isRequestRunning = NO;
	}
	return self;
}

- (void) dealloc
{
	[unlockRequests release];
	[super dealloc];
}

+ (PNAchievementRequestQueue *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}

@end
