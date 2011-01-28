//
//  PNLinkFacebookViewController.h
//  PankakuNet
//
//  Created by pankaku on 10/08/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"
#import "FBConnect.h"

@interface PNLinkFacebookViewController : PNViewController <FBSessionDelegate, FBDialogDelegate> {
	FBSession* fbSession;
}
@end
