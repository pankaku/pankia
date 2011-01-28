//
//  PNTableViewCell.h
//  PankakuNet
//
//  Created by sota2 on 10/10/05.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum PNTableViewCellBackgroundStyle {
    PNTableViewCellBackgroundStyleDefault	= 0,
    PNTableViewCellBackgroundStyleFixed		= 1,
} PNTableViewCellBackgroundStyle;

@interface PNTableViewCell : UITableViewCell {
    PNTableViewCellBackgroundStyle backgroundStyle;
    float fontSize;
    float paddingLeft;
}
@property (nonatomic, assign) PNTableViewCellBackgroundStyle backgroundStyle;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) float paddingLeft;

+ (PNTableViewCell*)cellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)loadRoundRectImageNamed:(NSString*)defaultImageName
					paddingLeft:(float)left
							top:(float)top
						  right:(float)right
						 bottom:(float)bottom
						  width:(float)width
						 height:(float)height
					   delegate:(id)delegate;
- (void)loadRoundRectImageFromURL:(NSString*)url
				 defaultImageName:(NSString*)defaultImageName
					  paddingLeft:(float)left
							  top:(float)top
							right:(float)right
						   bottom:(float)bottom
							width:(float)width
						   height:(float)height
						 delegate:(id)delegate;
- (void)setArrowAccessoryWithText:(NSString*)text;
- (void)setAccessoryText:(NSString*)text;
@end
