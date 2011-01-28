//
//  PNErrorViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PNErrorViewController : UIViewController {
	IBOutlet UILabel* errorMessageLabel;
}

@property (retain) IBOutlet UILabel* errorMessageLabel;

- (void)setErrorMessage:(NSString*)errorMessage;

@end
