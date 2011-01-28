//
//  PNLobbyViewCell.m
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNLobbyViewCell.h"
#import "PNImageUtil.h"
#import "PNLobby.h"
#import "PNLocalizableLabel.h"

#define kPNCellBackgroundImage	@"PNTableCellBackgroundImage.png"
#define kPNDefaultLobbyIcon		@"PNDefaultLobbyIcon.png"
#define kPNAccessoryImage		@"PNCellArrowImage.png"

@implementation PNLobbyViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withLobby:(PNLobby *)lobby {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		UIImage *originalIconImage;
		if ([lobby hasIcon]) {
			if ([PNImageUtil hasCacheForUrl:lobby.iconUrl]) {
				originalIconImage = [UIImage imageWithContentsOfFile:[PNImageUtil cacheFilePathForURL:lobby.iconUrl]];
			} else {
				// キャッシュがなければダウンロードしにいき、数秒後に更新します
				//[PNImageUtil createCacheForUrl:lobby.iconUrl];  // http://pankia.com/images/s114/missing.png
				//[self performSelector:@selector(reloadData) withObject:nil afterDelay:1.0f];
				originalIconImage = [UIImage imageNamed:kPNDefaultLobbyIcon];
			}
		}
		else {
			originalIconImage = [UIImage imageNamed:kPNDefaultLobbyIcon];
		}

		self.imageView.image = [PNImageUtil imageWithPadding:originalIconImage
														left:20.0f top:0.0f right:0.0f bottom:0.0f width:48 height:48];
		self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNCellBackgroundImage]] autorelease];
		self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNCellBackgroundImage]] autorelease];
		
		CGRect nameLabbelFrame = CGRectMake(90, 15, 200, 30);
		PNLocalizableLabel *nameLabbel = [[PNLocalizableLabel alloc] initWithFrame:nameLabbelFrame
																			 style:PNLargeLabelStyle];
		nameLabbel.text = lobby.name;
		[self addSubview:nameLabbel];
		[nameLabbel release];
		
		CGRect memberImageViewFrame = CGRectMake(90, 40, 18, 18);
		UIImageView *memberImageView = [[UIImageView alloc] initWithFrame:memberImageViewFrame];
		memberImageView.image = [UIImage imageNamed:@"PNFriendsSmallIcon.png"];
		[self addSubview:memberImageView];
		[memberImageView release];
		
		CGRect membershipsCountLabelFrame = CGRectMake(130, 40, 200, 18);
		PNLocalizableLabel *membershipsCountLabel = [[PNLocalizableLabel alloc] initWithFrame:membershipsCountLabelFrame
																						style:PNStatusLabelStyle];
		membershipsCountLabel.text = [NSString stringWithFormat:@"%d", lobby.membershipsCount];
		[self addSubview:membershipsCountLabel];
		[membershipsCountLabel release];
		
		UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNAccessoryImage]];
		self.accessoryView = accessoryImageView;
		[accessoryImageView release];		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
