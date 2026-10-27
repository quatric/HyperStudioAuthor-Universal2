#import "HSPlaybackContext.h"
// Playing a stack: everything allowed, with history.
@implementation HSPlaybackContext
- (BOOL)canOpenObjectInPlayer
{
    return YES;
}
- (BOOL)needsHistory
{
    return YES;
}
- (NSInteger)renderQuality
{
    return 2;
}
- (BOOL)supportsRotatableObjects
{
    return YES;
}
- (BOOL)supportsResizableObjects
{
    return YES;
}
- (BOOL)supportsDraggableObjects
{
    return YES;
}
- (BOOL)supportsOwnActions
{
    return YES;
}
- (BOOL)supportsUserActions
{
    return YES;
}
@end
