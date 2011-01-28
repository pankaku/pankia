#import "PNModel.h"

@class PNLeaderboardModel;

typedef enum {
	kPNUndefined,
	kPNSortByLatest,
	kPNSortByMinimum,
	kPNSortByMaximum
} PNLeaderboardSortType;

typedef enum {
	kPNLeaderboardFormatInteger,
	kPNLeaderboardFormatFloat1,
	kPNLeaderboardFormatFloat2,
	kPNLeaderboardFormatFloat3,
	kPNLeaderboardFormatElaspedTimeToMinute,
	kPNLeaderboardFormatElaspedTimeToSecond,
	kPNLeaderboardFormatElaspedTimeToTheHunsredthOfASecond,
	kPNLeaderboardFormatMoneyWholeNumbers,
	kPNLeaderboardFormatMoneyTwoDecimals
} PNLeaderboardFormat;
	
@interface PNLeaderboard : PNModel {
	int							leaderboardId;
	NSString*					name;
	NSString*					type;
	PNLeaderboardSortType		sortBy;
	int64_t						scoreBase;
	int							format;
}
@property (readonly) int		id;
@property (assign) int			leaderboardId;
@property (retain) NSString*	name;
@property (retain) NSString*	type;
@property (assign) PNLeaderboardSortType	sortBy;
@property (assign) int64_t		scoreBase;
@property (assign) int			format;
- (id)initWithLocalDictionary:(NSDictionary*)dictionary;
- (id) initWithLeaderboardModel:(PNLeaderboardModel*)model;
- (NSComparisonResult)compareId:(PNLeaderboard *)leaderboard;
- (void) setSortByWithString:(NSString*)stringValue;
@end
