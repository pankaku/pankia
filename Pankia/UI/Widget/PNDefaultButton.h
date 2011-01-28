//
//  PNDefaultButton.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNButton.h"

@interface PNDefaultButton : PNButton {

}
- (void)defaultButtonColorRed;
- (void)defaultButtonColorGreen;
- (void)defaultButtonColorBlue;
- (void)refreshText;

+ (PNDefaultButton*)buttonWithTitle:(NSString*)title;
@end
