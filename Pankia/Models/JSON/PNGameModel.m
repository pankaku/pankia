#import "PNGameModel.h"
#import "PNUserModel.h"
#import "PNFeatureModel.h"
#import "NSString+VersionString.h"
//Game
#define kPNGameDefaultID					-1
#define kPNGameDefaultName					@""
#define kPNGameDefaultDescription			@""
#define kPNGameDefaultIconURL				@""
#define kPNGameDefaultGrade					NO

@implementation PNGameModel

@synthesize id = _id, name = _name, description = _description, icon_url = _icon_url, grade_enabled = _grade_enabled,
	currentVersion = _currentVersion, iTunesURL = _iTunesURL, features = _features, screenshot_urls, followees, thumbnail_urls, developer_name, price;

- (id) init{
	if (self = [super init]){
		self.id = kPNGameDefaultID;
		self.name = kPNGameDefaultName;
		self.description = kPNGameDefaultDescription;
		self.icon_url = kPNGameDefaultIconURL;
		self.grade_enabled = kPNGameDefaultGrade;
		self.currentVersion = nil;
		self.iTunesURL = nil;
		self.features = nil;
		self.screenshot_urls = [NSArray array];
		self.thumbnail_urls = [NSArray array];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	if (self = [super initWithDictionary:aDictionary]) {
		if (aDictionary == nil) {
			return nil;
		}
		self.id = [aDictionary intValueForKey:@"id" defaultValue:kPNGameDefaultID];
		self.description = [aDictionary stringValueForKey:@"description" defaultValue:kPNGameDefaultDescription];
		self.icon_url = [aDictionary stringValueForKey:@"icon_url" defaultValue:kPNGameDefaultIconURL];
		self.name = [aDictionary stringValueForKey:@"name" defaultValue:kPNGameDefaultName];
		self.grade_enabled = [aDictionary boolValueForKey:@"grade_enabled" defaultValue:kPNGameDefaultGrade];
		if ([aDictionary hasObjectForKey:@"current_version"]){
			self.currentVersion = [PNVersionModel dataModelWithDictionary:[aDictionary objectForKey:@"current_version"]];
		}
		
		//self.features = [PNFeatureModel availableDataModelsFromArray:[aDictionary objectForKey:@"features"] inVersion:[self.currentVersion.value versionIntValue]];
		
		if ([aDictionary hasObjectForKey:@"features"]) {
			NSArray* featureDictionaries = [aDictionary objectForKey:@"features"];
			NSMutableArray* featureArray = [NSMutableArray arrayWithCapacity:[featureDictionaries count]];
			
			for (NSDictionary* feature in featureDictionaries) {
				[featureArray addObject:[feature objectForKey:@"key"]];
			}
			self.features = featureArray;
		} else {
			self.features = [NSArray array];
		}
 
		self.iTunesURL = [aDictionary stringValueForKey:@"itunes_url" defaultValue:nil];
		self.screenshot_urls = [aDictionary objectForKey:@"screenshot_urls"];
		self.thumbnail_urls = [aDictionary objectForKey:@"thumbnail_screenshot_urls"];
		
		if ([aDictionary hasObjectForKey:@"followees"]) {
			self.followees = [PNUserModel dataModelsFromArray:[aDictionary objectForKey:@"followees"]];
		} else {
			self.followees = [NSArray array];
		}
		
		if ([aDictionary hasObjectForKey:@"developer"]) {
			NSDictionary* developerTree = [aDictionary objectForKey:@"developer"];
			self.developer_name = [developerTree objectForKey:@"name"];
		}
		
		self.price = [aDictionary objectForKey:@"price"];

	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	self.name			= nil;
	self.description	= nil;
	self.icon_url		= nil;
	self.currentVersion = nil;
	self.iTunesURL		= nil;
	self.features		= nil;
	self.screenshot_urls = nil;
	self.thumbnail_urls = nil;
	self.followees		= nil; 
	self.developer_name = nil;
	self.price			= nil;
	[super dealloc];

}

@end
