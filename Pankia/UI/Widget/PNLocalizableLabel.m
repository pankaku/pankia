#import "PNLocalizableLabel.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"
 

#define kPNColorMake(redCode,greenCode,blueCode) [UIColor colorWithRed:redCode/255.0 green:greenCode/255.0 blue:blueCode/255.0 alpha:1.0]

@implementation PNLocalizableLabel

@synthesize styleName;
@synthesize fontSize;


- (id)init {
	if (self = [super init]) {
		[self setFont:[UIFont fontWithName:kPNDefaultFontName size:self.font.pointSize]];
		self.backgroundColor = [UIColor clearColor];
		self.textColor = [UIColor whiteColor];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.textColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// designated initializer
- (id)initWithFrame:(CGRect)frame style:(PNStyleName)myStyleName {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.styleName = myStyleName;
		self.textColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor clearColor];
		self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		NSString *fontName = @"Verdana-Bold";
		CGFloat labelFontSize;
		
		switch (self.styleName) {
			case PNDefaultStyle:
				labelFontSize = 11.0;
				break;
			case PNHomeButtonLabelStyle:
				labelFontSize = 11.0;
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNButtonLabelStyle:
				labelFontSize = 11.0;
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNUserNameLabelStyle:
				labelFontSize = 16.0;
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNSubLabelStyle:
				labelFontSize = 10.0;
				self.textColor = kPNColorMake(0xCC,0xCC,0xCC);
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNStatusLabelStyle:
				labelFontSize = 10.0;
				self.textColor = [UIColor cyanColor];
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNGradeBarMinLabelStyle:
				labelFontSize = 9.0;
				self.textColor = [UIColor blackColor];
				break;
			case PNGradeBarCurrentLabelStyle:
				labelFontSize = 9.0;
				self.textColor = kPNColorMake(0x99,0xFF,0xFF);
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNGradeBarMaxLabelStyle:
				labelFontSize = 9.0;
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNMenuLabelStyle:
				labelFontSize = 14.0;
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNLargeLabelStyle:
				labelFontSize = 14.0;
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNSmallLabelStyle:
				labelFontSize = 10.0;
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNInputBoxTextStyle:
				labelFontSize = 10.0;
				self.textColor = [UIColor blackColor];
				break;
			case PNAlertViewTitleStyle:
				labelFontSize = 20.0;
				self.textColor = kPNColorMake(0x99,0xFF,0xFF);
				break;
			case PNAlertViewTextStyle:
				labelFontSize = 11.0;
				break;
			case PNRankLabelStyle:
				labelFontSize = 14.0;
				self.textColor = kPNColorMake(0x00,0xFF,0xFF);
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNSpecialLargeLabelStyle:
				labelFontSize = 14.0;
				self.textColor = kPNColorMake(0x99,0xFF,0xFF);
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			case PNSubLargeLabelStyle:
				labelFontSize = 14.0;
				self.textColor = kPNColorMake(0xCC,0xCC,0xCC);
				self.shadowColor = [UIColor blackColor];
				self.shadowOffset = CGSizeMake(0, 1);
				break;
			default:
				break;
		}
		self.font = [UIFont fontWithName:fontName size:labelFontSize];
    }
    return self;
}

- (void) awakeFromNib {
	[self setText:getTextFromTable(self.text)];
	[self setFont:[UIFont fontWithName:kPNDefaultFontName size:self.font.pointSize]];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -

- (void) setFontSize:(float)value {
	fontSize = value;
	[self setFont:[UIFont fontWithName:kPNDefaultFontName size:value]];
}

- (void)setText:(NSString *)newText {
	[super setText:getTextFromTable(newText)];
}

+ (PNLocalizableLabel*)label {
    PNLocalizableLabel* instance = [[[PNLocalizableLabel alloc] init] autorelease];
    return instance;
}

@end
