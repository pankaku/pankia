#import "PNHTTPRequestHelper.h"
#import "PNNetworkError.h"

@protocol PNInvitationRequestHelperDelegate;

/**
 @brief Invitation作成のHTTP通信の補助をするクラスです。
 
 invitationの表示、ポスト、削除のHTTP通信の補助をします。
 */
@interface PNInvitationRequestHelper : PNHTTPRequestHelper {
}

+(void)show:(NSString*)session
	 filter:(NSString*)filter
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key;

+(void)post:(NSString*)session
	   room:(NSString*)room
	   user:(NSString*)user
	  group:(NSString*)group
	   text:(NSString*)text
   delegate:(id)delegate
   selector:(SEL)selector
 requestKey:(NSString*)key;

+(void)deleteInvitation:(NSString*)session
			 invitation:(NSString*)invitation
			   delegate:(id)delegate
			   selector:(SEL)selector
			 requestKey:(NSString*)key;

+(void)rooms:(NSString*)session
	delegate:(id)delegate
	selector:(SEL)selector
  requestKey:(NSString*)key;


@end
