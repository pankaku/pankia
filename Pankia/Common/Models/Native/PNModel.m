//
//  PNModel.m
//  PankakuNet
//
//  Created by 横江 宗太 on 10/11/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNModel.h"
#import "NSString+VersionString.h"


@implementation PNModel
@synthesize maxVersion, minVersion;

- (id) init
{
	if (self = [super init]) {
		minVersion = 0;
		maxVersion = 99999999;
	}
	return self;
}

- (id) initWithDataModel:(PNDataModel *)dataModel
{
	if (self = [self init]) {
		if (dataModel.max_version != nil){
			maxVersion			= [dataModel.max_version versionIntValue];
		}
		if (dataModel.min_version != nil){
			minVersion			= [dataModel.min_version versionIntValue];
		}
	}
	return self;
}

+ (id) modelFromDataModel:(PNDataModel *)dataModel
{
	return [[[self alloc] initWithDataModel:dataModel] autorelease];
}

+ (NSArray*) modelsFromDataModels:(NSArray *)dataModels
{
	NSMutableArray* models = [NSMutableArray array];
	for (PNDataModel* dataModel in dataModels) {
		[models addObject:[self modelFromDataModel:dataModel]];
	}
	return models;
}

+ (NSArray*) modelsFromDataModels:(NSArray *)dataModels availableInVersion:(int)versionNumber
{
	NSMutableArray* models = [NSMutableArray array];
	for (PNDataModel* dataModel in dataModels) {
		PNModel* model = [self modelFromDataModel:dataModel];
		if ([model isAvailable:versionNumber]) {
			[models addObject:[self modelFromDataModel:dataModel]];
		}
	}
	return models;
}

- (BOOL) isAvailable:(int)currentVersionInt
{
	if (minVersion > currentVersionInt) return NO;
	if (maxVersion < currentVersionInt) return NO;
	
	return YES;
}
@end
