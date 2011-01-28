//
//  PNLicenseViewController.h
//  PankakuNet
//
//  Created by nakashima on 10/06/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNViewController.h"


@interface PNLicenseViewController : PNViewController <UITextViewDelegate> {
	
	UITextView* licenseTextView;
}

@property (retain) IBOutlet UITextView* licenseTextView;

@end
