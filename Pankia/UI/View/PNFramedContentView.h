//
//  PNFramedContentView.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNNavigationController.h"

@interface PNFramedContentView : UIView {
	PNNavigationController*   navigationController;
	UITableView*			  myView;
	UIEdgeInsets			  myInsets;
	BOOL					  isTable;
}

@property (retain) UITableView* myView;
@property (retain) PNNavigationController*	navigationController;

- (id)initWithView:(UITableView*)view;
- (void)reloadData;
- (void)setInsets:(UIEdgeInsets)_insets;
- (void)isTable:(BOOL)boo;
- (void)setPNNavigationController:(PNNavigationController*)_navigationController;
- (void)showIndicator;
- (void)hideIndicator;
@end
