//
//  PNGameCenterOptionViewController.h
//  PankakuNet
//
//  Created by Yujin TANG on 11/12/10.
//  Copyright 2010 Waseda University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNViewController.h"
#import "PNLocalizableLabel.h"

@interface PNGameCenterOptionViewController : PNViewController {
	
}

@property (retain) IBOutlet UISwitch*			gameCenterOptionSwitch;
@property (retain) IBOutlet PNLocalizableLabel* currentAccountLabel;
@property (retain) IBOutlet PNLocalizableLabel* currentAccount;

-(IBAction)gameCenterOptionSwitchStateChanged;

@end

