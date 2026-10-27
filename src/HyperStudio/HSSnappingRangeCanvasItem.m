#import "HSSnappingRangeCanvasItem.h"

@implementation HSSnappingRangeCanvasItem

+ (id)animationPathFillColor
{
    return [NSColor colorWithCalibratedRed:0.3825f green:0.4648f blue:0.9609f alpha:0.25f];
}

+ (id)animationPathStrokeColor
{
    return [NSColor grayColor];
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
    NSRect bounds = [self boundingRectForPrototypeObject:[_delegate itemPrototypeObject]];
    if (NSIsEmptyRect(bounds))
        return NSZeroRect;
    return [self rect:bounds inCanvasLayer:aLayer];
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
    [NSGraphicsContext saveGraphicsState];
    [(NSColor *)[[self class] animationPathStrokeColor] set];
    CGFloat dash[2] = { 10.0, 10.0 };
    id prototype = [_delegate itemPrototypeObject];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[[prototype queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect]];
    [path appendBezierPathWithRect:[self boundingRectForPrototypeObject:prototype]];
    [path setLineDash:dash count:2 phase:0.0];
    [path setLineWidth:0.5];
    path = [self bezierPath:path inCanvasLayer:aLayer];
    [path setWindingRule:NSWindingRuleEvenOdd];
    [path stroke];
    [(NSColor *)[[self class] animationPathFillColor] set];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
}

- (NSRect)boundingRectForPrototypeObject:(id)aObject
{
    float range = (float)[_delegate snappingRange];
    NSRect frame = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    return NSMakeRect(frame.origin.x - range, frame.origin.y - range, frame.size.width + range * 2.0f, frame.size.height + range * 2.0f);
}

- (id)bezierPath:(id)aPath inCanvasLayer:(id)aLayer
{
    id view = [[aLayer context] renderingView];
    if (aPath != nil && view != nil)
        [aPath transformUsingAffineTransform:[view userSpaceToViewSpaceTransform]];
    return aPath;
}

- (NSRect)rect:(NSRect)aRect inCanvasLayer:(id)aLayer
{
    id view = [[aLayer context] renderingView];
    if (NSIsEmptyRect(aRect) || view == nil)
        return aRect;
    NSAffineTransform *transform = [view userSpaceToViewSpaceTransform];
    NSPoint corners[4] = {
        { NSMinX(aRect), NSMinY(aRect) }, { NSMaxX(aRect), NSMinY(aRect) },
        { NSMaxX(aRect), NSMaxY(aRect) }, { NSMinX(aRect), NSMaxY(aRect) }
    };
    CGFloat minX = CGFLOAT_MAX, minY = CGFLOAT_MAX, maxX = -CGFLOAT_MAX, maxY = -CGFLOAT_MAX;
    for (int i = 0; i < 4; i++) {
        NSPoint p = [transform transformPoint:corners[i]];
        minX = MIN(minX, p.x);
        minY = MIN(minY, p.y);
        maxX = MAX(maxX, p.x);
        maxY = MAX(maxY, p.y);
    }
    return NSMakeRect(minX, minY, maxX - minX, maxY - minY);
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

@end
