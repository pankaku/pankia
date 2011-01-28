#import "PNRoomsReloadActionCell.h"
#import "PankiaNetworkLibrary+Package.h"
#import "PNDashboard.h"

@implementation PNRoomsReloadActionCell

@synthesize delegate;

- (void)awakeFromNib
{
	[super awakeFromNib];
}

/*
- (IBAction)pressedReloadBtn:(id)sender
{
	if ([[PNDashboard getWrappedNavigationController]  isIndicatorAnimating]) return;
	if (delegate && [delegate respondsToSelector:@selector(reload)]) {
		[delegate reload];
	}
}
*/

- (void)dealloc
{
	self.delegate = nil;
	[super dealloc];
}

@end
