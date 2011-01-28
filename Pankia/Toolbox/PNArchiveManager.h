//
//  PNArchiveManager.h
//  PankakuNet
//
//  Created by sota2 on 10/09/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PNArchiveManager : NSObject {

}
+ (void)archiveObject:(id)object toFile:(NSString*)fileName;
+ (id)unarchiveObjectWithFile:(NSString*)fileName;
+ (void)archiveString:(NSString*)string toFile:(NSString*)fileName;
+ (NSString*)unarchiveStringWithFile:(NSString*)fileName;
+ (void)deleteArchivedFile:(NSString*)fileName;
@end
