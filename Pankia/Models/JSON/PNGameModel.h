#import "PNDataModel.h"
#import "PNVersionModel.h"

@interface PNGameModel : PNDataModel {
	int								_id;
	NSString*						_name;
	NSString*						_description;
	NSString*						_icon_url;
	BOOL							_grade_enabled;
	PNVersionModel*					_currentVersion;
	NSString*						_iTunesURL;
	NSArray*						_features;
	NSArray*						screenshot_urls;
	NSArray*						thumbnail_urls;
	NSArray*						followees;
	NSString*						developer_name;
	NSString*						price;
}

@property (assign, nonatomic) int				id;
@property (retain, nonatomic) NSString*		name;
@property (retain, nonatomic) NSString*		description;
@property (retain, nonatomic) NSString*		icon_url;
@property (assign, nonatomic) BOOL				grade_enabled;
@property (retain, nonatomic) PNVersionModel*	currentVersion;
@property (retain, nonatomic) NSString*		iTunesURL;
@property (retain, nonatomic) NSArray* features;
@property (nonatomic, retain) NSArray* screenshot_urls;
@property (nonatomic, retain) NSArray* thumbnail_urls;
@property (nonatomic, retain) NSArray* followees;
@property (nonatomic, retain) NSString* developer_name;
@property (nonatomic, retain) NSString* price;
@end
