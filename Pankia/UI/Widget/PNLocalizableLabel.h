#import <UIKit/UIKit.h>


typedef enum {
	PNDefaultStyle,
	PNHomeButtonLabelStyle,
	PNButtonLabelStyle,
	PNUserNameLabelStyle,
	PNSubLabelStyle,
	PNStatusLabelStyle,
	PNGradeBarMinLabelStyle,
	PNGradeBarCurrentLabelStyle,
	PNGradeBarMaxLabelStyle,
	PNMenuLabelStyle,
	PNLargeLabelStyle,	 
	PNSmallLabelStyle, 
	PNInputBoxTextStyle,	
	PNAlertViewTitleStyle,	 
	PNAlertViewTextStyle,
	PNRankLabelStyle,
	PNSpecialLargeLabelStyle, 
	PNSubLargeLabelStyle
} PNStyleName;


@interface PNLocalizableLabel : UILabel {	
	PNStyleName styleName;
	float fontSize;
}

@property (nonatomic, assign) PNStyleName styleName;
@property (nonatomic, assign) float fontSize;

+ (PNLocalizableLabel*)label;
- (id)initWithFrame:(CGRect)frame style:(PNStyleName)myStyleName;

@end
