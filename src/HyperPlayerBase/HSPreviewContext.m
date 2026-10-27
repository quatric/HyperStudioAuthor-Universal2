#import "HSPreviewContext.h"
// A still preview that may be edited.
@implementation HSPreviewContext
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
    return YES;
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
