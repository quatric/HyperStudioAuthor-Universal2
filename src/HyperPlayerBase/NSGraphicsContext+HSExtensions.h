#import "HyperPlayerBasePrefix.h"


@interface NSGraphicsContext (HSExtensions)
- (CGAffineTransform)currentHyperCGAffineUserSpaceToDeviceSpaceTransform;
- (id)currentHyperUserSpaceToDeviceSpaceTransform;
- (CGAffineTransform)currentHyperCGAffineTransform;
- (id)currentHyperTransform;
@end

