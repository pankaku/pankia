#import "PNDefaultButton.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"



@implementation PNDefaultButton

+ (PNDefaultButton*)buttonWithTitle:(NSString*)title
{
    PNDefaultButton* anInstance = [self button];
    [anInstance setTitle:title];
    return anInstance;
}

- (void)defaultButtonColorRed
{
	float buttonLeftCapWidth = 18.0f;
	float buttonTopCapHeight = 18.0f;
	UIImage* normalImage = [UIImage imageNamed:@"PNNegativeButton.png"];
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];
	[self refreshText];
}

- (void)defaultButtonColorGreen
{
	float buttonLeftCapWidth = 18.0f;
	float buttonTopCapHeight = 18.0f;
	UIImage* normalImage = [UIImage imageNamed:@"PNNormalButton.png"];
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];
	[self refreshText];
}

- (void)defaultButtonColorBlue
{
	float buttonLeftCapWidth = 18.0f;
	float buttonTopCapHeight = 18.0f;
	UIImage* normalImage = [UIImage imageNamed:@"PNPositiveButton.png"];
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];
	[self refreshText];
}

- (void)refreshText
{
	[self setTitle:getTextFromTable(self.titleLabel.text)];
}

@end
