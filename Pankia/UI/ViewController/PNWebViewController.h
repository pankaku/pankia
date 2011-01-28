//
//  PNWebViewController.h
//  PankakuNet
//
//  Created by 横江 宗太 on 11/01/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PNWebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView* currentWebView;
	BOOL firstRequest;
}
- (void)loadURL:(NSString*)url;
@end
