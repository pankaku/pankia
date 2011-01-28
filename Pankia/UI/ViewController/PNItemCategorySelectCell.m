//
//  PNItemCategorySelectCell.m
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNItemCategorySelectCell.h"
#import "PNItemCategory.h"
#import "UIView+Slide.h"
#import "PNLocalizableLabel.h"

#define kPNPreviousButtonImage @"PNPreviousButton.png"
#define kPNNextButtonImage     @"PNNextButton.png"
#define kPNBackgroundImage     @"PNFixedCellBackgroundImage.png"

@interface PNItemCategorySelectCell ()
@property (nonatomic, retain) UILabel* categoryNameLabel;
@property (nonatomic, retain) UIButton* previousButton;
@property (nonatomic, retain) UIButton* nextButton;
@end

@implementation PNItemCategorySelectCell
@synthesize selectedCategory, categoryNameLabel, previousButton, nextButton, delegate;

- (void)setSelectedCategory:(PNItemCategory *)category
{
	if (selectedCategory != nil) {
		[selectedCategory release];
		selectedCategory = nil;
	}
	selectedCategory = [category retain];
	
	self.categoryNameLabel.text = selectedCategory.name;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		self.categoryNameLabel = [[[PNLocalizableLabel alloc] init] autorelease];
		self.categoryNameLabel.textAlignment = UITextAlignmentCenter;
		self.categoryNameLabel.textColor = [UIColor whiteColor];
		self.categoryNameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:categoryNameLabel];
		
		self.previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *previousButtonImage = [UIImage imageNamed:kPNPreviousButtonImage];
		[previousButton setImage:previousButtonImage forState:UIControlStateNormal];
		self.previousButton.frame = CGRectMake(0.0f, 0.0f, previousButtonImage.size.width + 20.0f, previousButtonImage.size.height + 20.0f);
		[previousButton addTarget:self action:@selector(previousButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:previousButton];
		
		self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *nextButtonImage = [UIImage imageNamed:kPNNextButtonImage];
		[nextButton setImage:nextButtonImage forState:UIControlStateNormal];
		nextButton.frame = CGRectMake(0.0f, 0.0f, nextButtonImage.size.width + 20.0f, nextButtonImage.size.height + 20.0f);
		[nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:nextButton];
		
		self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNBackgroundImage]] autorelease];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)previousButtonTapped
{
	if ([(NSObject*)delegate respondsToSelector:@selector(selectPrevious:)]) {
		[delegate selectPrevious:self];
	}
}
- (void)nextButtonTapped
{
	if ([(NSObject*)delegate respondsToSelector:@selector(selectNext:)]) {
		[delegate selectNext:self];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self.categoryNameLabel setFrame:CGRectMake(0.0f,0.0f,self.frame.size.width,self.frame.size.height)];
	
	float buttonY = (self.frame.size.height - previousButton.frame.size.height) * 0.5f;
	[previousButton moveToX:20.0f y:buttonY];
	[nextButton moveToX:self.frame.size.width - 20.0f - nextButton.frame.size.width y:buttonY];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.categoryNameLabel = nil;
    [super dealloc];
}


@end
