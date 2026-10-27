#import "HyperPlayerBasePrefix.h"
#import "HSUserObject.h"


@interface HSUserObject (MediaSupport)
+ (BOOL)isMediaTypeSupported:(id)aSupported;
- (void)checkIfCanSetMediaFromPath:(id)aPath;
- (void)checkIfMediaTypeIsSupported:(id)aSupported;
- (BOOL)isMediaTypeSupported:(id)aSupported;
- (BOOL)canSetMediaFromPath:(id)aPath;
@end

