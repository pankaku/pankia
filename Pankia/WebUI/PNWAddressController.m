//
//  PNWAddressController.m
//  PankakuNet
//
//  Created by あんのたん on 11/01/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNWAddressController.h"


@implementation PNWAddressController

- (void)profiles {
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef source = ABAddressBookCopyDefaultSource(ab);
	NSArray* persons = (NSArray *)(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(ab, source, kABPersonSortByLastName));
	[persons autorelease];
	CFRelease(source);
	
	NSMutableArray* retArray = [NSMutableArray arrayWithCapacity:[persons count]];
	
	for (int i=0; i<[persons count]; i++) {
		ABRecordRef p = [persons objectAtIndex:i];
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSMutableDictionary* retDic = [NSMutableDictionary dictionary];
		NSString* firstName = (NSString *)(ABRecordCopyValue(p, kABPersonFirstNameProperty));
		[firstName autorelease];
		NSString* lastName = (NSString *)(ABRecordCopyValue(p, kABPersonLastNameProperty));
		[lastName autorelease];
		
		NSMutableString* pName = [NSMutableString string];
		if (lastName) {
			[pName appendString:lastName];
		}
		if (firstName) {
			[pName appendFormat:@" %@", firstName];
		}
		
		NSLog(@"Name:%@", pName);
		[retDic setObject:pName forKey:@"name"];
		
		NSString* phonetic = (NSString *)(ABRecordCopyValue(p, kABPersonLastNamePhoneticProperty));
		[phonetic autorelease];
		
		if ([phonetic length] > 0) {
			[retDic setObject:[phonetic substringToIndex:1] forKey:@"group"];
			NSLog(@"%@", [phonetic substringToIndex:1]);
		}
		
		
		ABMultiValueRef emails = (ABMultiValueRef)(ABRecordCopyValue(p, kABPersonEmailProperty));
		NSArray* emailArray = (NSArray *)(ABMultiValueCopyArrayOfAllValues(emails));
		CFRelease(emails);
		[emailArray autorelease];
		
		if (emailArray) {
			[retDic setObject:emailArray forKey:@"mail"];
			[retArray addObject:retDic];
		}
		
		[pool release];
	}
	
	[request setAsOKWithObject:retArray forKey:@"profiles"];
	CFRelease(ab);
}

@end
