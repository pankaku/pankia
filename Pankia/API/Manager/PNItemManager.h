//
//  PNItemManager.h
//  PankakuNet
//
//  Created by sota on 10/09/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNItem;
@class PNError;
@interface PNItemManager : NSObject {
	NSArray* itemArray;
	NSMutableDictionary* itemDictionary;
	NSArray* categoryArray;
	NSMutableDictionary* categoryDictionary;
}
@property (nonatomic, retain) NSArray* categoryArray;
@property (nonatomic, retain) NSArray* itemArray;

+ (PNItemManager*)sharedObject;

- (PNItem*)itemWithIdentifier:(NSString*)identifier;
- (void)updateItemFieldsFromServerDictionary:(NSDictionary*)dictionary;

- (void)acquireItem:(NSString*)itemId quantity:(int)quantity delegate:(id)delegate
		onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)acquireItems:(NSDictionary*)items delegate:(id)delegate
		onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)consumeItem:(NSString*)itemId quantity:(int)quantity delegate:(id)delegate
		onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)consumeItems:(NSDictionary*)items delegate:(id)delegate
		 onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector;
- (void)getItemOwnershipsFromServerWithOnSuccess:(void (^)(NSDictionary* ownerships))onSuccess onFailure:(void (^)(PNError* error))onFailure;
- (NSArray*)itemOwnerships;
@end
