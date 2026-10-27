#import "HSPlayerPreviewContext.h"
// A still preview in the player.
@implementation HSPlayerPreviewContext
- (NSInteger)renderQuality
{
    return 1;
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
    return NO;
}
- (BOOL)supportsUserActions
{
    return NO;
}
@end
