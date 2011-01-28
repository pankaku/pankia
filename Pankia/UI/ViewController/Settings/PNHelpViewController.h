//
//  PNHelpViewController.h
//  PankakuNet
//
//  Created by shunter on 10/11/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PNViewController.h"
#import "PNGlobal.h"

@interface PNHelpViewController : PNViewController <UIWebViewDelegate>{
	
	IBOutlet UIWebView* helpView;

}

@property(nonatomic, retain) UIWebView* helpView;

@end
