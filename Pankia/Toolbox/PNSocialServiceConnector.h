//
//  PNSocialServiceConnector.h
//  PankakuNet
//
//  Created by sota2 on 10/11/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface PNSocialServiceConnector : NSObject {
	id delegate;
	NSMutableData* receivedData;
}
@property (nonatomic, retain) id delegate;
- (void)getIconURLFromTwitterWithId:(NSString*)userId;
@end
