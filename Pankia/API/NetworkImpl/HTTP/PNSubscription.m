#import "PNSubscription.h"
#import "PNNetworkError.h"
#import "PNLogger+Package.h"
#import "PNAPIHTTPDefinition.h"

@implementation PNSubscription


//subscription.show (session*) - セッションで購読中のトピックの一覧を取得する
//subscription.add (session*, topic*) - 購読するトピックをセッションに追加する
//subscription.remove (session*, topic*) - 購読したくないトピックをセッションから削除する
//subscription.set (session*, topic*) - セッションで購読中のトピックを削除して指定のトピックで置き換える

//when 'friendship'
//next true unless (user = User.find_by_username(path[2])) and @user == user
//when 'membership'
//next true unless (room = Room.find_by_public_id(path[2])) and @user.member_of?(room)
//when 'room'
//next true unless (room = Room.find_by_public_id(path[2])) and @user.member_of?(room)
//when 'user'
//next true unless (user = User.find_by_username(path[2])) and @user == user
//else
//next true

+(NSString*)createTopic:(NSString*)command
			 param:(NSString*)param
{
	return [NSString stringWithFormat:@"%@%@",command,param];
}


- (id) init {
	if (self = [super init])
	{
		
	}
	return self;
}


+(void) add:(NSString*)session
	  topic:(NSString*)topic
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key
{
	[[self class] requestWithCommand:kPNHTTPRequestCommandSubscriptionAdd
						 requestType:@"GET"
						   isMutable:NO
						  parameters:[NSDictionary dictionaryWithObjectsAndKeys:
									  session,		@"session",
									  topic,		@"topic",
									  nil]
							delegate:delegate
							selector:selector
						 callBackKey:key];
	
}

- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNLog(@"%@ %d",error.message,error.errorType);
}

- (void) dealloc
{
	[super dealloc];
}
@end
