#import <UIKit/UIKit.h>
#import "PNNavigationController.h"
#import "PNTableViewCell.h"


#define kPNCellBackgroundImage		@"PNTableCellBackgroundImage.png"
#define kPNCellInfoBackgroundImage	@"PNInformationTableCellBackgroundImage.png"


@interface PNTableViewController : UITableViewController {

}

- (void)reloadData;	
- (void)setBackgroundImage:(UITableViewCell *)cell;

- (NSString*)cellIdentifierName:(NSString*)prefix;
- (UITableViewCell*)cellWithIdentifier:(NSString*)identifier;

@end
