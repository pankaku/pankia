#import "PNError.h"
#import "JsonHelper.h"
#import "PNLocalizedString.h"

@implementation PNError

@synthesize errorType;
@synthesize	errorCode;
@synthesize message;


-(id)init
{
	if([super init]) {
		
	}
	return self;
}

- (id)initWithResponse:(NSString*)response
{
	if (self = [self init]) {
		static NSString* beginStr = @"""";
		static NSString* endStr   = @"""";
		
		NSDictionary* json = [response JSONValue];
		NSString*  detail     = [json objectForKey:@"detail"];
		if (detail && ![detail isKindOfClass:[NSNull class]]) {
			NSRange    beginRange = [detail rangeOfString:beginStr];
			NSRange    endRange   = [detail rangeOfString:endStr];
			NSUInteger _location  = beginRange.location + [beginStr length] + beginRange.length;
			NSUInteger _length    = endRange.location - _location - endRange.length;
			if (_location && _length) {
				self.message = [detail substringWithRange:NSMakeRange(_location, _length)];
			} else {
				self.message = detail;
			}
		} else {
			self.message = @"";
		}
		NSString*  code = [json objectForKey:@"code"];
		self.errorCode = code;
		self.errorType = 0;
	}
	return self;
}

+ (id)errorFromResponse:(NSString*)response
{
	return [[[self alloc] initWithResponse:response] autorelease];
}

- (id)initWithCode:(NSString *)code message:(NSString *)aMessage
{
	if (self = [super init]) {
		self.errorCode = code;
		self.message = aMessage;
	}
	return self;
}
+ (id)errorWithCode:(NSString *)code message:(NSString *)message
{
	return [[[self alloc] initWithCode:code message:message] autorelease];
}

+ (id)connectionError{
	PNError* anInstance = [self error];
	anInstance.errorCode = kPNConnectionError;
	anInstance.message = @"PNTEXT:UI:Connection_Fail";
	return anInstance;
}
- (BOOL)isConnectionError
{
	return [errorCode isEqualToString:kPNConnectionError];
}
+(PNError*)errorWithType:(int)type message:(NSString*)message
{
	PNError *error = [[[PNError alloc] init] autorelease];
	error.message	= message;
	error.errorType = type;
	
	return error;
}

+(PNError*)error
{
	return [[[PNError alloc] init] autorelease];
}

- (NSString*)errorTitle
{
	NSString* title = @"";
	
	if ([self.errorCode isEqualToString:@"invalid_domain"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_domain_title");
	} else if([self.errorCode isEqualToString:@"invalid_http_method"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_http_method_title");
	} else if([self.errorCode isEqualToString:@"invalid_api_method"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_api_method_title");
	} else if([self.errorCode isEqualToString:@"invalid_format"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_format_title");
	} else if([self.errorCode isEqualToString:@"invalid_encoding"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_encoding_title");
	} else if([self.errorCode isEqualToString:@"invalid_session"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_session_title");
	} else if([self.errorCode isEqualToString:@"invalid_user_credentials"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_user_credentials_title");
	} else if([self.errorCode isEqualToString:@"not_signed_in"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_signed_in_title");
	} else if([self.errorCode isEqualToString:@"already_signed_in"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:already_signed_in_title");
	} else if([self.errorCode isEqualToString:@"invalid_user"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_user_title");
	} else if([self.errorCode isEqualToString:@"already_exists"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:already_exists_title");
	} else if([self.errorCode isEqualToString:@"not_confirmed"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_confirmed_title");
	} else if([self.errorCode isEqualToString:@"not_linked"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_linked_title");
	} else if([self.errorCode isEqualToString:@"not_allowed"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_allowed_title");
	} else if([self.errorCode isEqualToString:@"not_found"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_found_title");
	} else if([self.errorCode isEqualToString:@"not_member"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_member_title");
	} else if([self.errorCode isEqualToString:@"text_too_long"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:text_too_long_title");
	} else if([self.errorCode isEqualToString:@"text_empty"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:text_empty_title");
	} else if([self.errorCode isEqualToString:@"missing_parameter"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:missing_parameter_title");
	} else if([self.errorCode isEqualToString:@"invalid_parameter"]) {
		title = getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_parameter_title");
	}
	
	return title;
}

- (NSString*)errorMessage
{
	NSString* msg = @"";
	
	if ([self.errorCode isEqualToString:@"invalid_domain"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_domain_message");
	} else if([self.errorCode isEqualToString:@"invalid_http_method"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_http_method_message");
	} else if([self.errorCode isEqualToString:@"invalid_api_method"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_api_method_message");
	} else if([self.errorCode isEqualToString:@"invalid_format"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_format_message");
	} else if([self.errorCode isEqualToString:@"invalid_encoding"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_encoding_message");
	} else if([self.errorCode isEqualToString:@"invalid_session"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_session_message");
	} else if([self.errorCode isEqualToString:@"invalid_user_credentials"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_user_credentials_message");
	} else if([self.errorCode isEqualToString:@"not_signed_in"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_signed_in_message");
	} else if([self.errorCode isEqualToString:@"already_signed_in"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:already_signed_in_message");
	} else if([self.errorCode isEqualToString:@"invalid_user"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_user_message");
	} else if([self.errorCode isEqualToString:@"already_exists"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:already_exists_message");
	} else if([self.errorCode isEqualToString:@"not_confirmed"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_confirmed_message");
	} else if([self.errorCode isEqualToString:@"not_linked"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_linked_message");
	} else if([self.errorCode isEqualToString:@"not_allowed"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_allowed_message");
	} else if([self.errorCode isEqualToString:@"not_found"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_found_message");
	} else if([self.errorCode isEqualToString:@"not_member"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:not_member_message");
	} else if([self.errorCode isEqualToString:@"text_too_long"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:text_too_long_message");
	} else if([self.errorCode isEqualToString:@"text_empty"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:text_empty_message");
	} else if([self.errorCode isEqualToString:@"missing_parameter"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:missing_parameter_message");
	} else if([self.errorCode isEqualToString:@"invalid_parameter"]) {
		msg =getTextFromTable(@"PNTEXT:UI:SERVERERROR:invalid_parameter_message");
	}
	
	return msg;
}
- (NSString*)message
{
	return getTextFromTable(message);
}

- (NSString*)description
{
	if (errorCode != nil && message != nil) {
		return [NSString stringWithFormat:@"%@: %@", errorCode, message];
	} else if (errorCode != nil && message == nil) {
		return self.errorCode;
	} else if (errorCode == nil && message != nil) {
		return self.message;
	} else {
		return @"Unknown error.";
	}

}

- (void)dealloc
{
	self.message		= nil;	
	[super dealloc];
}

@end
