//
//  PNDataModel.m
//  PankakuNet
//
//  Created by Sota Yokoe on 10/03/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNDataModel.h"
#import "Helpers.h"
#import "NSString+VersionString.h"

#import "objc/runtime.h"

// from http://code.google.com/p/wonderxml/source/browse/trunk/wonderxml/XmlParser.m?r=8
//
static const char* getPropertyType(objc_property_t property) {
	
    // parse the property attribues. this is a comma delimited string. the type of the attribute starts with the
    // character 'T' should really just use strsep for this, using a C99 variable sized array.
	
    const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
	
    char *state = buffer;
	char *attribute;
	
    while ((attribute = strsep(&state, ",")) != NULL) {
		
        if (attribute[0] == 'T' && strlen(attribute)>2) {
			
            // return a pointer scoped to the autorelease pool. Under GC, this will be a separate block.
			
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute)-4] bytes];
			
			
			
        }else if (attribute[0] == 'T' && strlen(attribute)==2) {
			return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute)] bytes];
		}
		
    }
	
    return "@";
	
}

@implementation PNDataModel
@synthesize min_version, max_version;

- (id)initWithDictionary:(NSDictionary*)aDictionary
{
	if (self = [super init]) {
		self.min_version = [aDictionary stringValueForKey:@"min_version" defaultValue:@"0.0.0"];
		self.max_version = [aDictionary stringValueForKey:@"max_version" defaultValue:@"9999.99.99"];
//		if ([aDictionary hasObjectForKey:@"min_version"]) self.min_version = [aDictionary objectForKey:@"min_version"];
//		if ([aDictionary hasObjectForKey:@"max_version"]) self.max_version = [aDictionary objectForKey:@"max_version"];
	}
	return self;
}

+ (id)dataModelWithDictionary:(NSDictionary*)aDictionary
{
	// nilが渡されたときはnilを返します。
	if (aDictionary == nil) return nil;
	
	return [[[[self class] alloc] initWithDictionary:aDictionary] autorelease];
}

+ (NSArray*)dataModelsFromArray:(NSArray*)anArray
{
	NSMutableArray* dataModels = [NSMutableArray array];
	for (NSDictionary* dictionary in anArray) {
		id parsedObject = [self dataModelWithDictionary:dictionary];
		if (parsedObject) {
			[dataModels addObject:parsedObject];
		}
	}
	return dataModels;
}
+ (NSArray*)availableDataModelsFromArray:(NSArray*)anArray inVersion:(int)version
{
	NSMutableArray* dataModels = [NSMutableArray array];
	for (NSDictionary* dictionary in anArray) {
		PNDataModel* parsedObject = [self dataModelWithDictionary:dictionary];
		if (parsedObject && [parsedObject isAvailableInVersion:version]) {
			[dataModels addObject:parsedObject];
		}
	}
	return dataModels;
}

- (BOOL)isAvailableInVersion:(int)versionInt
{
	if (self.min_version != nil) {
		int minVersion = [min_version versionIntValue];
		if (versionInt < minVersion) return NO;
	}
	if (self.max_version != nil) {
		int maxVersion = [max_version versionIntValue];
		if (versionInt > maxVersion) return NO;
	}
	return YES;
}

- (NSString*)toCanonicalName:(NSString*)s
{
	if (s == nil || [s length] == 0) {
		return nil;
	}
	
	NSMutableString* ss = [[[NSMutableString alloc] init] autorelease];
	// まずすべてを小文字にする
	[ss appendString:[s lowercaseString]];
	NSRange range = [ss rangeOfString:@"_"];
	while ( range.location != NSNotFound ) {
		// "_"があったら消す
		[ss deleteCharactersInRange:range];

		if (range.location == 0) {
			// ignore prefix underscore
			range = [ss rangeOfString:@"_"];
			continue;
		}
		
		// "_"後ろの文字を大文字にする
		[ss replaceCharactersInRange:range
						  withString:[[ss substringWithRange:range] uppercaseString]];
		range = [ss rangeOfString:@"_"];
	}
	return ss;
}

// ********
// *未テスト*
// ********
//
// プロパティがNSArray*配列の場合、
// 配列に格納されるオブジェクトのクラスを示す、"プロパティ名_CLASS"という名のプロパティを定義すること。
// 例：
// NSArray* rooms;
// PNRoomModel* rooms_CLASS;
//
- (id)initWithJSONDictionary:(NSDictionary*)d
{
	if (self = [super init]) {
		for (NSString* key in [d allKeys]) {
			NSObject* o = [d objectForKey:key];
			if ([o isKindOfClass:[NSArray class]]) {
				// 配列の場合
				NSArray* ary = (NSArray*)o;
				NSMutableArray* dataary = [[[NSMutableArray alloc] init] autorelease];
				NSString* ckey = [self toCanonicalName:key];
				
				Class this = [self class];
				objc_property_t property = class_getProperty(this, [[ckey stringByAppendingString:@"_CLASS"] UTF8String]);
				if (property == nil) {
					NSLog(@"Warning: class definition for %@(%@) not found", key, ckey);
					[self setValue:ary forKey:ckey];
					continue;
				}

				const char* type = getPropertyType(property);
				NSString *propertyType = [NSString stringWithCString:type
															encoding:NSUTF8StringEncoding];
				Class dataclass = NSClassFromString(propertyType);
				for ( int i = 1; i < [ary count]; i++ ) {
					if ([dataclass isKindOfClass:[PNDataModel class]]) {
						[dataary addObject:[[dataclass alloc] initWithJSONDictionary:[ary objectAtIndex:i]]];
					} else {
						[dataary addObject:[ary objectAtIndex:i]];
					}
				}
				[self setValue:dataary forKey:[self toCanonicalName:key]];
			} else if ([o isKindOfClass:[NSDictionary class]]) {
				// マップの場合
				Class this = [self class];
				objc_property_t property = class_getProperty(this, [key UTF8String]);
				//const char* attrs = property_getAttributes(property);
				const char* type = getPropertyType(property);
				NSString *propertyType = [NSString stringWithCString:type
															encoding:NSUTF8StringEncoding];
				
				PNDataModel* datamodel = [[[NSClassFromString(propertyType) alloc] initWithJSONDictionary:(NSDictionary*)o] autorelease];
				[self setValue:datamodel forKey:[self toCanonicalName:key]];
			} else {
				// そのた：文字列、真理値、数値、null
				[self setValue:o forKey:[self toCanonicalName:key]];
			}
		}
	}
	return self;
}

@end
