#import "NSGraphicsContext+HSExtensions.h"
@implementation NSGraphicsContext (HSExtensions)
- (CGAffineTransform)currentHyperCGAffineUserSpaceToDeviceSpaceTransform
{
    CGContextRef context = [self CGContext];
    return context != NULL ? CGContextGetUserSpaceToDeviceSpaceTransform(context) : CGAffineTransformIdentity;
}
- (id)currentHyperUserSpaceToDeviceSpaceTransform
{
    return [NSAffineTransform transformWithHyperCGAffineTransform:[self currentHyperCGAffineUserSpaceToDeviceSpaceTransform]];
}
- (CGAffineTransform)currentHyperCGAffineTransform
{
    CGContextRef context = [self CGContext];
    return context != NULL ? CGContextGetCTM(context) : CGAffineTransformIdentity;
}
- (id)currentHyperTransform
{
    return [NSAffineTransform transformWithHyperCGAffineTransform:[self currentHyperCGAffineTransform]];
}
@end
