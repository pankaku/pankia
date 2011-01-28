//
//  PNTableViewHelper.m
//  PankakuNet
//
//  Created by sota on 10/09/17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNTableViewHelper.h"
#import "PNGlobal.h"
#import "PNTableCell.h"
#import "PNLocalizedString.h"
#import "PNThumbnailsCell.h"
#import "PNDashboard.h"
#import "PNAchievement.h"
#import "PNAchievement+Package.h"
#import "PNGame.h"
#import "PNGameCell.h"

#import "PNTableViewCell.h"
#import "PNRankCell.h"

#import "PNFormatUtil.h"


#define kPNDefaultMyUserIcon    @"PNDefaultSelfIcon.png"
#define kPNLeaderboardsIcon     @"PNDefaultLeaderboardIcon.png"
#define kPNDefaultOtherUserIcon @"PNDefaultUserIcon.png" 


@implementation PNTableViewHelper

+ (CGFloat)heightSizeForString:(NSString*)string {
	NSString *cellText = string;
    UIFont *cellFont = [UIFont fontWithName:kPNDefaultFontName size:13.0];
    CGSize constraintSize = CGSizeMake([[PNDashboard sharedObject] isLandscapeMode] ? 320.0f : 260.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
    return labelSize.height + 20;
}

+ (CGFloat)heightSizeForScreenshotsCell:(NSArray*)urls {
	float eachHeight = [[PNDashboard sharedObject] isLandscapeMode] ? 145.0f : 190.0f;
	return (int)ceil((float)[urls count] * 0.5f) * eachHeight;
}

#pragma mark -

+ (UITableViewCell *)headerCellForTableView:(UITableView *)tableView title:(NSString*)title {
	static NSString *CellIdentifier = @"HeaderCell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNInformationHeaderBackgroundImage.png"]] autorelease];

	[cell setBottomedText:getTextFromTable(title) color:[UIColor cyanColor] fontSize:13.0f];
	[cell setLeftPadding:5.0f];
	cell.highlightable = NO;	
    return cell;
}

+ (UITableViewCell *)descriptionCellForTableView:(UITableView*)tableView description:(NSString*)description {
	static NSString *CellIdentifier = @"DescriptionCell";
    
    PNTableCell *cell = (PNTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNInformationBackgroundImage.png"]] autorelease];
	cell.textLabel.text = description;
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
	cell.highlightable = NO;
	[cell setLeftPadding:10.0f];
	[cell setRightPadding:1.0f];
    return cell;
}

+ (UITableViewCell *)screenshotsCellForTableView:(UITableView*)tableView urls:(NSArray*)urls {
	static NSString *CellIdentifier = @"ScreenshotsCell";
    
    PNThumbnailsCell *cell = (PNThumbnailsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNThumbnailsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNInformationBackgroundImage.png"]] autorelease];
	cell.textLabel.text = @"";
	
	[cell hideAllThumbnails];
	for (NSString* url in urls) {
		[cell addThumbnailFromURL:url];
	}
    return cell;
}

+ (UITableViewCell *)screenshotsCellForTableView:(UITableView*)tableView urls:(NSArray*)urls thumbnailUrls:(NSArray*)thumbnailUrls {
	PNLogMethodName;
	static NSString *CellIdentifier = @"ScreenshotsCell";
    
    PNThumbnailsCell *cell = (PNThumbnailsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNThumbnailsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNInformationBackgroundImage.png"]] autorelease];
	cell.textLabel.text = @"";
	
	[cell hideAllThumbnails];
	
	for (int i=0; i< [urls count]; i++) {
		[cell addThumbnailFromURL:[urls objectAtIndex:i]];// originalUrl:[urls objectAtIndex:i] ];
	}
    return cell;
}

+ (UITableViewCell *)achievementCellForTableView:(UITableView*)tableView achievement:(PNAchievement*)achievement delegate:(id)delegate {
	PNLogMethodName;
	NSString *CellIdentifier = [NSString stringWithFormat:@"PNAchievementCell%@", ([[PNDashboard sharedObject] isLandscapeMode] ? @"Landscape" : @"")];
	PNTableCell *cell = (PNTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[PNTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	cell.textLabel.text = achievement.title;
	[cell setAccessoryText:[NSString stringWithFormat:@"%d", achievement.value] withIconNamed:@"PNAchievementIconSmall.png"];
	
	if (achievement.isUnlocked) {
		[cell loadRoundRectImageFromURL:achievement.iconUrl defaultImageName:@"PNUnlockedAchievementIcon.png" 
							paddingLeft:10.0f top:0.0f right:0.0f bottom:0.0f width:36.0f height:36.0f delegate:self];
	} else {
		[cell loadRoundRectImageFromURL:nil defaultImageName:@"PNLockedAchievementIcon.png" 
							paddingLeft:10.0f top:0.0f right:0.0f bottom:0.0f width:36.0f height:36.0f delegate:self];
	}	
	return cell;
}

+ (UITableViewCell *)gameCellForTableView:(UITableView*)tableView game:(PNGame*)game delegate:(id)delegate onDetailTouched:(SEL)detailSelector tag:(NSInteger)tag {
	static NSString *CellIdentifier = @"PNGameCell";
    
    PNGameCell *cell = (PNGameCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PNGameCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.game = game;
	[cell loadRoundRectImageFromURL:game.iconUrl defaultImageName:@"PNDefaultGameIcon.png" paddingLeft:10.0f top:0.0f right:0.0f bottom:0.0f width:36.0 height:36.0f delegate:delegate];
//	[cell setDetailDisclosureButtonWithDelegate:delegate selector:detailSelector tag:tag];
	
	
	return cell;
}

+ (UITableViewCell *)leaderboardCellForTableView:(UITableView*)tableView leaderboard:(PNLeaderboard*)leaderboard delegate:(id)delegate {
    static NSString *CellIdentifier = @"PNLeaderboardCell";
    PNTableViewCell* cell = (PNTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [PNTableViewCell cellWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = leaderboard.name;
    cell.fontSize = 14.0f;
    [cell loadRoundRectImageNamed:kPNLeaderboardsIcon paddingLeft:10.0f top:0.0f right:0.0 bottom:0.0f width:36.0f height:36.0f delegate:delegate];
    [cell setArrowAccessoryWithText:@" "];
    return cell;
}

+ (UITableViewCell *)rankCellForTableView:(UITableView*)tableView rank:(PNRank*)rank delegate:(id)delegate {
    static NSString *CellIdentifier = @"PNRankCell";
    PNRankCell* cell = (PNRankCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (PNRankCell*)[PNRankCell cellWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }    
    cell.textLabel.text = @"   ";
    
    cell.rank = rank;
    
    NSString* defaultIconImage = [rank.user.username isEqualToString:[PNUser currentUser].username] ? kPNDefaultMyUserIcon : kPNDefaultOtherUserIcon;
    
    [cell loadRoundRectImageFromURL:rank.user.iconURL defaultImageName:defaultIconImage paddingLeft:10.0f top:0.0f right:0.0f bottom:0.0f width:36.0f height:36.0f delegate:delegate];
    return cell;
}
@end
