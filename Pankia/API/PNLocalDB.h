//
//  PNLocalDB.h
//  PankakuNet
//
//  Created by pankaku on 10/08/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface PNLocalDB : NSObject {
	sqlite3*	database;
}
@property (assign) sqlite3*		database;
+ (PNLocalDB*)sharedObject;
+ (NSString*)dbFilePath;
- (void)doPlainSQL:(const NSString*)sqlString;
- (BOOL)processSQLFile:(const NSString*)fileName ofType:(const NSString*)ofType;

// マイグレーション関係
- (int)currentMigrationNumberOfTableNamed:(const NSString*)tableName;
- (void)updateMigrationNumber:(int)migrationNumber forTable:(const NSString*)tableName;
@end
