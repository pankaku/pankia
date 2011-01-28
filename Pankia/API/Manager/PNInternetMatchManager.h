//
//  PNInternetMatchManager.h
//  no_dashboard
//
//  Created by sota2 on 10/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PNRoom;
@interface PNInternetMatchManager : NSObject {

}
+ (PNInternetMatchManager*)sharedObject;

- (void)createAnInternetRoomWithMaxMemberNum:(int)memberNum isPublic:(BOOL)isPublic roomName:(NSString*)name
						 		  gradeRange:(NSString*)gradeRange lobbyId:(int)lobbyId delegate:(id)aDelegate
								 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)findRooms:(int)maxCount inLobby:(int)lobbyId delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
		 onFailed:(SEL)onFailedSelector;
- (void)leaveInternetRoom:(PNRoom*)room delegate:(id)aDelegate onSucceeded:(SEL)onSucceededSelector
				 onFailed:(SEL)onFailedSelector;
@end
