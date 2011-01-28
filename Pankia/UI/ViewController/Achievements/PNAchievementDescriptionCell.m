//
//  PNAchievementDescriptionCell.m
//  PankakuNet
//
//  Created by Hiroki Tsuchimoto on 10/12/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNAchievementDescriptionCell.h"
#import "PNLocalizableLabel.h"

@implementation PNAchievementDescriptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {    

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		CGRect descriptionLabelFrame = CGRectMake(71, 3, 250, 18);
		descriptionLabel = [[PNLocalizableLabel alloc] initWithFrame:descriptionLabelFrame style:PNSubLabelStyle];
		[self addSubview:descriptionLabel];
		[descriptionLabel release];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[descriptionLabel release];
    [super dealloc];
}


#pragma mark -

- (void)setDescriptionText:(NSString *)description {
	descriptionLabel.text = [NSString stringWithFormat:@"%@", description];
}

@end
