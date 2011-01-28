#import "PNUserStatsLabel.h"
#import "UILabel+textWidth.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"
#import	"PNGlobalManager.h"
#import "PNFormatUtil.h"
 

@implementation PNUserStatsLabel
@synthesize user = _user;
@synthesize alignment = _alignment;
@synthesize textIndentX;

- (id)initWithFrame:(CGRect)frame {
	PNLogMethodName;
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void) setUser:(PNUser*)user{
	PNLogMethodName;
	PNSafeDelete(_user);
	_user = [user retain];
	[self updateStats];
}
- (void) setAlignment:(UITextAlignment)alignment{
	PNLogMethodName;
	_alignment = alignment;
	[self updateLayout];
}

- (void) updateStats{
	PNLogMethodName;
	NSString* fontName = kPNDefaultFontName;
	static CGFloat   pointSize  = 10.0f;
	UIFont *defaultFont = [UIFont fontWithName:fontName size:pointSize];
	[achievementLabel setFont:defaultFont];
	[gradeNameLabel   setFont:defaultFont];
	[gradePointLabel setFont:defaultFont];
	[coinLabel	setFont:defaultFont];
	
	if (_user == [PNUser currentUser] && [PNManager sharedObject].isLoggedIn == NO ){	//ユーザが自分でなおかつオフラインの時はローカルの情報を元に計算します
		[achievementLabel setText:[NSString stringWithFormat:@"%d / %d", [[PNLocalAchievementDB sharedObject] unlockedPointsOfUser:[[PNUser currentUser].userId intValue]],
								   [[PNAchievementManager sharedObject] totalPoints]]];
	} else if ([PNManager sharedObject].isLoggedIn == YES) {	//オンラインの時はサーバーの情報を元に計算します
		[achievementLabel setText:[NSString stringWithFormat:@"%d / %d", _user.achievementPoint,_user.achievementTotal]];
	} else {	//その他の時は計算するデータがないので -- を表示します。
		[achievementLabel setText:@"--"];
	}

	if (!_user.gradeEnabled) {
		[gradePointImage setHidden:YES];
		[gradeNameLabel  setHidden:YES];
		[gradePointLabel setHidden:YES];
	} else {
		[gradePointImage setHidden:NO];
		[gradeNameLabel  setHidden:NO];
		[gradePointLabel setHidden:NO];
		[gradeNameLabel  setText:_user.gradeName];
		
		NSNumber *number = [NSNumber numberWithInt:_user.gradePoint];
		NSNumberFormatter *fmt =[[[NSNumberFormatter alloc] init] autorelease];
		[fmt setPositiveFormat:@"#,##0"];
		[fmt setNegativeFormat:@"-#,##0"];
		NSString *str = [fmt stringForObjectValue:number];
		
		if (gradeNameLabel.text && ![gradeNameLabel.text isEqualToString:@""]) {
			[gradePointLabel setText:[NSString stringWithFormat:@"(%@)", str]];
		} else {
			[gradePointLabel setText:str];
		}
	}
	
	// begin - lerry modified
	if ([[PNGlobalManager sharedObject] coinsEnabled]) {
		[coinLabel setHidden:NO];
		[coinImage setHidden:NO];
		[coinLabel setText:[PNFormatUtil stringWithComma:_user.coins]];
	} else {
		[coinLabel setHidden:YES];
		[coinImage setHidden:YES];
	}
	// end - lerry modified
	
	[self updateLayout];
}

//Make labels & images right aligned.
- (void)updateLayout{	
	PNLogMethodName;
	const int USER_STATS_LABEL_SPACING = 1.0f;	//Space between ui elements.
	
	//Get current y location of labels.
	float labelY = 4;
	float iconY  = labelY-2;
	float labelHeight = achievementLabel.frame.size.height;
	
	//Get widths of each ui element.
	float achievementLabelWidth = [achievementLabel textWidth];
	float gradeNameLabelWidth = [gradeNameLabel textWidth];
	float gradePointLabelWidht = [gradePointLabel textWidth];
	float coinLabelWidth = [coinLabel textWidth];
	
	//Determine x location of each ui element.
	float totalWidth = achievementImage.frame.size.width + USER_STATS_LABEL_SPACING
					+ achievementLabelWidth + USER_STATS_LABEL_SPACING
					+ gradePointImage.frame.size.width + USER_STATS_LABEL_SPACING
					+ gradeNameLabelWidth
					+ gradePointLabelWidht+ USER_STATS_LABEL_SPACING + 
					coinImage.frame.size.width + USER_STATS_LABEL_SPACING
					+ coinLabelWidth;
	float frameWidth = self.frame.size.width;
	
	float leftOffset;
	switch (_alignment) {
		case UITextAlignmentLeft:
			leftOffset = 0.0f;
			break;
		case UITextAlignmentCenter:
			leftOffset = (frameWidth - totalWidth) * 0.5f;
			break;
		case UITextAlignmentRight:
			leftOffset = (frameWidth - totalWidth);
			break;
		default:
			leftOffset = 0.0f;
			break;
	}
	textIndentX = leftOffset;

	float achievementImageX = leftOffset;
	float achievementLabelX = achievementImageX + achievementImage.frame.size.width + USER_STATS_LABEL_SPACING;
	float gradePointImageX = achievementLabelX + achievementLabelWidth + USER_STATS_LABEL_SPACING;
	float gradeNameLabelX = gradePointImageX + gradePointImage.frame.size.width + USER_STATS_LABEL_SPACING;
	float gradePointLabelX = gradeNameLabelX + gradeNameLabel.frame.size.width + USER_STATS_LABEL_SPACING;
	float coinImageX = gradePointLabelX + gradePointLabelWidht + USER_STATS_LABEL_SPACING;
	float coinLabelX = coinImageX + coinImage.frame.size.width + USER_STATS_LABEL_SPACING;
	
	//Relocate each ui element.
	[gradeNameLabel setFrame:CGRectMake(gradeNameLabelX, labelY, gradeNameLabelWidth, labelHeight)];
	[gradePointImage setFrame:CGRectMake(gradePointImageX, iconY, gradePointImage.frame.size.width, gradePointImage.frame.size.height)];
	[achievementLabel setFrame:CGRectMake(achievementLabelX, labelY, achievementLabelWidth, labelHeight)];
	[achievementImage setFrame:CGRectMake(achievementImageX, iconY, achievementImage.frame.size.width, achievementImage.frame.size.height)];		
	[gradePointLabel setFrame:CGRectMake(gradePointLabelX, labelY, gradePointLabelWidht, labelHeight)];	
	[coinImage setFrame:CGRectMake(coinImageX, iconY, coinImage.frame.size.width, coinImage.frame.size.height)];
	[coinLabel setFrame:CGRectMake(coinLabelX, labelY, coinLabelWidth, labelHeight)];

}

- (void)drawRect:(CGRect)rect {
	PNLogMethodName;
    // Drawing code
}


- (void)dealloc {
	PNLogMethodName;
	PNSafeDelete(_user);
    [super dealloc];
}


@end
