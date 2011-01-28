//
//  PNArchiveManager.m
//  PankakuNet
//
//  Created by sota2 on 10/09/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNArchiveManager.h"

#import "PNLogger.h"

@interface PNArchiveManager (Private)
+ (NSString*)pathForFileName:(NSString*)fileName;
@end

@implementation PNArchiveManager

+ (NSString*)pathForFileName:(NSString*)fileName {
	PNLogMethodName;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+ (void)archiveObject:(id)object toFile:(NSString*)fileName {
	PNLogMethodName;
	[NSKeyedArchiver archiveRootObject:object toFile:[self pathForFileName:fileName]];
}

+ (id)unarchiveObjectWithFile:(NSString*)fileName {
	PNLogMethodName;
	return [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForFileName:fileName]];
}

+ (void)archiveString:(NSString*)string toFile:(NSString*)fileName {
	PNLogMethodName;
	[string writeToFile:[self pathForFileName:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString*)unarchiveStringWithFile:(NSString*)fileName {
	PNLogMethodName;
	return [[[NSString alloc] initWithContentsOfFile:[self pathForFileName:fileName] encoding:NSUTF8StringEncoding error:nil] autorelease];
}
+ (void)deleteArchivedFile:(NSString*)fileName
{
	NSError* error;
	[[NSFileManager defaultManager] removeItemAtPath:[self pathForFileName:fileName] error:&error];
}
@end
