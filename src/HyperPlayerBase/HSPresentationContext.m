#import "HSPresentationContext.h"
// What a presentation (player, editor preview, printing, slideshow…)
// allows; the base context allows nothing.
@implementation HSPresentationContext
+ (id)presentationContext
{
    return [[self new] autorelease];
}
- (BOOL)isInteractive
{
    return [self supportsUserActions] && [self supportsOwnActions] && [self supportsDraggableObjects] && [self supportsResizableObjects] && [self supportsRotatableObjects] && [self canOpenObjectInPlayer];
}
- (BOOL)isUIObjectsContext
{
    return NO;
}
- (BOOL)canOpenObjectInPlayer
{
    return NO;
}
- (BOOL)canOpenObjectInEditor
{
    return NO;
}
- (BOOL)isSlideshowContext
{
    return NO;
}
- (BOOL)needsHistory
{
    return NO;
}
- (BOOL)isPrinting
{
    return NO;
}
- (id)contextIdentifier
{
    return NSStringFromClass([self class]);
}
- (NSInteger)renderQuality
{
    return 0;
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
