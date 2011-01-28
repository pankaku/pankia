#import "PNHTTPRequestHelper.h"

@interface PNMatchRequestHelper : PNHTTPRequestHelper {
}

+ (void)start:(NSString*)aSession
		 room:(NSString*)aRoom
	 delegate:(id)aDelegate
	 selector:(SEL)aSelector
   requestKey:(NSString*)aKey;

+ (void)finish:(NSString*)aSession
		  room:(NSString*)aRoom
		 users:(NSArray*)aUsers
   gradePoints:(NSArray*)aGradePoints
	matchScores:(NSArray*)matchScores
	  delegate:(id)aDelegate
	  selector:(SEL)aSelector
	requestKey:(NSString*)aKey;

+ (void)find:(NSString*)aSession
	   users:(NSArray*)aUsers
	delegate:(id)aDelegate
	selector:(SEL)aSelector
  requestKey:(NSString*)aKey;


@end
