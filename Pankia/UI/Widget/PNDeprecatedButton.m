#import "PNDeprecatedButton.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNGlobal.h"

@implementation PNDeprecatedButton
- (void) awakeFromNib{
	[self setTitle:getTextFromTable(self.titleLabel.text)];
}

- (void)configureBackgroundImage
{
	[super configureBackgroundImage];
    UIImage* normalImage = [UIImage imageNamed:@"PNDefaultButtonGreen.png"];
	UIImage* selectedImage = [UIImage imageNamed:@"PNDefaultButtonDisable.png"];
	
	float buttonLeftCapWidth = 20.0f;
	float buttonTopCapHeight = 20.0f;
	
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateHighlighted];
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateDisabled];
}
/*
- (void)_init
{
	UIImage* normalImage = [UIImage imageNamed:@"PNDefaultButtonGreen.png"];
	UIImage* selectedImage = [UIImage imageNamed:@"PNDefaultButtonDisable.png"];
	
	NSString* fontName = kPNDefaultFontName;
	[self.titleLabel setFont:[UIFont fontWithName:fontName size:11]];
	
	[self setTitle:getTextFromTable(self.titleLabel.text)];
	
	const int buttonLeftCapWidth = 18;
	const int buttonTopCapHeight = 18;
	[self setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateNormal];
	[self setBackgroundImage:[selectedImage stretchableImageWithLeftCapWidth:buttonLeftCapWidth topCapHeight:buttonTopCapHeight] forState:UIControlStateDisabled];	
}
*/
- (void)dealloc {
    [super dealloc];
}


@end
