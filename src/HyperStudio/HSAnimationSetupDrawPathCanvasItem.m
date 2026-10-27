#import "HSAnimationSetupDrawPathCanvasItem.h"

@implementation HSAnimationSetupDrawPathCanvasItem

- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return [self pathForLayer:aLayer] != nil;
}

- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return [HSRegion regionWithRect:[self renderingBoundsInCanvasLayer:aLayer]];
}

- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    id bounded = [self pathForLayer:aLayer];
    if (bounded == nil)
        bounded = [[aLayer context] renderingView];
    return [bounded bounds];
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
    NSBezierPath *path = [self pathForLayer:aLayer];
    if (path != nil) {
        CGFloat dash[2] = {5.0, 2.0};
        [path setLineDash:dash count:2 phase:0.0];
        [[NSColor grayColor] set];
        [path stroke];
    }
}

- (id)pathForLayer:(id)aLayer
{
    NSBezierPath *path = [[[_delegate pathForEditPathCanvasItem:self] copy] autorelease];
    [path transformUsingAffineTransform:[[[aLayer context] renderingView] userSpaceToViewSpaceTransform]];
    return path;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end
