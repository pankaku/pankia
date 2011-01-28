//
//  PNTableViewCell.m
//  PankakuNet
//
//  Created by sota2 on 10/10/05.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PNTableViewCell.h"
#import "PNGlobal.h"
#import "PNImageUtil.h"
 
#import "PNLogger.h"
#import "UILabel+textWidth.h"

#define kPNCellBackgroundImage	@"PNTableCellBackgroundImage.png"
#define kPNBlankImage			@"PNBlank.png"
#define kPNArrowImage			@"PNCellArrowImage.png"


@interface PNTableViewCell ()
- (void)setBackgroundImage;
- (void)setFontSize:(float)size;
- (void)setPaddingLeft:(float)value;
- (void)configureStyles;
@end


@implementation PNTableViewCell

@synthesize backgroundStyle;
@synthesize fontSize, paddingLeft;


- (void)setBackgroundImage {
	UIImage *backgroundImage = [UIImage imageNamed:kPNCellBackgroundImage];
	UIView *cellBackgroundView = [[[UIView alloc] init] autorelease];
	cellBackgroundView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
	self.backgroundView = cellBackgroundView;
}

- (void)setFontSize:(float)size {
	PNLogMethodName;
    fontSize = size;
    self.textLabel.font = [UIFont fontWithName:kPNDefaultFontName size:fontSize];
}

- (void)setPaddingLeft:(float)value {
	PNLogMethodName;
    paddingLeft = value;
    if (paddingLeft == 0.0f) {
		return;
	}
	self.imageView.image = [PNImageUtil imageWithPadding:[UIImage imageNamed:kPNBlankImage]
													left:0.0f top:0.0f right:0.0f bottom:0.0f width:paddingLeft height:10.0f];
}

- (void)configureStyles {
	PNLogMethodName;
    self.backgroundStyle = PNTableViewCellBackgroundStyleDefault;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.textColor = [UIColor whiteColor];
    self.fontSize = 13.0f;
    self.detailTextLabel.font = [UIFont fontWithName:kPNDefaultFontName size:11.0f];
    self.paddingLeft = 1.0f;
}

#pragma mark -

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	PNLogMethodName;
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.frame = CGRectMake(0, 0, 480, 50);
        [self configureStyles];
		[self setBackgroundImage];
    }
    return self;
}

+ (PNTableViewCell*)cellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	PNLogMethodName;
    return [[[self alloc] initWithStyle:style reuseIdentifier:reuseIdentifier] autorelease];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	PNLogMethodName;
    [super setSelected:selected animated:animated];
}

#pragma mark - 

- (UILabel*)labelForAccessoryWithText:(NSString*)text {
	PNLogMethodName;
	UILabel* label = [[[UILabel alloc] init] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor cyanColor];
	label.font = [UIFont fontWithName:kPNDefaultFontName size:11.0f];
	label.text = text;
	
	float labelWidth = [label textWidth];
	float labelHeight = [label textHeight];
	[label setFrame:CGRectMake(0.0f, 0.0f, labelWidth, labelHeight)];
	
	return label;
}

#pragma mark -

- (void)loadRoundRectImageNamed:(NSString*)defaultImageName paddingLeft:(float)left top:(float)top right:(float)right bottom:(float)bottom width:(float)width height:(float)height delegate:(id)delegate {
	PNLogMethodName;
    UIImage* originalIconImage = [UIImage imageNamed:defaultImageName];
	self.imageView.image = [PNImageUtil imageWithPadding:originalIconImage 
													left:left top:top right:right bottom:bottom 
												   width:width height:height];
}

- (void)loadRoundRectImageFromURL:(NSString*)url defaultImageName:(NSString*)defaultImageName
					  paddingLeft:(float)left top:(float)top right:(float)right bottom:(float)bottom
							width:(float)width height:(float)height delegate:(id)delegate {

	PNLogMethodName;
	UIImage* originalIconImage;
	if (url != nil && [url length] > 0 && ![url hasSuffix:@"missing.png"]){
		//アイコンがある場合
		if ([PNImageUtil hasCacheForUrl:url]){
			originalIconImage = [UIImage imageWithContentsOfFile:[PNImageUtil cacheFilePathForURL:url]];
		} else {
			// キャッシュがなければダウンロードしにいき、数秒後に更新します
			[PNImageUtil createCacheForUrl:url];
			[delegate performSelector:@selector(reloadData) withObject:nil afterDelay:1.0f];

			originalIconImage = [UIImage imageNamed:defaultImageName];
		}
	} else {
		// アイコンがない場合
		originalIconImage = [UIImage imageNamed:defaultImageName];
	}
	self.imageView.image = [PNImageUtil imageWithPadding:originalIconImage 
													left:left top:top right:right bottom:bottom 
												   width:width height:height];
}

#pragma mark -

- (void)setAccessoryView:(UIView *)view {
	PNLogMethodName;
	UIView* viewWithContainer = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width + 10.0f, view.frame.size.height)] autorelease];
	[viewWithContainer addSubview:view];
	[super setAccessoryView:viewWithContainer];
}

- (void)setArrowAccessoryWithText:(NSString*)text {
	PNLogMethodName;
	UIView* accessoryContainer = [[[UIView alloc] init] autorelease];
	UIImageView* arrowImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kPNArrowImage]] autorelease];
	UILabel* label = [self labelForAccessoryWithText:text];
	
	float PADDING = 10.0f;
    
	float labelWidth = [label textWidth];
	float labelHeight = [label textHeight];
	float imageWidth = arrowImage.frame.size.width;
	float totalWidth = labelWidth + PADDING + imageWidth;
	float totalHeight = arrowImage.frame.size.height;
	
	[accessoryContainer addSubview:label];	
	[accessoryContainer addSubview:arrowImage];
	
	[accessoryContainer setFrame:CGRectMake(0.0f, 0.0f, totalWidth, totalHeight)];
	[label setFrame:CGRectMake(0.0f, (totalHeight- labelHeight) * 0.5f, labelWidth, labelHeight)];
	[arrowImage setFrame:CGRectMake(labelWidth + PADDING, 0.0f, imageWidth, totalHeight)];
	
	self.accessoryView = accessoryContainer;
}

- (void)setAccessoryText:(NSString*)text {
	PNLogMethodName;
	self.accessoryView = [self labelForAccessoryWithText:text];
}

- (void)dealloc {
	PNLogMethodName;
    [super dealloc];
}

@end
