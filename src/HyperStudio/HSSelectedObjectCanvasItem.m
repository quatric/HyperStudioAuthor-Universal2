#import "HSSelectedObjectCanvasItem.h"

@implementation HSSelectedObjectCanvasItem

+ (CGFloat)cardObjectBoundingFrameThickness
{
    return 0.5f;
}

+ (id)cardObjectBoundingFrameColor
{
    return [NSColor darkGrayColor];
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}

- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return YES;
}

// The view-space bounding box of the object's frame, outlined with the frame
// thickness, expressed back through the object's own transform.
- (id)boundingFrameRegionInView:(id)aView
{
    id geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry && [self rendersBoundingFrame]) {
        NSSize size = [(id<HSGeometryAttributes>)geometry size];
        NSRect frame = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height);
        CGAffineTransform viewTransform = [aView userSpaceToViewSpaceCGAffineTransform];
        CGAffineTransform inverse = CGAffineTransformInvert(viewTransform);
        float thickness = [HSSelectedObjectCanvasItem cardObjectBoundingFrameThickness];
        float corners[8] = { NSMinX(frame), NSMinY(frame), NSMaxX(frame), NSMinY(frame), NSMaxX(frame), NSMaxY(frame), NSMinX(frame), NSMaxY(frame) };
        for (int i = 0; i < 4; i++) {
            double x = corners[i * 2];
            double y = corners[i * 2 + 1];
            corners[i * 2] = viewTransform.a * x + viewTransform.c * y + viewTransform.tx;
            corners[i * 2 + 1] = viewTransform.b * x + viewTransform.d * y + viewTransform.ty;
        }
        float minX = MIN(corners[0], corners[2]), maxX = MAX(corners[0], corners[2]);
        float minY = MIN(corners[1], corners[3]), maxY = MAX(corners[1], corners[3]);
        for (int i = 2; i < 4; i++) {
            minX = MIN(minX, corners[i * 2]);
            maxX = MAX(maxX, corners[i * 2]);
            minY = MIN(minY, corners[i * 2 + 1]);
            maxY = MAX(maxY, corners[i * 2 + 1]);
        }
        HSMutableRegion *region = [HSMutableRegion regionWithRectOutline:NSMakeRect(minX, minY, maxX - minX, maxY - minY) strokeThickness:ceilf(thickness)];
        [region applyAffineTransform:inverse];
        [region applyAffineTransform:CGAffineTransformConcat([geometry affineTransform], viewTransform)];
        if (region)
            return region;
    }
    return [HSRegion region];
}

- (id)boundingFramePathInView:(id)aView
{
    id geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (!geometry)
        return nil;
    NSSize size = [(id<HSGeometryAttributes>)geometry size];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height)];
    CGAffineTransform viewTransform = [aView userSpaceToViewSpaceCGAffineTransform];
    CGAffineTransform transform = CGAffineTransformConcat([geometry affineTransform], viewTransform);
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:transform]];
    [path setLineWidth:[HSSelectedObjectCanvasItem cardObjectBoundingFrameThickness]];
    return path;
}

- (id)boundsHitTester
{
    if (!_boundsHitTester)
        _boundsHitTester = [[HSVisualBoundsHitTester alloc] initWithHyperObject:[self hyperObject]];
    return _boundsHitTester;
}

- (void)setRendersBoundingFrame:(BOOL)aFrame
{
    _frameRenderingDisabled = !aFrame;
}

- (BOOL)rendersBoundingFrame
{
    return !_frameRenderingDisabled;
}

- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return [self boundingFrameRegionInView:[[aLayer context] renderingView]];
}

- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    return NSZeroRect;
}

- (BOOL)prefersRegionInvalidation
{
    return [self rendersBoundingFrame];
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    id view = [[aLayer context] renderingView];
    if (!view)
        return YES;
    return [[self boundsHitTester] hitTestUserPoint:[view convertPointFromViewSpaceToUserSpace:aPoint]];
}

// An invisible button gets its border path drawn dashed (unless it is an
// invisible shape button), then the bounding frame is stroked.
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
    if (![self rendersBoundingFrame])
        return;
    if ([[[self hyperObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)] isButtonNaturallyInvisible]) {
        NSBezierPath *border = [[[self hyperObject] queryHyperInterface:@protocol(HSButtonObjectBorderAttributes)] borderPath];
        if (border && ![[[[self hyperObject] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] shapeButtonType] isEqualToString:@"HSInvisibleShapeButtonType"]) {
            id geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
            CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
            CGContextSaveGState(context);
            NSRect borderBounds = [border bounds];
            NSSize size = [(id<HSGeometryAttributes>)geometry size];
            // Centres the border path in the object's frame.
            CGAffineTransform centring = CGAffineTransformMake(1, 0, 0, 1,
                (((NSZeroPoint.x - borderBounds.origin.x) + size.width) - borderBounds.size.width) * 0.5f,
                (size.height + NSZeroPoint.y + NSZeroPoint.y) - (((NSZeroPoint.y - borderBounds.origin.y) + size.height) - borderBounds.size.height) * 0.5f);
            CGAffineTransform viewTransform = [[[aLayer context] renderingView] userSpaceToViewSpaceCGAffineTransform];
            CGAffineTransform objectTransform = CGAffineTransformConcat([geometry affineTransform], viewTransform);
            CGContextConcatCTM(context, CGAffineTransformConcat(centring, objectTransform));
            [self drawPath:[border hyperCGPath]];
            CGContextRestoreGState(context);
        }
    }
    [(NSColor *)[HSSelectedObjectCanvasItem cardObjectBoundingFrameColor] set];
    [(NSBezierPath *)[self boundingFramePathInView:[[aLayer context] renderingView]] stroke];
}

- (void)dealloc
{
    // (The original does not release the hit tester.)
    [_boundsHitTester release];
    [super dealloc];
}

// Dashed white line with a dashed red line offset over it.
- (void)drawPath:(struct CGPath *)aPath
{
    if (!aPath)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (!context)
        return;
    CGFloat whiteDash[2] = { 3, 5 };
    CGContextSetLineWidth(context, 1);
    CGContextSetLineDash(context, 1, whiteDash, 2);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextBeginPath(context);
    CGContextAddPath(context, aPath);
    CGContextStrokePath(context);
    CGFloat redDash[2] = { 5, 3 };
    CGContextSetLineDash(context, 6, redDash, 2);
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
    CGContextBeginPath(context);
    CGContextAddPath(context, aPath);
    CGContextStrokePath(context);
    CGContextSetLineDash(context, 0, NULL, 0);
}

@end
