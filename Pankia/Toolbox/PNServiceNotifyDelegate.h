#import "PNError.h"

@protocol PNServiceNotifyDelegate <NSObject>

- (void) notify:(NSString*)data userInfo:(id)userInfo;
- (void) error:(PNError*)error userInfo:(id)userInfo;

@end


