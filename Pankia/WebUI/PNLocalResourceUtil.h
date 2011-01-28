//
//  PNLocalResourceUtil.h
//  PankakuNet
//
//  Created by sota on 11/01/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kPNDashboardDefaultUIResourcesBaseDirectoryPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/pankia/dashboard/default/resources"]
#define kPNDashboardDefaultUIResourceArchiveFileName @"pn_default_ui_theme"
#define kPNDashboardDefaultUIResourceArchiveFilePath [[NSBundle mainBundle] pathForResource:kPNDashboardDefaultUIResourceArchiveFileName ofType:@"zip"]
#define kPNDashboardDefaultUICopiedVersionDateTime @"PNDashboardDefaultUICopiedVersionDateTime"

@interface PNLocalResourceUtil : NSObject {

}
+ (BOOL)isLocalResourceAvailableForURL:(NSURL*)url;
+ (NSString*)pathForHTMLResourceForSelectorName:(NSString*)selectorName;
+ (NSString*)HTMLStringValueForURL:(NSURL*)url;
@end
