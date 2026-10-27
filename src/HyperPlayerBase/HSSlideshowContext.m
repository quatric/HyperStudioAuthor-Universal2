#import "HSSlideshowContext.h"
// A slideshow: objects run their own actions only.
@implementation HSSlideshowContext
- (BOOL)isSlideshowContext
{
    return YES;
}
- (NSInteger)renderQuality
{
    return 2;
}
- (BOOL)supportsRotatableObjects
{
    return NO;
}
- (BOOL)supportsResizableObjects
{
    return NO;
}
- (BOOL)supportsDraggableObjects
{
    return NO;
}
- (BOOL)allowsEditing
{
    return NO;
}
- (BOOL)supportsOwnActions
{
    return YES;
}
- (BOOL)supportsUserActions
{
    return NO;
}
@end
