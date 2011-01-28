//
//  PNHighScoreViewController.h
//  PankiaNet
//
//  Created by Kazuto Maruoka on 1/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTableViewController.h"
#import "PankiaNetworkLibrary.h"

@interface PNHighScoreViewController : PNTableViewController {
	NSMutableArray*		highScores;
	int                 addScoreCount;
	int					scope;
	PNRank*				myRank;
	int					leaderboardId;
	int					rankMode;
	NSString*			leaderboardType;
	int					rowCounter;
	BOOL				showLoadMoreHighScores;
	NSDate*				targetDate;
	NSString*           viewTitle;
	BOOL				loadingFlag;
}

@property (retain) NSMutableArray*		highScores;
@property (assign) int                  addScoreCount;
@property (assign) int					leaderboardId;
@property (assign) int					scope;
@property (retain) PNRank*				myRank;
@property (retain) NSString*			leaderboardType;
@property (retain) NSDate*				targetDate;
@property (retain) NSString*            viewTitle;

/**
 *	@brief 現在保持しているスコアデータをリセットする。
 */
- (void)resetScore;

/**
 *	@brief queryをサーバへ送ります。
 */
- (void)sendQueries;

/**
 *	@brief viewのタイトルをセットします。
 */
- (void)setViewTitle:(NSString *)title;

@end
