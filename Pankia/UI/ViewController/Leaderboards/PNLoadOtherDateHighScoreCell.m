#import "PNLoadOtherDateHighScoreCell.h"
#import "PNHighScoreViewController.h"
#import "PankiaNetworkLibrary+Package.h"

@implementation PNLoadOtherDateHighScoreCell

@synthesize dateLabel,delegate,targetDate,scope;

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self disableNextBtn];
	self.targetDate == [NSDate date];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.dateLabel		= nil;
	self.delegate		= nil;
	self.targetDate		= nil;
    [super dealloc];
}


- (IBAction)previousDate
{
	if ([delegate respondsToSelector:@selector(resetScore)]) {
		[delegate resetScore];
	}
	
	if (scope == kPNLeaderboardPeriodMonthly){
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
		comps.month = -1;
		NSDate* tmpDate = [calendar dateByAddingComponents:comps toDate:targetDate options:0];
		self.targetDate = tmpDate;
		
		[(PNHighScoreViewController*)delegate setTargetDate:tmpDate];
		if([delegate respondsToSelector:@selector(sendQueries)]){
			[(PNHighScoreViewController*)delegate sendQueries];
		}
	}
	else if(scope == kPNLeaderboardPeriodDaily){
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
		comps.day = -1;
		NSDate* tmpDate = [calendar dateByAddingComponents:comps toDate:targetDate options:0];
		self.targetDate = tmpDate;

		[(PNHighScoreViewController*)delegate setTargetDate:tmpDate];
		if([delegate respondsToSelector:@selector(sendQueries)]){
			[(PNHighScoreViewController*)delegate sendQueries];
		}
	}

	[self enableNextBtn];
}

- (IBAction)nextDate
{
	if ([delegate respondsToSelector:@selector(resetScore)]) {
		[delegate resetScore];
	}
	
	if (scope == kPNLeaderboardPeriodMonthly){
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
		comps.month = 1;
		NSDate* tmpDate = [calendar dateByAddingComponents:comps toDate:targetDate options:0];
		
		comps.month = 2;
		NSDate*	nextMonthDate = [calendar dateByAddingComponents:comps toDate:targetDate options:0];
		if ([nextMonthDate compare:[NSDate date]] == NSOrderedDescending) {
			[self disableNextBtn];
		}

		self.targetDate = tmpDate;
		[(PNHighScoreViewController*)delegate setTargetDate:tmpDate];

		if([delegate respondsToSelector:@selector(sendQueries)]){
			[delegate sendQueries];
		}
						
	}
	else if(scope == kPNLeaderboardPeriodDaily){
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
		comps.day = 1;
		NSDate* tmpDate = [calendar dateByAddingComponents:comps toDate:targetDate options:0];
		
		comps.day = 2;
		NSDate*	nextMonthDate = [calendar dateByAddingComponents:comps toDate:targetDate options:0];

		if ([nextMonthDate compare:[NSDate date]] == NSOrderedDescending) {
			[self disableNextBtn];
		}
		self.targetDate = tmpDate;
		[(PNHighScoreViewController*)delegate setTargetDate:tmpDate];
		if([delegate respondsToSelector:@selector(sendQueries)]){
			[delegate sendQueries];
		}
				
	}
	
}

- (void)enableNextBtn
{
	hiddenButton.hidden = NO;
	nextButton.hidden = NO;
}

- (void)disableNextBtn
{
	hiddenButton.hidden = YES;
	nextButton.hidden = YES;
}

@end
