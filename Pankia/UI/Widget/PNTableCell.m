#import "PNTableCell.h"
#import "UILabel+textWidth.h"
#import "PNCountryCodeUtil.h"
#import "PNGlobal.h"
#import "PNHighScoreCell.h"
#import "PNMyLocalRoomActionCell.h"
#import "PNJoinedLocalRoomCell.h"
#import "PNRoomsReloadActionCell.h"
#import "PNInviteFriendActionCell.h"
#import "PNJoinedRoomCell.h"
#import "PNJoinedRoomEventCell.h"
#import "PNImageUtil.h"
#import "UILabel+textWidth.h"
#import "PNGlobal.h"
#import "PNDefaultButton.h"
#import "PNLocalizedString.h"
#import "PNDashboard.h"
#import "PNSpecialTableCell.h"

#import "PNUser.h"
#import "PNLogger.h"

#define kPNAccessoryImage		@"PNCellArrowImage.png"
#define kPNCellBackgroundImage	@"PNTableCellBackgroundImage.png"

@implementation PNTableCell

@synthesize useDarkBackground;
@synthesize headIcon;
@synthesize userNameLabel;
@synthesize achievementNameLabel;
@synthesize achievementInfoLabel;
@synthesize achievementIconImage;
@synthesize iconUrl;
@synthesize achievementPointLabel;
@synthesize appNameLabel;
@synthesize gradeIconImage;
@synthesize gradeNameLabel;
@synthesize gradePointLabel;
@synthesize flagImage;
@synthesize rankingLabel;
@synthesize roomNameLabel;
@synthesize friendsIconImage;
@synthesize numberOfPeoplesLabel;
@synthesize signalImage;
@synthesize nameLabel;
@synthesize leaderboardNameLabel;
@synthesize roomMemberNumLabel;
@synthesize treeIcon;
@synthesize followingImage;
@synthesize gradeEnabled;
@synthesize nextButton;
@synthesize previousButton;
@synthesize isHighlightedBackground;
@synthesize hiddenButton;
@synthesize joinMatchUpBtn;
@synthesize inviteFriendsBtn;
@synthesize highlightable;
@synthesize myCoin_;

// cell size
const float CELL_WIDTH						= 480.0f;
const float CELL_HEIGHT						=  50.0f;
// offset
const float OFFSET							=   5.0f;
// common
const float HEAD_ICON_X						=  16.0f;
const float HEAD_ICON_Y						=   7.0f;
const float FLAG_ICON_X						=  38.0f;
const float FLAG_ICON_Y						=  31.0f;
const float TREE_ICON_X						=   4.0f;
const float TREE_ICON_Y						=  15.0f;
const float PREVIOUS_ICON_X					=  15.0f;
const float PREVIOUS_ICON_Y					=  10.0f;
const float NEXT_ICON_X						=  390.0f - 15.0f;
const float NEXT_ICON_Y						=  10.0f;
const float FOLLOWING_ICON_Y				=   2.0f;
const float ROOM_LEFT_BUTTON_X              =   3.0f;
const float ROOM_RIGHT_BUTTON_X             = 108.0f;
const float ROOM_BUTTON_Y                   =   2.0f;
// icon size
const float HEAD_ICON_WIDTH					=  36.0f;
const float HEAD_ICON_HEIGHT				=  36.0f;
const float FLAG_ICON_WIDTH					=  17.0f;
const float FLAG_ICON_HEIGHT				=  12.0f;
const float TREE_ICON_WIDTH					=  10.0f;
const float TREE_ICON_HEIGHT				=  10.0f;
const float ACHIEVEMENT_ICON_WIDTH			=  25.0f;
const float ACHIEVEMENT_ICON_HEIGHT			=  25.0f;
const float GRADE_ICON_WIDTH				=  25.0f;
const float GRADE_ICON_HEIGHT				=  25.0f;
const float FOLLOWING_ICON_WIDTH			=  80.0f;
const float FOLLOWING_ICON_HEIGHT			=  20.0f;
const float NAME_WIDTH2						= 280.0f;
const float ACHIEVEMENT_DESCRIPTION_WIDTH2	= 360.0f;
const float ACHIEVEMENT_DESCRIPTION_HEIGHT2	=  40.0f;
const float ACHIEVEMENT_TEXT_HEIGHT2		=  40.0f;
const float TEXT_HEIGHT						=  20.0f;
const float PREVIOUS_ICON_WIDTH				=  20.0f;
const float PREVIOUS_ICON_HEIGHT			=  20.0f;
const float NEXT_ICON_WIDTH					=  20.0f;
const float NEXT_ICON_HEIGHT				=  20.0f;
// max
const float GRADE_NAME_MAX_WIDTH2			=  60.0f;
const float GRADE_POINT_MAX_WIDTH2			=  60.0f;
const float GRADE_POINT_MAX_WIDTH1			= 100.0f;
const float GRADE_NAME_MAX_WIDTH1			= 100.0f;
const float USERNAME_MAX_WIDTH				= 100.0f;
//two steps
const float NAME_X2							=  72.0f;
const float NAME_Y2							=   5.0f;
const float ACHIEVEMENT_ICON_X2				=  65.0f;
const float ACHIEVEMENT_ICON_Y2				=  20.0f;
const float ACHIEVEMENT_POINT_X2			=  97.0f;
const float ACHIEVEMENT_POINT_Y2			=  22.0f;
const float ACHIEVEMENT_POINT_MAX_WIDTH2	=  80.0f;
const float ACHIEVEMENT_DESCRIPTION_X2		=  16.0f;
const float ACHIEVEMENT_DESCRIPTION_Y2		=   5.0f;
const float GRADE_ICON_Y2					=  20.0f;
const float GRADE_NAME_Y2					=  22.0f;
const float GRADE_POINT_Y2					=  22.0f;
//one step
const float TEXT_Y_CENTER					=  15.0f;
const float ICON_Y_CENTER					=  12.5f;
const float RANKING_X						=  72.0f;


NSString* commaString(NSString* str) {
	static NSString* comma = @",";
	
	BOOL isMinus = NO;
	if ([str intValue] == INT_MAX) {
		isMinus = (BOOL)([str longLongValue] < 0);
	} else {
		isMinus = (BOOL)([str intValue] < 0);
	}
	
	NSUInteger length = [str length];
	if (length > 3) {
		NSString* commaStr = [[[NSString alloc] initWithString:@""] autorelease];
		NSUInteger loc = 0;
		NSUInteger len = length%3;
		while (loc < length) {
			if (loc) {
				commaStr = [commaStr stringByAppendingFormat:@"%@%@",
							comma, [str substringWithRange:NSMakeRange(loc, len)]];
			} else {
				commaStr = [commaStr stringByAppendingString:
							[str substringWithRange:NSMakeRange(loc, len)]];
			}
			loc += len;
			len  = 3;
		}
		if (isMinus) commaStr = [NSString stringWithFormat:@"-%@", commaStr];
		return commaStr;
	} else {
		if (isMinus) str = [NSString stringWithFormat:@"-%@", str];
		return str;
	}
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNCellBackgroundImage]] autorelease];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.textColor = [UIColor whiteColor];
		self.textLabel.font = [UIFont fontWithName:kPNDefaultFontName size:13.0f];
		self.detailTextLabel.font = [UIFont fontWithName:kPNDefaultFontName size:11.0f];
		highlightable = YES;
	}
	return self;
}

- (void)awakeFromNib {	
	if (!self.backgroundView) {
		UIImage* normalImage = [UIImage imageNamed:kPNCellBackgroundImage];		
        self.backgroundView = [[[UIImageView alloc] initWithImage:normalImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
		
	}
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)oneStepLayout {
	float RANKING_WIDTH = [rankingLabel textWidth];
	[rankingLabel setFrame:CGRectMake(RANKING_X, TEXT_Y_CENTER, RANKING_WIDTH, TEXT_HEIGHT)];
	[leaderboardNameLabel  setFrame:CGRectMake(NAME_X2, NAME_Y2, NAME_WIDTH2, TEXT_HEIGHT*2)];
	[leaderboardNameLabel  setNumberOfLines:2];

	float USERNAME_X = RANKING_X + RANKING_WIDTH + OFFSET;
	float USERNAME_WIDTH = [userNameLabel textWidth];
	if (USERNAME_WIDTH > USERNAME_MAX_WIDTH) {
		USERNAME_WIDTH = USERNAME_MAX_WIDTH;
	}
	[userNameLabel setFrame:CGRectMake(USERNAME_X, TEXT_Y_CENTER, USERNAME_WIDTH, TEXT_HEIGHT)];
	float GRADE_ICON_X = USERNAME_X + USERNAME_WIDTH + OFFSET;
	
	[gradeIconImage setFrame:CGRectMake(GRADE_ICON_X, ICON_Y_CENTER, GRADE_ICON_WIDTH, GRADE_ICON_HEIGHT)];
	
	float GRADE_NAME_X = GRADE_ICON_X + GRADE_ICON_WIDTH;
	float GRADE_NAME_WIDTH = [gradeNameLabel textWidth];
	if (GRADE_NAME_WIDTH > GRADE_NAME_MAX_WIDTH1) {
		GRADE_NAME_WIDTH = GRADE_NAME_MAX_WIDTH1;
	}
	[gradeNameLabel setFrame:CGRectMake(GRADE_NAME_X, TEXT_Y_CENTER, GRADE_NAME_WIDTH, TEXT_HEIGHT)];
	float GRADE_POINT_WIDTH = [gradePointLabel textWidth];
	if (GRADE_POINT_WIDTH > GRADE_POINT_MAX_WIDTH1) {
		GRADE_POINT_WIDTH = GRADE_POINT_MAX_WIDTH1;
	}
	float GRADE_POINT_X = CELL_WIDTH - OFFSET - GRADE_POINT_WIDTH;
	[gradePointLabel setFrame:CGRectMake(GRADE_POINT_X, TEXT_Y_CENTER, GRADE_POINT_WIDTH, TEXT_HEIGHT)];
}

- (void)twoStepsLayout {
	float ACHIEVEMENT_POINT_WIDTH = [achievementPointLabel textWidth];
	if (ACHIEVEMENT_POINT_WIDTH > ACHIEVEMENT_POINT_MAX_WIDTH2) {
		ACHIEVEMENT_POINT_WIDTH = ACHIEVEMENT_POINT_MAX_WIDTH2;
	}
	float GRADE_ICON_X           = ACHIEVEMENT_POINT_X2 + ACHIEVEMENT_POINT_WIDTH + OFFSET;
	if (!achievementPointLabel.text) {
		GRADE_ICON_X           = ACHIEVEMENT_ICON_X2;
	} else {
		GRADE_ICON_X           = ACHIEVEMENT_POINT_X2 + ACHIEVEMENT_POINT_WIDTH + OFFSET;
	}
	float GRADE_NAME_X           = GRADE_ICON_X + GRADE_ICON_WIDTH;
	float GRADE_NAME_WIDTH       = [gradeNameLabel textWidth];
	if (GRADE_NAME_WIDTH > GRADE_NAME_MAX_WIDTH2) {
		GRADE_NAME_WIDTH = GRADE_NAME_MAX_WIDTH2;
	}
	float GRADE_POINT_X  = GRADE_NAME_X + GRADE_NAME_WIDTH;
	float GRADE_POINT_WIDTH = [gradePointLabel textWidth];
	if (GRADE_POINT_WIDTH > GRADE_POINT_MAX_WIDTH2) {
		GRADE_POINT_WIDTH = GRADE_POINT_MAX_WIDTH2;
	}
	
	[achievementNameLabel  setFrame:CGRectMake(NAME_X2, NAME_Y2, NAME_WIDTH2, ACHIEVEMENT_TEXT_HEIGHT2)];
	[achievementNameLabel  setNumberOfLines:2];	
	[userNameLabel         setFrame:CGRectMake(NAME_X2, NAME_Y2, NAME_WIDTH2, TEXT_HEIGHT)];	
	[appNameLabel          setFrame:CGRectMake(NAME_X2, NAME_Y2, NAME_WIDTH2, TEXT_HEIGHT)];
	
	[achievementInfoLabel  setFrame:CGRectMake(ACHIEVEMENT_DESCRIPTION_X2, ACHIEVEMENT_DESCRIPTION_Y2, ACHIEVEMENT_DESCRIPTION_WIDTH2, ACHIEVEMENT_DESCRIPTION_HEIGHT2)];
	[achievementInfoLabel  setNumberOfLines:3];
	
	if (achievementPointLabel.text) {
		[achievementIconImage  setFrame:CGRectMake(ACHIEVEMENT_ICON_X2, ACHIEVEMENT_ICON_Y2, ACHIEVEMENT_ICON_WIDTH, ACHIEVEMENT_ICON_HEIGHT)];
		[achievementPointLabel setFrame:CGRectMake(ACHIEVEMENT_POINT_X2, ACHIEVEMENT_POINT_Y2, ACHIEVEMENT_POINT_WIDTH, TEXT_HEIGHT)];
	}
	[gradeIconImage      setFrame:CGRectMake(GRADE_ICON_X, GRADE_ICON_Y2, GRADE_ICON_WIDTH, GRADE_ICON_HEIGHT)];
	if (!gradeNameLabel.text) {
		[gradePointLabel setFrame:CGRectMake(GRADE_NAME_X, GRADE_POINT_Y2, GRADE_POINT_WIDTH, TEXT_HEIGHT)];
	} else {
		[gradeNameLabel  setFrame:CGRectMake(GRADE_NAME_X, GRADE_NAME_Y2, GRADE_NAME_WIDTH, TEXT_HEIGHT)];
		[gradePointLabel setFrame:CGRectMake(GRADE_POINT_X, GRADE_POINT_Y2, GRADE_POINT_WIDTH, TEXT_HEIGHT)];
	}
}

- (void)setMyCoin {
	PNUser* myUser = [PNUser currentUser];
	myCoin_.text = [NSString stringWithFormat:@"%d", myUser.coins];
}

- (void)setAllFonts {

	NSString* fontName = kPNDefaultFontName;
	[userNameLabel         setFont:[UIFont fontWithName:fontName size:14]];
	[achievementNameLabel  setFont:[UIFont fontWithName:fontName size:12]];
	[appNameLabel          setFont:[UIFont fontWithName:fontName size:12]];
	[rankingLabel          setFont:[UIFont fontWithName:fontName size:12]];
	[roomNameLabel         setFont:[UIFont fontWithName:fontName size:12]];
	[nameLabel             setFont:[UIFont fontWithName:fontName size:12]];
	[leaderboardNameLabel  setFont:[UIFont fontWithName:fontName size:12]];
	[achievementInfoLabel  setFont:[UIFont fontWithName:fontName size:10]];
	[achievementPointLabel setFont:[UIFont fontWithName:fontName size:10]];
	[gradeNameLabel        setFont:[UIFont fontWithName:fontName size:10]];
	[gradePointLabel       setFont:[UIFont fontWithName:fontName size:10]];
	[numberOfPeoplesLabel  setFont:[UIFont fontWithName:fontName size:10]];
	[roomMemberNumLabel    setFont:[UIFont fontWithName:fontName size:10]];
}

- (void)setLayout:(NSInteger)cellType {

	[self setAllFonts];
	[headIcon       setFrame:CGRectMake(HEAD_ICON_X, HEAD_ICON_Y, HEAD_ICON_WIDTH, HEAD_ICON_HEIGHT)];
	[flagImage      setFrame:CGRectMake(FLAG_ICON_X, FLAG_ICON_Y, FLAG_ICON_WIDTH, FLAG_ICON_HEIGHT)];
	[treeIcon       setFrame:CGRectMake(TREE_ICON_X, TREE_ICON_Y, TREE_ICON_WIDTH, TREE_ICON_HEIGHT)];
	[previousButton setFrame:CGRectMake(PREVIOUS_ICON_X, PREVIOUS_ICON_Y, PREVIOUS_ICON_WIDTH, PREVIOUS_ICON_HEIGHT)];
	if ([[PNDashboard sharedObject] isLandscapeMode]) {
		[nextButton     setFrame:CGRectMake(NEXT_ICON_X, NEXT_ICON_Y, NEXT_ICON_WIDTH, NEXT_ICON_HEIGHT)];
	}
	else {
		[nextButton     setFrame:CGRectMake(250, NEXT_ICON_Y, NEXT_ICON_WIDTH, NEXT_ICON_HEIGHT)];
	}
	
	if (cellType != LEADERBOARD_CELL && gradeNameLabel.text && ![gradeNameLabel.text isEqualToString:@""]) {
		gradePointLabel.text = [NSString stringWithFormat:@"(%@)", gradePointLabel.text];
	}
	
	if (cellType == ACHIEVEMENT_CELL) {
		[self twoStepsLayout];
		float ACHIEVEMENT_POINT_WIDTH = [achievementPointLabel textWidth];
		if (ACHIEVEMENT_POINT_WIDTH > ACHIEVEMENT_POINT_MAX_WIDTH2) {
			ACHIEVEMENT_POINT_WIDTH = ACHIEVEMENT_POINT_MAX_WIDTH2;
		}
		float ACHIEVEMENT_POINT_X = CELL_WIDTH - ACHIEVEMENT_POINT_WIDTH - OFFSET - 40;
		if (![[PNDashboard sharedObject] isLandscapeMode]) {
			ACHIEVEMENT_POINT_X = 290 - ACHIEVEMENT_POINT_WIDTH - OFFSET - 30;
		}
		float ACHIEVEMENT_POINT_Y = TEXT_Y_CENTER;
		
		if ([[PNDashboard sharedObject] isLandscapeMode]) {
			[achievementPointLabel setFrame:CGRectMake(
			   ACHIEVEMENT_POINT_X, ACHIEVEMENT_POINT_Y, ACHIEVEMENT_POINT_WIDTH, TEXT_HEIGHT)];
		}
		else {
			[achievementPointLabel setFrame:CGRectMake(
			   ACHIEVEMENT_POINT_X, 0.0f, ACHIEVEMENT_POINT_WIDTH, TEXT_HEIGHT)];
		}
		
		float labelWidthForThreeDigits = [achievementPointLabel textWidthOfString:@"000"];
		float currentLabelWidth = [achievementPointLabel textWidth];
		float labelWidth = (currentLabelWidth > labelWidthForThreeDigits) ? currentLabelWidth : labelWidthForThreeDigits;
		
		float ACHIEVEMENT_ICON_X = CELL_WIDTH - labelWidth - ACHIEVEMENT_ICON_WIDTH - OFFSET;
		
		if (![[PNDashboard sharedObject] isLandscapeMode]) {
			ACHIEVEMENT_ICON_X = 290 - labelWidth - ACHIEVEMENT_ICON_WIDTH - OFFSET;
			[achievementIconImage setFrame:CGRectMake(
													  achievementPointLabel.frame.origin.x - achievementIconImage.frame.size.width - 3.0f, achievementPointLabel.frame.origin.y, ACHIEVEMENT_ICON_WIDTH, ACHIEVEMENT_ICON_HEIGHT)];
		}
		else {
			[achievementIconImage setFrame:CGRectMake(
													  ACHIEVEMENT_ICON_X - 40, ICON_Y_CENTER, ACHIEVEMENT_ICON_WIDTH, ACHIEVEMENT_ICON_HEIGHT)];
		}
		
		[gradeIconImage setFrame:CGRectMake(ACHIEVEMENT_ICON_X2, GRADE_ICON_Y2, GRADE_ICON_WIDTH, GRADE_ICON_HEIGHT)];
		float GRADE_NAME_X = ACHIEVEMENT_ICON_X2 + GRADE_ICON_WIDTH + OFFSET;
		float GRADE_NAME_WIDTH = [gradeNameLabel textWidth];
		if (GRADE_NAME_WIDTH > GRADE_NAME_MAX_WIDTH2) {
			GRADE_NAME_WIDTH = GRADE_NAME_MAX_WIDTH2;
		}
		
		[gradeNameLabel setFrame:CGRectMake(GRADE_NAME_X, GRADE_NAME_Y2, GRADE_NAME_WIDTH, TEXT_HEIGHT)];
		float GRADE_POINT_X = GRADE_NAME_X + GRADE_NAME_WIDTH;
		float GRADE_POINT_WIDTH = [gradePointLabel textWidth];
		if (GRADE_POINT_WIDTH > GRADE_POINT_MAX_WIDTH2) {
			GRADE_POINT_WIDTH = GRADE_POINT_MAX_WIDTH2;
		}
		[gradePointLabel setFrame:CGRectMake(GRADE_POINT_X, GRADE_POINT_Y2, GRADE_POINT_WIDTH, TEXT_HEIGHT)];
	}
	else if (cellType == FRIENDS_CELL || cellType == MATCH_CELL) {
		[self twoStepsLayout];
		float FOLLOWING_ICON_X;
		if ([userNameLabel textWidth] > NAME_WIDTH2) {
			FOLLOWING_ICON_X = NAME_X2 + NAME_WIDTH2 + OFFSET;
		} else {
			FOLLOWING_ICON_X = NAME_X2 + [userNameLabel textWidth] + OFFSET;
		}
		[followingImage setFrame:CGRectMake(FOLLOWING_ICON_X, FOLLOWING_ICON_Y, FOLLOWING_ICON_WIDTH, FOLLOWING_ICON_HEIGHT)];
		
		// Not Landscape but PortraitMode!
		if (cellType == MATCH_CELL && ![[PNDashboard sharedObject] isLandscapeMode]) {
			CGRect frame = headIcon.frame;
			frame.origin.x -= 10;
			headIcon.frame = frame;
			
			frame = userNameLabel.frame;
			frame.origin.x -= 10;
			userNameLabel.frame = frame;
		
			if (achievementPointLabel.text) {
				frame = achievementIconImage.frame;
				frame.origin.x -= 10;
				achievementIconImage.frame = frame;
			
				frame = achievementPointLabel.frame;
				frame.origin.x -= 15;
				achievementPointLabel.frame = frame;
			}
			frame = gradeIconImage.frame;
			frame.origin.x -= 18;
			gradeIconImage.frame = frame;
		
			if (gradeNameLabel.text) {
				frame = gradeNameLabel.frame;
				frame.origin.x -= 18;
				gradeNameLabel.frame = frame;
			}			
			frame = gradePointLabel.frame;
			frame.origin.x -= 20;
			gradePointLabel.frame = frame;
		}
		
	}
	else if (cellType == LEADERBOARD_CELL) {
		if ([[PNDashboard sharedObject] isLandscapeMode]) {
			[self oneStepLayout];
		}
	}
	else if (cellType == MY_ROOM_VIEW) {
		[joinMatchUpBtn setHidden:YES];
		CGRect frame = inviteFriendsBtn.frame;
		frame.origin.x = ROOM_LEFT_BUTTON_X;
		frame.origin.y = ROOM_BUTTON_Y;
		inviteFriendsBtn.frame = frame;
	}
	else if (cellType == JOINED_ROOM_VIEW) {
		[joinMatchUpBtn setHidden:NO];
	}

	if (!achievementPointLabel.text || [achievementPointLabel.text isEqualToString:@""]) {
		[achievementIconImage  setHidden:YES];
		[achievementPointLabel setHidden:YES];
	}
	else {
		[achievementIconImage  setHidden:NO];
		[achievementPointLabel setHidden:NO];
	}
	
	if (gradeEnabled) {
		[gradeIconImage  setHidden:NO];
		[gradeNameLabel  setHidden:NO];
		[gradePointLabel setHidden:NO];
	}
	else {
		[gradeIconImage  setHidden:YES];
		[gradeNameLabel  setHidden:YES];
		[gradePointLabel setHidden:YES];
	}
	if (cellType == LEADERBOARD_CELL) {
		[gradePointLabel setHidden:NO];//Leaderboadでは常にポイントを表示する
	}
	
	if (gradeNameLabel.text) {
		if (cellType != LEADERBOARD_CELL) {
			[gradeIconImage setHidden:NO];
		}
		[gradeNameLabel  setHidden:NO];
	}
	else {
		if (cellType == LEADERBOARD_CELL) {
			[gradeIconImage setHidden:YES];
		}
		[gradeNameLabel  setHidden:YES];
	}
}

- (BOOL)setHeadIconImage:(NSString*)url {

	[headIcon loadImageWithUrl:url];
	if (headIcon) {
		return YES;
	}
	return NO;
}

- (void)setUseDarkBackground:(BOOL)flag {

    if (self.backgroundView) {
		UIImage* normalImage = [UIImage imageNamed:kPNCellBackgroundImage];		
        self.backgroundView = [[[UIImageView alloc] initWithImage:normalImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
	}
}

- (void)setHighlightedBackground:(BOOL)flag {
	
	if (flag) {
		if (self.backgroundView) {
			UIImage* normalImage = [UIImage imageNamed:kPNCellBackgroundImage];
			self.backgroundView = [[[UIImageView alloc] initWithImage:normalImage] autorelease];
			self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			self.backgroundView.frame = self.bounds;
			self.isHighlightedBackground = YES;

		}
	}
	else if(flag == NO && self.isHighlightedBackground == YES){
		if (self.backgroundView) {
			UIImage* normalImage = [UIImage imageNamed:kPNCellBackgroundImage];
			self.backgroundView = [[[UIImageView alloc] initWithImage:normalImage] autorelease];
			self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			self.backgroundView.frame = self.bounds;
			self.isHighlightedBackground = NO;
		}
	}	
}

- (void)dealloc {

	self.backgroundView			= nil;
	self.selectedBackgroundView = nil;
	
	self.headIcon				= nil;
	self.userNameLabel			= nil;
	self.achievementIconImage	= nil;
	self.achievementInfoLabel	= nil;
	self.achievementPointLabel	= nil;
	self.appNameLabel			= nil;
	self.gradeIconImage			= nil;
	self.gradeNameLabel			= nil;
	self.gradePointLabel		= nil;
	self.flagImage				= nil;
	self.rankingLabel			= nil;
	self.roomNameLabel			= nil;
	self.friendsIconImage		= nil;
	self.numberOfPeoplesLabel	= nil;
	self.signalImage			= nil;
	self.nameLabel				= nil;
	self.leaderboardNameLabel   = nil;
	self.iconUrl				= nil;
	self.followingImage			= nil;
	self.treeIcon				= nil;
	self.roomMemberNumLabel		= nil;
	self.nextButton				= nil;
	self.previousButton			= nil;
	self.myCoin_				= nil;

    [super dealloc];
}

- (void)setName:(NSString*)newName {

	if (newName) {
		[nameLabel setText:newName];
	}
	else {
		[nameLabel setText:nil];
	}
}

- (void)setAchievementPoint:(NSString*)achievementPoint {

	if (achievementPoint) {
		[achievementPointLabel setText:achievementPoint];
	}
	else {
		[achievementPointLabel setText:nil];
	}
}

- (void)setIcon:(UIImage *)iconImage {

	if (iconImage) {
		[headIcon setImage:iconImage];
	}
	else {
		[headIcon setImage:nil];
	}
}

- (void)loadIconWithUrl:(NSString*)url {

	if (url) {
		[headIcon loadImageWithUrl:url];
	}
	else {
		[headIcon setImage:nil];
	}
}

- (void)setUserName:(NSString*)userName {

	if (userName) {
		[userNameLabel setText:userName];
	}
	else {
		[userNameLabel setText:nil];
	}
}

- (void)setLeaderboardName:(NSString*)leaderboardName {

	if (leaderboardName) {
		[leaderboardNameLabel setText:leaderboardName];
	}
	else {
		[leaderboardNameLabel setText:nil];
	}
}

- (void)setAchievementName:(NSString*)achievementName {

	if (achievementName) {
		[achievementNameLabel setText:achievementName];
	}
	else {
		[achievementNameLabel setText:nil];
	}
}

- (void)setAchievementInfo:(NSString*)achievementInfo {

	if (achievementInfo && ![achievementInfo isKindOfClass:[NSNull class]]) {
		[achievementInfoLabel setText:achievementInfo];
	}
	else {
		[achievementInfoLabel setText:nil];
	}
}

- (void)setAppName:(NSString*)appName {

	if (appName) {
		[appNameLabel setText:appName];
	}
	else {
		[appNameLabel setText:nil];
	}
}

- (void)setGradeName:(NSString*)gradeName {

	if (gradeName) {
		[gradeNameLabel setText:gradeName];
	} 
	else {
		[gradeNameLabel setText:nil];
	}
}

- (void)setGradePoint:(NSString*)gradePoint {

	if (gradePoint) {
		[gradePointLabel setText:commaString(gradePoint)];
	}
	else {
		[gradePointLabel setText:@"0"];
	}
}

- (void)setRankingScore:(NSString*)score {
	[gradePointLabel setText:score];
}

- (void)setRanking:(NSString*)ranking {
	[rankingLabel setText:ranking];
}

- (void)setRoomName:(NSString*)roomName {
	if (roomName) {
		[roomNameLabel setText:roomName];
	}
	else {
		[roomNameLabel setText:nil];
	}
}

- (void)setNumberOfPeople:(NSString*)numberOfPeople {

	if (numberOfPeople) {
		[numberOfPeoplesLabel setText:numberOfPeople];
	} else {
		[numberOfPeoplesLabel setText:nil];
	}
}

- (void)setIconUrl:(NSString*)url {
	iconUrl = url;
}

- (void)setFlagImageForCountryCode:(NSString*)countryCode {
	[flagImage setHidden:NO];
	[flagImage setImage:[PNCountryCodeUtil getFlagImageForAlpha2Code:countryCode]];
}

- (void)setHiddenFlagImage:(BOOL)boo {
	[flagImage setHidden:boo];
}

- (void)setRoomMemberNum:(int)memberNum maxMemberNum:(int)maxMemberNum {
	[roomMemberNumLabel setText:[NSString stringWithFormat:@"%d/%d",memberNum,maxMemberNum]];
}

- (void)setGradeEnabled:(BOOL)boo {
	gradeEnabled = boo;
}

- (void)setSignalImageWithSpeedLevel:(PNConnectionLevel)speedLevel {
	[signalImage setHidden:NO];
	if (speedLevel == kPNConnectionLevelHigh) {
		[signalImage setImage:[UIImage imageNamed:@"PNSignalImage5.png"]];
	} else if (speedLevel == kPNConnectionLevelNormal) {
		[signalImage setImage:[UIImage imageNamed:@"PNSignalImage4.png"]];
	} else if (speedLevel == kPNConnectionLevelLow) {
		[signalImage setImage:[UIImage imageNamed:@"PNSignalImage3.png"]];
	} else if (speedLevel == kPNConnectionLevelNotRecommend) {
		[signalImage setImage:[UIImage imageNamed:@"PNSignalImage2.png"]];
	} else if (speedLevel == kPNConnectionLevelUnknown) {
		[signalImage setImage:[UIImage imageNamed:@"PNSignalImage1.png"]];
	} else { // speedLevel is kPNConnectionLevelUnmeasurement
		[signalImage setImage:[UIImage imageNamed:@"PNSignalImage0.png"]];
	}
}

- (void)hideSignalImage {
	[signalImage setHidden:YES];
}


- (void)setHighlighted:(BOOL)aBool animated:(BOOL)animated {
	if ([self isKindOfClass:[PNHighScoreCell class]]
		|| [self isKindOfClass:[PNMyLocalRoomActionCell class]]
		|| [self isKindOfClass:[PNJoinedLocalRoomCell class]]
		|| [self isKindOfClass:[PNRoomsReloadActionCell class]]
		|| [self isKindOfClass:[PNInviteFriendActionCell class]]
		/*|| [self isKindOfClass:[PNJoinedRoomCell class]]*/) {
		return;
	}

	if (highlightable == NO) return;

	if ([self isKindOfClass:[PNSpecialTableCell class]]) {
		self.selected = aBool;
		self.backgroundView = aBool ? 
			[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNSpecialCellBackgroundImageOn.png"]] autorelease]:
			[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PNSpecialCellBackgroundImage.png"]] autorelease];
		self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundView.frame = self.bounds;
		return;
	}

	if (aBool) {
		[self setHighlightedBackground:YES];
		self.selected = YES;
	} else {
		[self setHighlightedBackground:NO];
		self.selected = NO;
	}
	
}


- (void)loadRoundRectImageFromURL:(NSString*)url defaultImageName:(NSString*)defaultImageName
					  paddingLeft:(float)left top:(float)top right:(float)right bottom:(float)bottom
							width:(float)width height:(float)height delegate:(id)delegate {
	UIImage* originalIconImage;
	if (url != nil && [url length] > 0 && ![url hasSuffix:@"missing.png"]){
		//アイコンがある場合
		if ([PNImageUtil hasCacheForUrl:url]){
			originalIconImage = [UIImage imageWithContentsOfFile:[PNImageUtil cacheFilePathForURL:url]];
		}
		else {
			// キャッシュがなければダウンロードしにいき、数秒後に更新します
			[PNImageUtil createCacheForUrl:url];
			[delegate performSelector:@selector(reloadData) withObject:nil afterDelay:1.0f];
			
			//TODO: show default coin
			originalIconImage = [UIImage imageNamed:defaultImageName];
		}
	}
	else {
		// アイコンがない場合
		//TODO: show default coin
		originalIconImage = [UIImage imageNamed:defaultImageName];
	}
	self.imageView.image = [PNImageUtil imageWithPadding:originalIconImage 
													left:left top:top right:right bottom:bottom 
												   width:width height:height];
}

- (void)setBackgroundImage:(NSString*)imageName {

	UIImage* image = [UIImage imageNamed:imageName];
	self.backgroundView = [[[UIImageView alloc] initWithImage:image] autorelease];
	self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:image] autorelease];
}

#pragma mark AccessoryRelated

- (void)setAccessoryView:(UIView *)view {

	UIView* viewWithContainer = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width + 10.0f, view.frame.size.height)] autorelease];
	[viewWithContainer addSubview:view];
	[super setAccessoryView:viewWithContainer];
}

- (UILabel*)labelForAccessoryWithText:(NSString*)text {

	UILabel* label = [[[UILabel alloc] init] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor cyanColor];
	label.font = [UIFont fontWithName:kPNDefaultFontName size:11.0f];
	label.text = text;
	
	float labelWidth = [label textWidth];
	float labelHeight = [label textHeight];
	[label setFrame:CGRectMake(0.0f, 0.0f, labelWidth, labelHeight)];
	
	return label;
}

- (void)setArrowAccessoryWithText:(NSString*)text {

	UIView* accessoryContainer = [[[UIView alloc] init] autorelease];
	UIImageView* arrowImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNAccessoryImage]] autorelease];
	UILabel* label = [self labelForAccessoryWithText:text];
	
	float PADDING = 10.0f;

	float labelWidth = [label textWidth];
	float labelHeight = [label textHeight];
	float imageWidth = arrowImage.frame.size.width;
	float totalWidth = labelWidth + PADDING + imageWidth;
	float totalHeight = arrowImage.frame.size.height;
	
	[accessoryContainer addSubview:label];	
	[accessoryContainer addSubview:arrowImage];
	
	[accessoryContainer setFrame:CGRectMake(0.0f, 0.0f, totalWidth, totalHeight)];
	[label setFrame:CGRectMake(0.0f, (totalHeight- labelHeight) * 0.5f, labelWidth, labelHeight)];
	[arrowImage setFrame:CGRectMake(labelWidth + PADDING, 0.0f, imageWidth, totalHeight)];
	
	self.accessoryView = accessoryContainer;
}

- (void)setAccessoryText:(NSString*)text {
	self.accessoryView = [self labelForAccessoryWithText:text];
}

- (void)setAccessoryText:(NSString *)text withIconNamed:(NSString*)imageName {
	UIView* accessoryContainer = [[[UIView alloc] init] autorelease];
	UILabel* label = [self labelForAccessoryWithText:text];
	UIImage* image = [UIImage imageNamed:imageName];
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:image] autorelease];

	float PADDING = 10.0f;
	
	float labelWidth = [label textWidth];
	float labelHeight = [label textHeight];
	float imageWidth = imageView.frame.size.width;
	float totalWidth = labelWidth + PADDING + imageWidth;
	float totalHeight = imageView.frame.size.height;
	
	[accessoryContainer addSubview:label];	
	[accessoryContainer addSubview:imageView];
	
	[accessoryContainer setFrame:CGRectMake(0.0f, 0.0f, totalWidth, totalHeight)];
	[label setFrame:CGRectMake(imageWidth + PADDING, (totalHeight- labelHeight) * 0.5f, labelWidth, labelHeight)];
	[imageView setFrame:CGRectMake(0.0f, 0.0f, imageWidth, totalHeight)];
	
	self.accessoryView = accessoryContainer;
}

- (PNDefaultButton*)defaultButtonWithDelegate:(id)aDelegate selector:(SEL)aSelector 
								 title:(NSString*)title enabled:(BOOL)enabled tag:(NSInteger)tag {

	PNDefaultButton* button = [PNDefaultButton buttonWithTitle:title];
	button.frame = CGRectMake(0.0f, 0.0f, [[PNDashboard sharedObject] isLandscapeMode] ? 100.0f : 80.0f, 30.0f);
	[button addTarget:aDelegate action:aSelector forControlEvents:UIControlEventTouchUpInside];
	button.enabled = enabled;
	button.tag = tag;
	return button;
}

- (void)setAccessoryButtonWithDelegate:(id)aDelegate selector:(SEL)aSelector 
								 title:(NSString*)title enabled:(BOOL)enabled tag:(NSInteger)tag {
	self.accessoryView = [self defaultButtonWithDelegate:aDelegate selector:aSelector title:title enabled:enabled tag:tag];
}

- (UIButton*)disclosureButtonWithDelegate:(id)aDelegate selector:(SEL)aSelector tag:(NSInteger)tag {
	UIButton* disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage* image = [UIImage imageNamed:@"PNDetailButton.png"];
	[disclosureButton setImage:image forState:UIControlStateNormal];
	disclosureButton.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	disclosureButton.tag = tag;
	[disclosureButton addTarget:aDelegate action:aSelector forControlEvents:UIControlEventTouchUpInside];
	return disclosureButton;
}

- (void)setDetailDisclosureButtonWithDelegate:(id)aDelegate selector:(SEL)aSelector tag:(NSInteger)tag {
	self.accessoryView = [self disclosureButtonWithDelegate:aDelegate selector:aSelector tag:tag];
}

- (void)setDetailDisclosureButtonWithDelegate:(id)disclosureButtonDelegate 
					 disclosureButtonSelector:(SEL)disclosureButtonSelector
						additionalButtonTitle:(NSString*)additionalButtonTitle
					 additionalButtonDelegate:(id)additionalButtonDelegate
					 additionalButtonSelector:(SEL)additionalButtonSelector
					  additionalButtonEnabled:(BOOL)enabled
										  tag:(NSInteger)aTag {
	UIView* accessoryContainer = [[[UIView alloc] init] autorelease];
	UIButton* detailButton = [self disclosureButtonWithDelegate:disclosureButtonDelegate selector:disclosureButtonSelector tag:0];
	
	PNDefaultButton* additionalButton = [self defaultButtonWithDelegate:additionalButtonDelegate selector:additionalButtonSelector 
																  title:additionalButtonTitle enabled:enabled tag:aTag];	
	float PADDING = 10.0f;
	
	float detailButtonWidth = detailButton.frame.size.width;
	float detailButtonHeight = detailButton.frame.size.height;
	float additionalButtonWidth = additionalButton.frame.size.width;
	float totalWidth = detailButtonWidth + PADDING + additionalButtonWidth;
	float totalHeight = detailButtonHeight;
	
	[accessoryContainer addSubview:additionalButton];	
	[accessoryContainer addSubview:detailButton];
	
	[accessoryContainer setFrame:CGRectMake(0.0f, 0.0f, totalWidth, totalHeight)];
	[additionalButton setFrame:CGRectMake(0.0f, 0.0f, additionalButtonWidth, totalHeight)];
	[detailButton setFrame:CGRectMake(additionalButtonWidth + PADDING, 0.0f, detailButtonWidth, totalHeight)];
	
	detailButton.tag = aTag;
	additionalButton.tag = aTag;
	
	self.accessoryView = accessoryContainer;
}

- (void)setFontSize:(float)fontSize {
	self.textLabel.font = [UIFont fontWithName:kPNDefaultFontName size:fontSize];
}

- (void)setLeftPadding:(float)leftPadding {
	if (leftPadding == 0){
		return;
	}
	self.imageView.image = [PNImageUtil imageWithPadding:[UIImage imageNamed:@"PNBlank.png"] left:0.0f top:0.0f right:0.0f bottom:0.0f width:leftPadding height:10.0f];
}

- (void)setRightPadding:(float)rightPadding {
	if (rightPadding == 0) {
		return;
	}
	self.accessoryView = [[[UIImageView alloc] initWithImage:[PNImageUtil imageWithPadding:[UIImage imageNamed:@"PNBlank.png"] left:0.0f top:0.0f right:0.0f bottom:0.0f width:rightPadding height:10.0f]] autorelease];
}

- (void)setBottomedText:(NSString*)text color:(UIColor*)color fontSize:(float)fontSize {
	if (bottomedLabel == nil) {
		bottomedLabel = [[[UILabel alloc] init] autorelease];
		[self.contentView addSubview:bottomedLabel];
	}

	UIFont* font = [UIFont fontWithName:kPNDefaultFontName size:fontSize];
	bottomedLabel.text = text;
	bottomedLabel.font = font;
	bottomedLabel.backgroundColor = [UIColor clearColor];
	bottomedLabel.textColor = color;
	CGSize textSize = [text sizeWithFont:font];
	bottomedLabel.frame = CGRectMake(20.0f, 25.0 - textSize.height, textSize.width, textSize.height);
}

@end
