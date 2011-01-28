#import <UIKit/UIKit.h>
#import "PNImageView.h"
#import "PNTreeIcon.h"
#import "PNPreviousButton.h"
#import "PNNextButton.h"
#import "PNDefaultButton.h"
#import "PankiaNetworkLibrary.h"

enum LayoutType {
	ACHIEVEMENT_CELL,
	FRIENDS_CELL,
	LEADERBOARD_CELL,
	MATCH_CELL,
	MY_ROOM_VIEW,
	JOINED_ROOM_VIEW
};

/**
 * @brief TableCellの拡張クラスです。
 * layoutの指定等ができます。
 */
@interface PNTableCell : UITableViewCell {	

	IBOutlet PNDefaultButton* joinMatchUpBtn;
	IBOutlet PNDefaultButton* inviteFriendsBtn;
	IBOutlet PNImageView*	headIcon;
	IBOutlet UILabel*		userNameLabel;
	IBOutlet UILabel*		achievementNameLabel;
	IBOutlet UILabel*		achievementInfoLabel;
	IBOutlet UIImageView*	achievementIconImage;
	IBOutlet UILabel*		achievementPointLabel;
	IBOutlet UILabel*		appNameLabel;
	IBOutlet UIImageView*	gradeIconImage;
	IBOutlet UILabel*		gradeNameLabel;
	IBOutlet UILabel*		gradePointLabel;
	IBOutlet UIImageView*	flagImage;
	IBOutlet UILabel*		rankingLabel;
	IBOutlet UILabel*		roomNameLabel;
	IBOutlet UIImageView*	friendsIconImage;
	IBOutlet UILabel*		numberOfPeoplesLabel;
	IBOutlet UIImageView*	signalImage;
	IBOutlet UIImageView*	followingImage;
	IBOutlet UILabel*		nameLabel;
	IBOutlet UILabel*		leaderboardNameLabel;
	IBOutlet UILabel*		myCoin_;
	IBOutlet UILabel*		roomMemberNumLabel;

	PNTreeIcon*           treeIcon;
	UIButton*             hiddenButton;
	PNNextButton*		  nextButton;
	PNPreviousButton*	  previousButton;
	NSString*             iconUrl;
	
	BOOL					useDarkBackground;
	BOOL                  gradeEnabled;
	BOOL				  isHighlightedBackground;
	BOOL					highlightable;

	UILabel*				bottomedLabel;
}

@property BOOL									useDarkBackground;
@property BOOL									highlightable;
@property (retain) IBOutlet PNImageView*		headIcon;
@property (retain) IBOutlet UILabel*			userNameLabel;
@property (retain) IBOutlet UILabel*			achievementNameLabel;
@property (retain) IBOutlet UILabel*			achievementInfoLabel;
@property (retain) IBOutlet UIImageView*		achievementIconImage;
@property (retain) IBOutlet UILabel*			achievementPointLabel;
@property (retain) IBOutlet UILabel*			appNameLabel;
@property (retain) IBOutlet UIImageView*		gradeIconImage;
@property (retain) IBOutlet UILabel*			gradeNameLabel;
@property (retain) IBOutlet UILabel*			gradePointLabel;
@property (retain) IBOutlet UIImageView*		flagImage;
@property (retain) IBOutlet UILabel*			rankingLabel;
@property (retain) IBOutlet UILabel*			roomNameLabel;
@property (retain) IBOutlet UIImageView*		friendsIconImage;
@property (retain) IBOutlet UILabel*			numberOfPeoplesLabel;
@property (retain) IBOutlet UIImageView*		signalImage;
@property (retain) IBOutlet UILabel*			nameLabel;
@property (retain) IBOutlet UILabel*			leaderboardNameLabel;
@property (retain)          NSString*			iconUrl;
@property (retain) IBOutlet UIImageView*		followingImage;
@property (retain) IBOutlet PNTreeIcon*			treeIcon;
@property (retain) IBOutlet UILabel*			roomMemberNumLabel;
@property BOOL									gradeEnabled;
@property (retain) IBOutlet UIButton*           hiddenButton;
@property (retain) IBOutlet PNNextButton*		nextButton;
@property (retain) IBOutlet PNPreviousButton*	previousButton;
@property BOOL									isHighlightedBackground;
@property (retain) IBOutlet UIButton*	joinMatchUpBtn;
@property (retain) IBOutlet UIButton*	inviteFriendsBtn;
@property (retain) IBOutlet UILabel*	myCoin_;

- (void)loadRoundRectImageFromURL:(NSString*)url defaultImageName:(NSString*)defaultImageName
					  paddingLeft:(float)left top:(float)top right:(float)right bottom:(float)bottom
							width:(float)width height:(float)height delegate:(id)delegate;
- (void)setArrowAccessoryWithText:(NSString*)text;
- (void)setDetailDisclosureButtonWithDelegate:(id)aDelegate selector:(SEL)aSelector tag:(NSInteger)tag;
- (void)setDetailDisclosureButtonWithDelegate:(id)disclosureButtonDelegate 
					 disclosureButtonSelector:(SEL)disclosureButtonSelector
						additionalButtonTitle:(NSString*)additionalButtonTitle
					 additionalButtonDelegate:(id)additionalButtonDelegate
					 additionalButtonSelector:(SEL)additionalButtonSelector
					  additionalButtonEnabled:(BOOL)enabled
										  tag:(NSInteger)aTag;
- (void)setAccessoryButtonWithDelegate:(id)aDelegate selector:(SEL)aSelector 
								 title:(NSString*)title enabled:(BOOL)enabled tag:(NSInteger)tag;
- (void)setAccessoryText:(NSString*)text;
- (void)setAccessoryText:(NSString *)text withIconNamed:(NSString*)imageName;
- (void)setBackgroundImage:(NSString*)imageName;
- (void)setFontSize:(float)fontSize;
- (void)setLeftPadding:(float)leftPadding;
- (void)setRightPadding:(float)rightPadding;
- (void)setBottomedText:(NSString*)text color:(UIColor*)color fontSize:(float)fontSize;


- (void)setMyCoin;								// 自分自身が所持しているコイン数をセットします。
- (void)setHighlightedBackground:(BOOL)flag;	// ハイライトした背景をセットします。
- (void)setName:(NSString*)newName;				// nameLabelにテキストをセットします。
- (void)setAchievementPoint:(NSString*)ap;		// achievementPointLabelにテキストをセットします。
- (void)setIcon:(UIImage *)iconImage;			// headIconに画像をセットします。
- (BOOL)setHeadIconImage:(NSString*)url;		// 指定URLの画像を、headIconにセットします。
- (void)setLayout:(NSInteger)layoutType;		// layoutType(ACHIEVEMENT_CELLや、FRIEND_CELLなど）を指定します。
- (void)setLayout:(NSInteger)cellType;			// layoutType(ACHIEVEMENT_CELLや、FRIEND_CELLなど）を指定します。


/**
 * @brief userNameLabelにテキストをセットします。
 */
- (void)setUserName:(NSString*)userName;

/**
 * @brief leaderboardNameLabelにテキストをセットします。
 */
- (void)setLeaderboardName:(NSString*)leaderboardName;

/**
 * @brief 指定URLの画像を、headIconにセットします。
 */
- (void)setAchievementName:(NSString*)achievementName;

/**
 * @brief achievementInfolabelにテキストをセットします。
 */
- (void)setAchievementInfo:(NSString*)achievementInfo;

/**
 * @brief appNameLabelにテキストをセットします。
 */
- (void)setAppName:(NSString*)appName;

/**
 * @brief gradeNameLabelにテキストをセットします。
 */
- (void)setGradeName:(NSString*)gradeName;

/**
 * @brief agradePointLabelにテキストをセットします。
 */
- (void)setGradePoint:(NSString*)gradePoint;

- (void)setRankingScore:(NSString*)score;
/**
 * @brief rankingLabelにテキストをセットします。
 */
- (void)setRanking:(NSString*)ranking;

/**
 * @brief roomNameLabelにテキストをセットします。
 */
- (void)setRoomName:(NSString*)roomName;

/**
 * @brief NumberOfPeopleLabelにテキストをセットします。
 */
- (void)setNumberOfPeople:(NSString*)numberOfPeople;

/**
 * @brief iconUrlにテキストをセットします。
 */
- (void)setIconUrl:(NSString*)url;

/**
 * @brief countryCodeに従って、国旗画像をflagImageにセットします。
 */
- (void)setFlagImageForCountryCode:(NSString*)countryCode;

/**
 * @brief roomMemberNumLabelに部屋の人数情報のテキストをセットします。
 */
- (void)setRoomMemberNum:(int)memberNum maxMemberNum:(int)maxMemberNum;

/**
 * @brief gradeEnabledに真偽値をセットします。
 */
- (void)setGradeEnabled:(BOOL)boo;

/**
 * @brief speedLevelに応じたsignalImageをセットします
 */
- (void)setSignalImageWithSpeedLevel:(PNConnectionLevel)speedLevel;

/**
 * @brief speedLevelを隠す
 */
- (void)hideSignalImage;

/**
 * @brief flagImageを隠す
 */
- (void)setHiddenFlagImage:(BOOL)boo;

@end
