//
//  PNInformationViewController.h
//  PankakuNet
//
//  Created by nakashima on 10/02/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PNInformationViewController : UIViewController {

	IBOutlet UILabel* informationMessageLabel;
}

@property (retain) IBOutlet UILabel* informationMessageLabel;

- (void)setInformationMessage:(NSString*)informationMessage;

@end
