#import "HSSimpleCanvasItem.h"
// A canvas item that draws and hits nothing; subclasses give either a
// region or bounds.
@implementation HSSimpleCanvasItem
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return NO;
}
- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    if ([self prefersRegionInvalidation])
        return [HSRegion region];
    return [HSRegion regionWithRect:[self renderingBoundsInCanvasLayer:aLayer]];
}
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    if (![self prefersRegionInvalidation])
        return NSZeroRect;
    return [[self renderingRegionInCanvasLayer:aLayer] boundingRect];
}
- (BOOL)prefersRegionInvalidation
{
    return NO;
}
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return NO;
}
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
}
@end
