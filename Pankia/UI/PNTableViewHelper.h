//
//  PNTableViewHelper.h
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNAchievement;
@class PNGame;
@class PNLeaderboard;
@class PNRank;

@interface PNTableViewHelper : NSObject {

}
+ (UITableViewCell *)headerCellForTableView:(UITableView *)tableView title:(NSString*)title;
+ (UITableViewCell *)descriptionCellForTableView:(UITableView*)tableView description:(NSString*)description;
+ (UITableViewCell *)screenshotsCellForTableView:(UITableView*)tableView urls:(NSArray*)urls;
+ (UITableViewCell *)screenshotsCellForTableView:(UITableView*)tableView urls:(NSArray*)urls thumbnailUrls:(NSArray*)thumbnailUrls;
+ (UITableViewCell *)achievementCellForTableView:(UITableView*)tableView achievement:(PNAchievement*)achievement delegate:(id)delegate;
+ (UITableViewCell *)gameCellForTableView:(UITableView*)tableView game:(PNGame*)game delegate:(id)delegate onDetailTouched:(SEL)detailSelector tag:(NSInteger)tag;
+ (UITableViewCell *)leaderboardCellForTableView:(UITableView*)tableView leaderboard:(PNLeaderboard*)leaderboard delegate:(id)delegate;
+ (UITableViewCell *)rankCellForTableView:(UITableView*)tableView rank:(PNRank*)rank delegate:(id)delegate;

+ (CGFloat)heightSizeForString:(NSString*)string;
+ (CGFloat)heightSizeForScreenshotsCell:(NSArray*)urls;
@end
