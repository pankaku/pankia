//
//  PNItemViewHelper.h
//  PankakuNet
//
//  Created by sota on 10/09/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNItem;
@interface PNItemViewHelper : NSObject {

}
+ (UITableViewCell *)screenshotsCellForTableView:(UITableView*)tableView item:(PNItem*)item;
+ (UITableViewCell *)descriptionCellForTableView:(UITableView*)tableView item:(PNItem*)item;
@end
