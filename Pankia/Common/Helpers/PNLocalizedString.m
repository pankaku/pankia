
#import "PNLocalizedString.h"

#include <mach/mach.h>
#include <math.h>

NSString* getTextFromTable(NSString* key) {
	NSString* localizedText		= NSLocalizedStringFromTable(key,@"PNLocalizable", @"");
	return localizedText;
}
