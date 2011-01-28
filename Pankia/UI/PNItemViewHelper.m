//
//  PNItemViewHelper.m
//  PankakuNet
//
//  Created by sota on 10/09/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemViewHelper.h"
#import "PNGlobal.h"
#import "PNLocalizedString.h"

#import "PNTableCell.h"
#import "PNThumbnailsCell.h"

#import "PNItem.h"

#import "PNTableViewHelper.h"

@implementation PNItemViewHelper


+ (UITableViewCell *)screenshotsCellForTableView:(UITableView*)tableView item:(PNItem*)item
{
    return [PNTableViewHelper screenshotsCellForTableView:tableView urls:item.screenshotUrls];
}

+ (UITableViewCell *)descriptionCellForTableView:(UITableView*)tableView item:(PNItem*)item
{
	return [PNTableViewHelper descriptionCellForTableView:tableView description:item.description];
}
@end
