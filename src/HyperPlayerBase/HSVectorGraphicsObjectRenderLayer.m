#import "HSVectorGraphicsObjectRenderLayer.h"
// A vector graphics object: its background clipped to the path, the line endings and (dashed lines) the path.
@implementation HSVectorGraphicsObjectRenderLayer
// The background argument is not used: the object draws its own background over the rect.
- (void)drawBackground:(id)aBackground inRect:(NSRect)aRect
{
    [[self hyperObject] hyperDrawBackgroundInROI:aRect ofBounds:aRect];
}
- (id)strokeColor
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)] hyperStrokeColor];
}
- (id)hyperObject
{
    return [super hyperObject];
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
// The path's visual bounds plus those of both line endings, relative to the path's origin.
- (id)calculateBoundingRegion
{
    id object = [self hyperObject];
    NSBezierPath *path = [[object queryHyperInterface:@protocol(HSVectorGraphicsAttributes)] hyperBezierPath];
    NSRect bounds = [path bounds];
    id region = [HSMutableRegion regionWithRect:NSOffsetRect([path hyperVisualBounds], -bounds.origin.x, -bounds.origin.y)];
    if ([path elementCount] == 0)
        return region;
    CGFloat lineWidth = [path lineWidth];
    CGFloat scale = lineWidth > 1.0f ? log2f(lineWidth) : 1.0f;
    NSBezierPath *head = [[object headEnding] pathAtPoint:[path hyperBasePointOfElementAtIndex:0]
                                                    angle:[path hyperInclineAngleOfElementAtIndex:0]
                                          additionalScale:scale
                                                isInverse:NO];
    if (head != nil) {
        [head setLineWidth:[path lineWidth]];
        [region addRect:NSOffsetRect([head hyperVisualBounds], -bounds.origin.x, -bounds.origin.y)];
    }
    NSUInteger last = [path elementCount] - 1;
    NSBezierPath *tail = [[object tailEnding] pathAtPoint:[path hyperBasePointOfElementAtIndex:last]
                                                    angle:[path hyperInclineAngleOfElementAtIndex:last]
                                          additionalScale:scale
                                                isInverse:YES];
    if (tail != nil) {
        [tail setLineWidth:[path lineWidth]];
        [region addRect:NSOffsetRect([tail hyperVisualBounds], -bounds.origin.x, -bounds.origin.y)];
    }
    return region;
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsLineEndingScaleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsLineEndingsInfoObjectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsHeadEndingAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsTailEndingAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsBezierPathAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsPathStyleAttribute) forObject:object];
}
- (BOOL)requiresTransparencyLayer
{
    return YES;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id object = [self hyperObject];
    id attributes = [object queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    id strokeColor = [self strokeColor];
    [(NSColor *)strokeColor set];
    NSBezierPath *path = [attributes hyperBezierPath];
    NSRect bounds = [path bounds];
    CGContextTranslateCTM([[NSGraphicsContext currentContext] graphicsPort], -bounds.origin.x, -bounds.origin.y);

    // Dynamic stroke width: the path is shrunk so the stroke stays inside its bounds; a stroke wider than the
    // shape itself is cut down to fit.
    NSUInteger factor = [attributes hyperDynamicStrokeWidthAdjustmentFactor];
    if (factor != 0) {
        CGFloat lineWidth = [attributes hyperLineWidth];
        float strokeWidth = lineWidth;
        if (!NSIsEmptyRect(bounds)) {
            float inset = lineWidth * 0.5 * (double)factor;
            if (NSIsEmptyRect(NSInsetRect(bounds, inset, inset)))
                strokeWidth = fminf(bounds.size.width, bounds.size.height) / (float)factor + -0.0001;
        }
        NSRect inner = NSInsetRect(bounds, strokeWidth * 0.5f, strokeWidth * 0.5f);
        float sx = bounds.size.width != 0 ? inner.size.width / bounds.size.width : 1.0f;
        float sy = bounds.size.height != 0 ? inner.size.height / bounds.size.height : 1.0f;
        CGAffineTransform t = CGAffineTransformMake(sx, 0, 0, sy,
                                                    inner.origin.x - bounds.origin.x * sx,
                                                    inner.origin.y - bounds.origin.y * sy);
        path = [[NSAffineTransform transformWithHyperCGAffineTransform:t] transformBezierPath:path];
        [path setLineWidth:strokeWidth];
    }

    // The background, clipped to the path and flipped within its bounds.
    id background = [[object queryHyperInterface:@protocol(HSBackgroundAttributes)] backgroundGraphics];
    if (background != nil) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [path addClip];
        NSRect pathBounds = [path bounds];
        CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, (float)(pathBounds.origin.y + pathBounds.origin.y + pathBounds.size.height));
        [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
        [self drawBackground:background inRect:[path bounds]];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }

    // Line endings (lines only), filled or stroked as each ending says.
    if (![attributes isHyperShape] && strokeColor != nil) {
        CGFloat lineWidth = [path lineWidth];
        CGFloat scale = lineWidth > 1.0f ? log2f(lineWidth) : 1.0f;
        id ending = [object headEnding];
        NSBezierPath *head = [ending pathAtPoint:[path hyperBasePointOfElementAtIndex:0]
                                           angle:[path hyperInclineAngleOfElementAtIndex:0]
                                 additionalScale:scale
                                       isInverse:NO];
        [head setLineWidth:[path lineWidth]];
        if ([ending isFilled])
            [head fill];
        else
            [head stroke];
        ending = [object tailEnding];
        NSUInteger last = [path elementCount] - 1;
        NSBezierPath *tail = [ending pathAtPoint:[path hyperBasePointOfElementAtIndex:last]
                                           angle:[path hyperInclineAngleOfElementAtIndex:last]
                                 additionalScale:scale
                                       isInverse:YES];
        [tail setLineWidth:[path lineWidth]];
        if ([ending isFilled])
            [tail fill];
        else
            [tail stroke];
    }

    if ([attributes hyperLineDashInfo] != nil && strokeColor != nil)
        [path stroke];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSBackgroundAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsLineEndingScaleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsLineEndingsInfoObjectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsHeadEndingAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsTailEndingAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsBezierPathAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsPathStyleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVectorGraphicsStrokeColorAttribute) forObject:object];
}
@end
