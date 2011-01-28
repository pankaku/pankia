//
//  PNFacebookAccountModel.h
//  PankakuNet
//
//  Created by pankaku on 10/08/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNDataModel.h"

#define kPNFacebookDefaultID                0
#define kPNFacebookDefaultScreenName        @""

@interface PNFacebookAccountModel : PNDataModel {
	int64_t _id;
	NSString* name;
}
@property (nonatomic, assign) int64_t id;
@property (nonatomic, retain) NSString* name;
@end
