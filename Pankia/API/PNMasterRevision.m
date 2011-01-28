//
//  PNMasterRevision.m
//  PankakuNet
//
//  Created by sota2 on 10/11/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMasterRevision.h"
#import "PNArchiveManager.h"
#import "NSDictionary+GetterExt.h"

#define kPNRevisedObjectKeyAchievements		@"achievements"
#define kPNRevisedObjectKeyCategories		@"categories"
#define kPNRevisedObjectKeyFeatures			@"features"
#define kPNRevisedObjectKeyGrades			@"grades"
#define kPNRevisedObjectKeyItems			@"items"
#define kPNRevisedObjectKeyLeaderboards		@"leaderboards"
#define kPNRevisedObjectKeyLobbies			@"lobbies"
#define kPNRevisedObjectKeyMerchandises		@"merchandises"
#define kPNRevisedObjectKeyTotal			@"total"
#define kPNRevisedObjectKeyVersions			@"versions"

@interface PNMasterRevision()
@property (nonatomic, retain) NSDictionary* originalDictionary;
@end

@implementation PNMasterRevision
@synthesize originalDictionary;

+ (id)masterRevisionWithDictionary:(NSDictionary*)dictionary
{
	PNMasterRevision *anInstance = [[[PNMasterRevision alloc] init] autorelease];
	anInstance.originalDictionary = dictionary;
	return anInstance;
}
+ (id)currentRevision
{
	return [PNArchiveManager unarchiveObjectWithFile:@"revision-info.plist"];
}
- (void)saveAsCurrent
{
	[PNArchiveManager archiveObject:self toFile:@"revision-info.plist"];
}
#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:originalDictionary forKey:@"original_dictionary"];
}
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
	self.originalDictionary = [decoder decodeObjectForKey:@"original_dictionary"];
    return self;
}

#pragma mark -
// totalの値を比較して、同じであれば同等(リビジョン変更なし)とみなします。
- (BOOL)isEqual:(id)object{
	if (![object isKindOfClass:[PNMasterRevision class]]) return NO;
	PNMasterRevision* target = (PNMasterRevision*)object;
	if (self.originalDictionary == nil || target.originalDictionary == nil) return NO;
	if (self.total < 0 || target.total < 0) return NO;
	if (self.total != target.total) return NO;
	return YES;
}

#pragma mark Getters

// keyに対するオブジェクトのリビジョン番号を返します。
// keyに対するオブジェクトが存在しない場合は-1を返します。
- (int)revisionForKey:(NSString*)key
{
	return [originalDictionary intValueForKey:key defaultValue:-1];
}

// 各要素に対するゲッターメソッド
// タイプミス等によるバグを回避するためにプロパティを使用しています。
// その要素に対するリビジョン番号が見つからなかった場合は-1を返します。
- (int)achievements {	return [self revisionForKey:kPNRevisedObjectKeyAchievements]; }
- (int)categories {		return [self revisionForKey:kPNRevisedObjectKeyCategories]; }
- (int)features {		return [self revisionForKey:kPNRevisedObjectKeyFeatures]; }
- (int)grades {			return [self revisionForKey:kPNRevisedObjectKeyGrades]; }
- (int)items {			return [self revisionForKey:kPNRevisedObjectKeyItems]; }
- (int)leaderboards {	return [self revisionForKey:kPNRevisedObjectKeyLeaderboards]; }
- (int)lobbies {		return [self revisionForKey:kPNRevisedObjectKeyLobbies]; }
- (int)merchandises {	return [self revisionForKey:kPNRevisedObjectKeyMerchandises]; }
- (int)total {			return [self revisionForKey:kPNRevisedObjectKeyTotal]; }
- (int)versions {		return [self revisionForKey:kPNRevisedObjectKeyVersions]; }
@end
