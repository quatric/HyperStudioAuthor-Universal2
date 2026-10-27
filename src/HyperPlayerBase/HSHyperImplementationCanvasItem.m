#import "HSHyperImplementationCanvasItem.h"
// A canvas item that draws and hits nothing.
@implementation HSHyperImplementationCanvasItem
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return NO;
}
- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return [HSRegion regionWithRect:[self renderingBoundsInCanvasLayer:aLayer]];
}
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    return NSZeroRect;
}
- (BOOL)prefersRegionInvalidation
{
    return NO;
}
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return NO;
}
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
}
@end
