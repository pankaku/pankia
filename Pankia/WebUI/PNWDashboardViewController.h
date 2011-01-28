//
//  PNWDashboardViewController.h
//  PankakuNet
//
//  Created by あんのたん on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNSessionManager.h"

@interface PNWDashboardViewController : UIViewController <UIWebViewDelegate> {
}
@property (retain, nonatomic) IBOutlet UIWebView* webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* indicatorView;
@property (retain, nonatomic) IBOutlet UILabel* nameLabel;
@property (retain, nonatomic) NSMutableArray* URLCaches;
@property (retain, nonatomic) NSURL* lastestURL;

- (IBAction)home:sender;
- (IBAction)close:sender;
- (void)showIndicator:sender;
- (void)hideIndicator:sender;
- (void)loadURLWithString:(NSString *)URLString;
@end
