//
//  PNControllerLoader.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 10/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNControllerLoader.h"
#import <objc/runtime.h>
#import "PankiaNetworkLibrary+Package.h"
#import "PNDashboard.h"
#import "UIView+Slide.h"

@implementation PNControllerLoader

+ (UIViewController*)loadUIViewControllerFromNib:(NSString*)nibName filesOwner:(NSObject*)filesOwner
{
	if(filesOwner == nil){ filesOwner = @"";}

	NSString* nibPath = [[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"];
	if ([nibPath length] > 0) {
		NSArray* objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:filesOwner options:nil];	
		for(unsigned int i = 0; i < [objects count]; ++i){
			NSObject* obj = [objects objectAtIndex:i];
			if([obj isKindOfClass:[UIViewController class]]){				
				return (UIViewController*)obj;
			}
			
		}
	}
	
	return nil;
	
}

+ (UIView*)loadUIViewFromNib:(NSString*)nibName filesOwner:(NSObject*)filesOwner
{
#ifdef DEBUG
	NSDate *loadingStartedAt = [NSDate date];
#endif
	if(filesOwner == nil){ filesOwner = @"";}
	
	NSString* landscapeNibName = [nibName stringByAppendingString:@"Landscape"];
	
	NSArray* nibNames;
	//LandscapeモードのときはLandscapeモード用nibが、PortraitモードのときはPortraitモード用nibが優先で読み込まれるようにします。
	if ([PNDashboard sharedObject].dashboardOrientation == UIInterfaceOrientationLandscapeLeft || [PNDashboard sharedObject].dashboardOrientation == UIInterfaceOrientationLandscapeRight){
		nibNames = [NSArray arrayWithObjects:landscapeNibName, nibName, nil];
	} else {
		nibNames = [NSArray arrayWithObjects:nibName, landscapeNibName, nil];
	}
	
	for (NSString* nibFileName in nibNames){
		//そのnibが存在するか調べます
		NSString* nibFilePath = [[NSBundle mainBundle] pathForResource:nibFileName ofType:@"nib"];
		if ([nibFilePath length] > 0){	//存在していたら読み込みます
			NSArray* objects = [[NSBundle mainBundle] loadNibNamed:nibFileName owner:filesOwner options:nil];
			for(unsigned int i = 0; i < [objects count]; ++i){
				NSObject* obj = [objects objectAtIndex:i];
				if([obj isKindOfClass:[UIView class]]){
#ifdef DEBUG
					NSTimeInterval timeInterval = [loadingStartedAt timeIntervalSinceNow];
					PNCLog(PNLOG_CAT_NIB_LOADER, @"%@ loaded -  %f sec", nibName, -timeInterval);
#endif
					return (UIView*)obj;
				}
			}
		}
	}
	
	return nil;
	
}


+ (UITableViewCell*)loadUITableViewCellFromNib:(NSString*)nibName filesOwner:(NSObject*)filesOwner
{
	if(filesOwner == nil){ filesOwner = @"";}
	
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:filesOwner options:nil];	
	
	for(unsigned int i = 0; i < [objects count]; ++i){
		
		NSObject* obj = [objects objectAtIndex:i];
		if([obj isKindOfClass:[UITableViewCell class]]){
			return (UITableViewCell*)obj;
		}
	}
	
	return nil;
	
}

+ (UIViewController*)load:(NSString*)name filesOwner:(NSObject*)filesOwner
{

	UIViewController* controller = nil;
	
	if([[PNDashboard sharedObject] isLandscapeMode]){
		if ([[PNDashboard sharedObject] isIPad]){
			NSString* iPadLandscapeNibName = [NSString stringWithFormat:@"%@LandscapeIPad", name];
			controller = [self loadUIViewControllerFromNib:[self getControllerNibName:iPadLandscapeNibName] filesOwner:filesOwner];
		}
		
		if (!controller){
			NSString* landscapeNibName = [NSString stringWithFormat:@"%@Landscape", name];
			controller = [self loadUIViewControllerFromNib:[self getControllerNibName:landscapeNibName] filesOwner:filesOwner];
		}
	}
	
	if(!controller){
		controller = [self loadUIViewControllerFromNib:name filesOwner:filesOwner];
	}
		
	if(!controller){		
		Class controllerClass = (Class)objc_lookUpClass([name UTF8String]);

		if(controllerClass){
			controller = (UIViewController*)class_createInstance(controllerClass, 0);
			[controller init];
			[controller autorelease];
		}
	}
		
	return controller;
		
}


+ (UIView*)loadView:(NSString*)viewName filesOwner:(NSObject*)filesOwner
{
	UIView *view = [[[UIView alloc] init] autorelease];
	return view;
}

+ (NSString*)getControllerNibName:(NSString*)controllerName
{
	return [NSString stringWithFormat:@"%@", controllerName];
	
}

+ (NSString*)getControllerClassName:(NSString*)controllerName
{
	return [NSString stringWithFormat:@"%@", controllerName];
}

@end
